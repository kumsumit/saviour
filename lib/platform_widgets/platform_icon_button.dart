import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_icons.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// A platform-aware icon button.
///
/// Renders the native icon button for each platform — `CupertinoButton` on iOS,
/// macos `MacosIconButton`, fluent `IconButton`, and Material `IconButton` (also
/// used for Linux). The icon color defaults to the theme's `onSurface`.
///
/// Use the default constructor with an explicit [IconData], or
/// [PlatformIconButton.kind] to render a [PlatformIconKind] resolved to each
/// platform's native glyph automatically.
class PlatformIconButton extends ConsumerWidget {
  const PlatformIconButton({
    super.key,
    required IconData this.icon,
    required this.onPressed,
    this.color,
    this.size = 22,
    this.tooltip,
    this.padding,
  }) : kind = null;

  /// Renders the native glyph for [iconKind] on the current platform.
  const PlatformIconButton.kind({
    super.key,
    required PlatformIconKind iconKind,
    required this.onPressed,
    this.color,
    this.size = 22,
    this.tooltip,
    this.padding,
  }) : icon = null,
       kind = iconKind;

  /// The icon to display. Null when constructed via [PlatformIconButton.kind].
  final IconData? icon;

  /// The semantic icon kind, resolved to a native glyph per platform. Null when
  /// constructed with an explicit [icon].
  final PlatformIconKind? kind;

  /// Called when the button is tapped. When null the button is disabled.
  final VoidCallback? onPressed;

  /// Icon color. Defaults to the theme's [PlatformThemeData.onSurface].
  final Color? color;

  /// Icon size.
  final double size;

  /// Optional tooltip shown on hover / long-press.
  final String? tooltip;

  /// Optional padding around the icon.
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final resolvedColor = color ?? context.platformTheme.onSurface;
    final resolvedIcon = icon ?? platformIcon(platform, kind!);
    final iconWidget = Icon(resolvedIcon, size: size, color: resolvedColor);

    final button = switch (platform) {
      AppPlatform.ios => cupertino.CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        onPressed: onPressed,
        child: iconWidget,
      ),
      AppPlatform.macos => macos.MacosIconButton(
        icon: iconWidget,
        padding: padding,
        onPressed: onPressed,
      ),
      AppPlatform.windows => fluent.IconButton(
        icon: iconWidget,
        onPressed: onPressed,
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.IconButton(
        icon: iconWidget,
        padding: padding ?? const EdgeInsets.all(8),
        onPressed: onPressed,
      ),
    };

    if (tooltip == null) return button;
    return material.Tooltip(message: tooltip, child: button);
  }
}
