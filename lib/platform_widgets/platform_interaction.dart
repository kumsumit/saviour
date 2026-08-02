import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_input.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:yaru/yaru.dart' as yaru;

class PlatformTapSurface extends ConsumerWidget {
  const PlatformTapSurface({
    super.key,
    required this.child,
    required this.onTap,
    this.borderRadius,
    this.color,
    this.padding,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;
  final Color? color;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveRadius =
        borderRadius ??
        BorderRadius.circular(context.platformTheme.controlRadius);
    final content = DecoratedBox(
      decoration: BoxDecoration(color: color, borderRadius: effectiveRadius),
      child: Padding(padding: padding ?? EdgeInsets.zero, child: child),
    );

    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoButton(
        padding: EdgeInsets.zero,
        borderRadius: effectiveRadius,
        onPressed: onTap,
        child: content,
      ),
      // macOS's PushButton paints the system accent gradient and forces its own
      // control padding/radius — it ignores [color], [borderRadius] and
      // [padding], turning a faintly tinted chip into a solid accent block. Use
      // a plain tap surface so the child's own decoration is what shows.
      AppPlatform.macos => _MacosTapSurface(
        onTap: onTap,
        borderRadius: effectiveRadius,
        child: content,
      ),
      AppPlatform.windows => fluent.HoverButton(
        cursor: SystemMouseCursors.click,
        onPressed: onTap,
        builder: (context, states) => Opacity(
          opacity: states.contains(WidgetState.pressed) ? 0.72 : 1,
          child: content,
        ),
      ),
      AppPlatform.linux => material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: content,
        ),
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.Material(
        color: material.Colors.transparent,
        child: material.InkWell(
          borderRadius: effectiveRadius,
          onTap: onTap,
          child: content,
        ),
      ),
    };
  }
}

/// A transparent macOS tap surface that respects the child's own decoration,
/// adding only a pointer cursor and a subtle pressed dim.
class _MacosTapSurface extends StatefulWidget {
  const _MacosTapSurface({
    required this.child,
    required this.onTap,
    required this.borderRadius,
  });

  final Widget child;
  final VoidCallback? onTap;
  final BorderRadius borderRadius;

  @override
  State<_MacosTapSurface> createState() => _MacosTapSurfaceState();
}

class _MacosTapSurfaceState extends State<_MacosTapSurface> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onTap != null;
    return MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : MouseCursor.defer,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => _setPressed(true) : null,
        onTapUp: enabled ? (_) => _setPressed(false) : null,
        onTapCancel: enabled ? () => _setPressed(false) : null,
        onTap: widget.onTap,
        child: Opacity(
          opacity: _pressed ? 0.72 : 1,
          child: ClipRRect(
            borderRadius: widget.borderRadius,
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

/// Backwards-compatible shorthand for an indeterminate circular indicator.
class PlatformProgressIndicator extends StatelessWidget {
  const PlatformProgressIndicator({
    super.key,
    this.size = 22,
    this.color,
    this.semanticLabel,
  });

  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return PlatformCircularProgressIndicator(
      size: size,
      color: color,
      semanticLabel: semanticLabel,
    );
  }
}

/// A platform-aware circular progress indicator.
///
/// A null [value] displays an indeterminate spinner. Otherwise [value] is
/// clamped to the conventional 0 to 1 range.
class PlatformCircularProgressIndicator extends ConsumerWidget {
  const PlatformCircularProgressIndicator({
    super.key,
    this.value,
    this.size = 22,
    this.strokeWidth = 3,
    this.color,
    this.backgroundColor,
    this.semanticLabel,
    this.semanticValue,
  });

  final double? value;
  final double size;
  final double strokeWidth;

  /// Indicator color. Defaults to the theme's [PlatformThemeData.onPrimary],
  /// since indicators are often shown on top of a primary button.
  final Color? color;
  final Color? backgroundColor;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resolvedColor = color ?? context.platformTheme.onPrimary;
    final normalizedValue = value?.clamp(0.0, 1.0);
    return SizedBox.square(
      dimension: size,
      child: switch (ref.watch(appPlatformProvider)) {
        AppPlatform.ios =>
          normalizedValue == null
              ? cupertino.CupertinoActivityIndicator(
                  radius: size / 2,
                  color: resolvedColor,
                )
              : material.CircularProgressIndicator(
                  value: normalizedValue,
                  color: resolvedColor,
                  backgroundColor: backgroundColor,
                  strokeWidth: strokeWidth,
                  semanticsLabel: semanticLabel,
                  semanticsValue: semanticValue,
                ),
        AppPlatform.macos => macos.ProgressCircle(
          value: normalizedValue == null ? null : normalizedValue * 100,
          radius: size / 2,
          borderColor: resolvedColor,
          semanticLabel: semanticLabel,
        ),
        AppPlatform.windows => fluent.ProgressRing(
          value: normalizedValue == null ? null : normalizedValue * 100,
          activeColor: resolvedColor,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          semanticLabel: semanticLabel,
        ),
        AppPlatform.linux => yaru.YaruCircularProgressIndicator(
          value: normalizedValue,
          color: resolvedColor,
          trackColor: backgroundColor,
          strokeWidth: strokeWidth,
          semanticsLabel: semanticLabel,
          semanticsValue: semanticValue,
        ),
        AppPlatform.android ||
        AppPlatform.web ||
        AppPlatform.fuchsia => material.CircularProgressIndicator(
          value: normalizedValue,
          color: resolvedColor,
          backgroundColor: backgroundColor,
          strokeWidth: strokeWidth,
          semanticsLabel: semanticLabel,
          semanticsValue: semanticValue,
        ),
      },
    );
  }
}

class PlatformSwitch extends ConsumerWidget {
  const PlatformSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.focusNode,
    this.autofocus = false,
    this.semanticLabel,
    this.mouseCursor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final FocusNode? focusNode;
  final bool autofocus;
  final String? semanticLabel;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = activeColor ?? context.platformTheme.primary;
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => _SwitchSemantics(
        label: semanticLabel,
        child: cupertino.CupertinoSwitch(
          value: value,
          onChanged: onChanged,
          activeTrackColor: active,
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor == null
              ? null
              : WidgetStatePropertyAll(mouseCursor!),
        ),
      ),
      AppPlatform.macos => PlatformInputActivator(
        focusNode: focusNode,
        autofocus: autofocus,
        mouseCursor: mouseCursor,
        semanticLabel: semanticLabel,
        button: false,
        toggled: value,
        onActivate: onChanged == null ? null : () => onChanged!(!value),
        excludeChildSemantics: true,
        child: macos.MacosSwitch(
          value: value,
          onChanged: onChanged,
          activeColor: macos.MacosColor(active.toARGB32()),
        ),
      ),
      AppPlatform.windows => fluent.ToggleSwitch(
        checked: value,
        onChanged: onChanged,
        focusNode: focusNode,
        autofocus: autofocus,
        semanticLabel: semanticLabel,
      ),
      AppPlatform.linux => _SwitchSemantics(
        label: semanticLabel,
        child: yaru.YaruSwitch(
          value: value,
          onChanged: onChanged,
          selectedColor: active,
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor,
        ),
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => _SwitchSemantics(
        label: semanticLabel,
        child: material.Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: active,
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor,
          materialTapTargetSize: material.MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    };
  }
}

class _SwitchSemantics extends StatelessWidget {
  const _SwitchSemantics({required this.label, required this.child});

  final String? label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (label == null) return child;
    return MergeSemantics(
      child: Semantics(label: label, child: child),
    );
  }
}

class PlatformLinearProgressIndicator extends ConsumerWidget {
  const PlatformLinearProgressIndicator({
    super.key,
    required this.value,
    this.height = 3,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final double height;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final normalizedValue = value.clamp(0.0, 1.0);
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => _CupertinoProgressBar(
        value: normalizedValue,
        height: height,
        color: color,
        backgroundColor: backgroundColor,
      ),
      AppPlatform.macos => macos.ProgressBar(
        value: normalizedValue * 100,
        height: height,
        trackColor: color,
        backgroundColor: backgroundColor,
      ),
      AppPlatform.windows => fluent.ProgressBar(
        value: normalizedValue * 100,
        strokeWidth: height,
        activeColor: color,
        backgroundColor: backgroundColor,
      ),
      AppPlatform.linux => yaru.YaruLinearProgressIndicator(
        value: normalizedValue,
        strokeWidth: height,
        color: color,
        trackColor: backgroundColor,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.LinearProgressIndicator(
        value: normalizedValue,
        minHeight: height,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    };
  }
}

class PlatformRadioIndicator extends ConsumerWidget {
  const PlatformRadioIndicator({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => RadioGroup<bool>(
        groupValue: selected,
        onChanged: (_) => onSelected(),
        child: const cupertino.CupertinoRadio<bool>(value: true),
      ),
      AppPlatform.macos => macos.MacosRadioButton<bool>(
        value: true,
        groupValue: selected,
        onChanged: (_) => onSelected(),
      ),
      AppPlatform.windows => RadioGroup<bool>(
        groupValue: selected,
        onChanged: (_) => onSelected(),
        child: const fluent.RadioButton<bool>(value: true),
      ),
      AppPlatform.linux => yaru.YaruRadioButton<bool>(
        value: true,
        groupValue: selected,
        onChanged: (_) => onSelected(),
        title: const SizedBox.shrink(),
        contentPadding: EdgeInsets.zero,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => RadioGroup<bool>(
        groupValue: selected,
        onChanged: (_) => onSelected(),
        child: const material.Radio<bool>(value: true),
      ),
    };
  }
}

class _CupertinoProgressBar extends StatelessWidget {
  const _CupertinoProgressBar({
    required this.value,
    required this.height,
    required this.color,
    required this.backgroundColor,
  });

  final double value;
  final double height;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) => ClipRRect(
        borderRadius: BorderRadius.circular(height),
        child: ColoredBox(
          color: backgroundColor,
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: SizedBox(
              width: constraints.maxWidth * value,
              height: height,
              child: ColoredBox(color: color),
            ),
          ),
        ),
      ),
    );
  }
}
