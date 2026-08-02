import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// Adds keyboard, pointer, and assistive-input activation to custom controls.
///
/// Native controls should use their own focus APIs when available. This is for
/// platform-specific compositions that do not expose keyboard activation.
class PlatformInputActivator extends StatefulWidget {
  const PlatformInputActivator({
    super.key,
    required this.child,
    required this.onActivate,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
    this.semanticLabel,
    this.button = true,
    this.toggled,
    this.excludeChildSemantics = false,
  });

  final Widget child;
  final VoidCallback? onActivate;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;
  final String? semanticLabel;
  final bool button;
  final bool? toggled;
  final bool excludeChildSemantics;

  @override
  State<PlatformInputActivator> createState() => _PlatformInputActivatorState();
}

class _PlatformInputActivatorState extends State<PlatformInputActivator> {
  bool _showFocusHighlight = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onActivate != null;
    final child = widget.excludeChildSemantics
        ? ExcludeSemantics(child: widget.child)
        : widget.child;

    return Semantics(
      label: widget.semanticLabel,
      button: widget.button,
      toggled: widget.toggled,
      enabled: enabled,
      onTap: widget.onActivate,
      child: FocusableActionDetector(
        enabled: enabled,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        onShowFocusHighlight: (value) {
          setState(() => _showFocusHighlight = value);
        },
        mouseCursor:
            widget.mouseCursor ??
            (enabled ? SystemMouseCursors.click : SystemMouseCursors.basic),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onActivate?.call();
              return null;
            },
          ),
        },
        child: DecoratedBox(
          position: DecorationPosition.foreground,
          decoration: BoxDecoration(
            border: _showFocusHighlight
                ? Border.all(color: context.platformTheme.primary, width: 2)
                : null,
            borderRadius: BorderRadius.circular(
              context.platformTheme.controlRadius,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
