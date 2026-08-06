import 'package:saviour/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:saviour/platform_widgets/platform_theme.dart';

/// A platform-aware one-time-code input: a row of digit boxes backed by a
/// single hidden [EditableText].
///
/// Using one hidden field (instead of N chained text fields) keeps focus
/// handling, backspace, and paste-of-a-full-code working identically on every
/// platform, and avoids depending on Material/Cupertino field internals —
/// the visible boxes are plain decorated boxes styled from the platform
/// theme.
class PlatformOtpInput extends StatefulWidget {
  const PlatformOtpInput({
    super.key,
    required this.length,
    required this.onChanged,
    this.onCompleted,
    this.autofocus = true,
    this.enabled = true,
    this.boxWidth = 46,
    this.boxHeight = 56,
  });

  final int length;

  /// Fires on every edit with the current (possibly partial) code.
  final ValueChanged<String> onChanged;

  /// Fires once each time the code reaches [length] digits.
  final ValueChanged<String>? onCompleted;

  final bool autofocus;
  final bool enabled;
  final double boxWidth;
  final double boxHeight;

  @override
  State<PlatformOtpInput> createState() => PlatformOtpInputState();
}

class PlatformOtpInputState extends State<PlatformOtpInput> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String get code => _controller.text;

  /// Clears the entered code (e.g. on resend) and refocuses the input.
  void clear() {
    _controller.clear();
    widget.onChanged('');
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleChanged(String value) {
    widget.onChanged(value);
    if (value.length == widget.length) {
      widget.onCompleted?.call(value);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final text = _controller.text;
    final focused = _focusNode.hasFocus;
    final radius = BorderRadius.circular(theme.controlRadius);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.enabled ? _focusNode.requestFocus : null,
      child: Stack(
        children: [
          // Hidden field that owns the actual text + keyboard interaction.
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: EditableText(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                readOnly: !widget.enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(widget.length),
                ],
                autofillHints: const [AutofillHints.oneTimeCode],
                style: const TextStyle(color: SaviourPalette.transparent),
                cursorColor: SaviourPalette.transparent,
                backgroundCursorColor: SaviourPalette.transparent,
                onChanged: _handleChanged,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(widget.length, (index) {
              final filled = index < text.length;
              final isActive =
                  focused &&
                  (index == text.length ||
                      (text.length == widget.length &&
                          index == widget.length - 1));
              return Container(
                width: widget.boxWidth,
                height: widget.boxHeight,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: filled || isActive
                      ? theme.primary.withValues(alpha: 0.06)
                      : theme.surface,
                  borderRadius: radius,
                  border: Border.all(
                    color: isActive
                        ? theme.primary
                        : theme.outlineVariant.withValues(alpha: 0.6),
                    width: isActive ? 2 : 1.4,
                  ),
                ),
                child: Text(
                  filled ? text[index] : '',
                  style: theme.text.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: theme.onSurface,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
