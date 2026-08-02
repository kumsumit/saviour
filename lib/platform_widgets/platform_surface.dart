import 'dart:ui' as ui;

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

/// A platform-aware container for visually grouping related content.
class PlatformCard extends ConsumerWidget {
  const PlatformCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.color,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.platformTheme;
    // Windows keeps the platform radius a touch tighter on its cards; everyone
    // else uses the shared surface radius.
    final radius = ref.watch(appPlatformProvider) == AppPlatform.windows
        ? theme.controlRadius
        : theme.surfaceRadius;
    return GlassSurface(
      borderRadius: BorderRadius.circular(radius),
      tint: color,
      margin: margin,
      padding: padding,
      child: child,
    );
  }
}

/// A subtle frosted-glass surface: a translucent [tint] over a backdrop blur,
/// finished with a faint light edge so panels read as panes of glass rather
/// than flat fills.
///
/// Kept deliberately understated ("slight" glassmorphism) so surfaces still
/// feel at home next to the native platform widgets. Reused across the app's
/// container surfaces (cards, bars, banners) so the glass treatment stays
/// consistent — tune [blurSigma] / [opacity] for a stronger or fainter pane.
class GlassSurface extends StatelessWidget {
  const GlassSurface({
    super.key,
    required this.child,
    this.borderRadius = BorderRadius.zero,
    this.tint,
    this.padding,
    this.margin,
    this.blurSigma = 12,
    this.opacity = 1,
    this.border = true,
  });

  final Widget child;
  final BorderRadius borderRadius;

  /// Base color tinting the glass. Defaults to the theme's surface container.
  final Color? tint;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  /// Gaussian blur strength applied to whatever sits behind the surface.
  final double blurSigma;

  /// Scales the tint's translucency: 1 keeps the default frosting, lower values
  /// make the pane clearer, higher values (capped at fully opaque) more solid.
  final double opacity;

  /// Whether to draw the faint light edge that gives the pane its sheen.
  final bool border;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final isDark = theme.isDark;
    final tintColor = tint ?? theme.surfaceContainer;
    // A light edge gives the surface a faint sheen; dark themes lean on a thin
    // white highlight, lighter themes on a brighter one.
    final highlight = const Color(0xFFFFFFFF)
        .withValues(alpha: isDark ? 0.08 : 0.45);
    double alpha(double base) => (base * opacity).clamp(0.0, 1.0);
    return Container(
      margin: margin,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  tintColor.withValues(alpha: alpha(isDark ? 0.62 : 0.72)),
                  tintColor.withValues(alpha: alpha(isDark ? 0.48 : 0.58)),
                ],
              ),
              border: border
                  ? Border.all(color: highlight, width: 0.8)
                  : null,
            ),
            child: padding == null
                ? child
                : Padding(padding: padding!, child: child),
          ),
        ),
      ),
    );
  }
}

/// A separator whose weight follows the current platform convention.
class PlatformDivider extends ConsumerWidget {
  const PlatformDivider({super.key, this.indent, this.endIndent});

  final double? indent;
  final double? endIndent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    return material.Divider(
      color: context.platformTheme.outlineVariant,
      height: platform == AppPlatform.ios ? 0.5 : 1,
      thickness: platform == AppPlatform.ios ? 0.5 : 1,
      indent: indent,
      endIndent: endIndent,
    );
  }
}

/// A platform-aware tooltip for pointer hover and long press.
class PlatformTooltip extends ConsumerWidget {
  const PlatformTooltip({
    super.key,
    required this.message,
    required this.child,
    this.excludeFromSemantics = false,
  });

  final String message;
  final Widget child;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.macos => macos.MacosTooltip(
        message: message,
        excludeFromSemantics: excludeFromSemantics,
        child: child,
      ),
      AppPlatform.windows => fluent.Tooltip(
        message: message,
        excludeFromSemantics: excludeFromSemantics,
        child: child,
      ),
      AppPlatform.ios ||
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.Tooltip(
        message: message,
        excludeFromSemantics: excludeFromSemantics,
        child: child,
      ),
    };
  }
}

/// A platform-aware expandable section for secondary content.
class PlatformDisclosure extends ConsumerStatefulWidget {
  const PlatformDisclosure({
    super.key,
    required this.header,
    required this.child,
    this.initiallyExpanded = false,
    this.onChanged,
  });

  final Widget header;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onChanged;

  @override
  ConsumerState<PlatformDisclosure> createState() => _PlatformDisclosureState();
}

class _PlatformDisclosureState extends ConsumerState<PlatformDisclosure> {
  late bool _expanded = widget.initiallyExpanded;

  void _setExpanded(bool expanded) {
    setState(() => _expanded = expanded);
    widget.onChanged?.call(expanded);
  }

  @override
  Widget build(BuildContext context) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.windows => fluent.Expander(
        header: widget.header,
        content: widget.child,
        initiallyExpanded: widget.initiallyExpanded,
        onStateChanged: widget.onChanged,
      ),
      AppPlatform.linux => yaru.YaruExpandable(
        header: widget.header,
        isExpanded: _expanded,
        onChange: _setExpanded,
        child: widget.child,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.ExpansionTile(
        title: widget.header,
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: widget.onChanged,
        children: [widget.child],
      ),
      AppPlatform.macos => _DisclosureBody(
        header: widget.header,
        expanded: _expanded,
        onPressed: () => _setExpanded(!_expanded),
        button: macos.MacosDisclosureButton(
          isPressed: _expanded,
          onPressed: () => _setExpanded(!_expanded),
        ),
        child: widget.child,
      ),
      AppPlatform.ios => _DisclosureBody(
        header: widget.header,
        expanded: _expanded,
        onPressed: () => _setExpanded(!_expanded),
        button: Icon(
          _expanded
              ? cupertino.CupertinoIcons.chevron_down
              : cupertino.CupertinoIcons.chevron_forward,
          size: 16,
        ),
        child: widget.child,
      ),
    };
  }
}

class _DisclosureBody extends StatelessWidget {
  const _DisclosureBody({
    required this.header,
    required this.child,
    required this.expanded,
    required this.onPressed,
    required this.button,
  });

  final Widget header;
  final Widget child;
  final bool expanded;
  final VoidCallback onPressed;
  final Widget button;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformInputActivator(
          onActivate: onPressed,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onPressed,
            child: Row(
              children: [
                Expanded(child: header),
                const SizedBox(width: 8),
                button,
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: 8),
            child: child,
          ),
          crossFadeState: expanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 180),
        ),
      ],
    );
  }
}
