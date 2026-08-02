import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_icons.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

enum PlatformButtonKind { primary, outlined, text }

/// A platform-aware button.
///
/// Renders the native button for each platform — `CupertinoButton` on iOS,
/// macos `PushButton`, fluent `FilledButton` / `Button` / `HyperlinkButton`, and
/// Material `ElevatedButton` / `OutlinedButton` / `TextButton` (also used for
/// Linux) — selected by [kind] (primary / outlined / text).
class PlatformButton extends ConsumerWidget {
  const PlatformButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.kind = PlatformButtonKind.primary,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
    this.borderRadius,
  });

  /// A button whose content is an [icon] followed by a [label].
  ///
  /// The icon and label inherit the button's per-kind foreground color, since
  /// the content is wrapped in `IconTheme` / `DefaultTextStyle` like any other
  /// child.
  PlatformButton.icon({
    super.key,
    required IconData icon,
    required Widget label,
    required this.onPressed,
    this.kind = PlatformButtonKind.primary,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
    this.borderRadius,
    double iconSize = 18,
    double gap = 8,
  }) : child = _IconLabel(
         icon: icon,
         label: label,
         iconSize: iconSize,
         gap: gap,
       );

  /// A button whose content is a [PlatformIconKind] (resolved to each platform's
  /// native glyph) followed by a [label].
  PlatformButton.iconKind({
    super.key,
    required PlatformIconKind iconKind,
    required Widget label,
    required this.onPressed,
    this.kind = PlatformButtonKind.primary,
    this.accentColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
    this.borderRadius,
    double iconSize = 18,
    double gap = 8,
  }) : child = _IconKindLabel(
         iconKind: iconKind,
         label: label,
         iconSize: iconSize,
         gap: gap,
       );

  final Widget child;
  final VoidCallback? onPressed;
  final PlatformButtonKind kind;
  final Color? accentColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final theme = context.platformTheme;
    final accent = accentColor ?? theme.primary;
    final accentForeground = theme.accessibleAccent(accent);
    final onAccent = theme.foregroundFor(accent);
    final radius = borderRadius ?? BorderRadius.circular(theme.controlRadius);
    final isPrimary = kind == PlatformButtonKind.primary;
    final content = _ButtonContent(
      color: isPrimary ? onAccent : accentForeground,
      child: child,
    );
    final cupertinoContent = kind == PlatformButtonKind.outlined
        ? DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: accent),
              borderRadius: radius,
            ),
            child: Padding(padding: padding, child: content),
          )
        : content;
    return switch (platform) {
      AppPlatform.ios => cupertino.CupertinoButton(
        color: isPrimary ? accent : null,
        disabledColor: accent.withValues(alpha: isPrimary ? 0.55 : 0),
        padding: kind == PlatformButtonKind.outlined
            ? EdgeInsets.zero
            : padding,
        borderRadius: radius,
        onPressed: onPressed,
        child: cupertinoContent,
      ),
      AppPlatform.macos =>
        isPrimary
            ? macos.PushButton(
                controlSize: macos.ControlSize.large,
                padding: padding,
                borderRadius: radius,
                onPressed: onPressed,
                child: _StyledButtonContent(child: child),
              )
            : macos.PushButton(
                controlSize: macos.ControlSize.large,
                padding: padding,
                borderRadius: radius,
                secondary: true,
                onPressed: onPressed,
                child: _StyledButtonContent(child: child),
              ),
      AppPlatform.windows =>
        isPrimary
            ? fluent.FilledButton(
                onPressed: onPressed,
                child: Padding(padding: padding, child: content),
              )
            : kind == PlatformButtonKind.outlined
            ? fluent.Button(
                onPressed: onPressed,
                child: Padding(padding: padding, child: content),
              )
            : fluent.HyperlinkButton(
                onPressed: onPressed,
                child: Padding(padding: padding, child: content),
              ),
      AppPlatform.linux =>
        isPrimary
            ? material.FilledButton(
                onPressed: onPressed,
                style: material.FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  padding: padding,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              )
            : kind == PlatformButtonKind.outlined
            ? material.OutlinedButton(
                onPressed: onPressed,
                style: material.OutlinedButton.styleFrom(
                  foregroundColor: accentForeground,
                  padding: padding,
                  side: BorderSide(color: accent),
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              )
            : material.TextButton(
                onPressed: onPressed,
                style: material.TextButton.styleFrom(
                  foregroundColor: accentForeground,
                  padding: padding,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              ),
      AppPlatform.android || AppPlatform.web || AppPlatform.fuchsia =>
        isPrimary
            ? material.ElevatedButton(
                onPressed: onPressed,
                style: material.ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: accent,
                  foregroundColor: onAccent,
                  padding: padding,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              )
            : kind == PlatformButtonKind.outlined
            ? material.OutlinedButton(
                onPressed: onPressed,
                style: material.OutlinedButton.styleFrom(
                  foregroundColor: accentForeground,
                  padding: padding,
                  side: BorderSide(color: accent),
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              )
            : material.TextButton(
                onPressed: onPressed,
                style: material.TextButton.styleFrom(
                  foregroundColor: accentForeground,
                  padding: padding,
                  shape: RoundedRectangleBorder(borderRadius: radius),
                ),
                child: content,
              ),
    };
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({
    required this.icon,
    required this.label,
    required this.iconSize,
    required this.gap,
  });

  final IconData icon;
  final Widget label;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize),
        SizedBox(width: gap),
        label,
      ],
    );
  }
}

/// Resolves a [PlatformIconKind] to the current platform's native glyph, so the
/// icon can be composed at construction time (as the button's `child`) without
/// the button needing to know the platform.
class _IconKindLabel extends ConsumerWidget {
  const _IconKindLabel({
    required this.iconKind,
    required this.label,
    required this.iconSize,
    required this.gap,
  });

  final PlatformIconKind iconKind;
  final Widget label;
  final double iconSize;
  final double gap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(platformIcon(platform, iconKind), size: iconSize),
        SizedBox(width: gap),
        label,
      ],
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.color, required this.child});

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textStyle = context.platformTheme.textTheme.labelLarge;
    return DefaultTextStyle.merge(
      style: textStyle?.copyWith(color: color, fontWeight: FontWeight.w700),
      child: IconTheme.merge(
        data: IconThemeData(color: color),
        child: child,
      ),
    );
  }
}

/// Applies the foreground color chosen by the native macOS button to icons too.
class _StyledButtonContent extends StatelessWidget {
  const _StyledButtonContent({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: IconThemeData(color: DefaultTextStyle.of(context).style.color),
      child: child,
    );
  }
}
