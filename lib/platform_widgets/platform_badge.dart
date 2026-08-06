import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:yaru/yaru.dart' as yaru;

enum PlatformBadgeSeverity { info, success, warning, error }

/// A native notification/status badge that can stand alone or decorate child.
///
/// Uses Fluent `InfoBadge`, Yaru `YaruInfoBadge`, Material 3 `Badge`, and a
/// compact Apple-style capsule on platforms without a dedicated badge control.
class PlatformBadge extends ConsumerWidget {
  const PlatformBadge({
    super.key,
    this.label,
    this.child,
    this.severity = PlatformBadgeSeverity.info,
    this.backgroundColor,
    this.foregroundColor,
    this.alignment = AlignmentDirectional.topEnd,
  });

  final Widget? label;
  final Widget? child;
  final PlatformBadgeSeverity severity;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.platformTheme;
    final color = backgroundColor ?? _severityColor(theme, severity);
    final foreground = foregroundColor ?? theme.foregroundFor(color);
    final badge = switch (ref.watch(appPlatformProvider)) {
      AppPlatform.windows => fluent.InfoBadge(
        source: label,
        color: color,
        foregroundColor: foreground,
        severity: _fluentSeverity(severity),
      ),
      AppPlatform.linux => yaru.YaruInfoBadge(
        title: label ?? const SizedBox.square(dimension: 6),
        yaruInfoType: _yaruSeverity(severity),
        color: color,
        padding: label == null ? const EdgeInsets.all(3) : null,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.Badge(
        label: label,
        backgroundColor: color,
        textColor: foreground,
      ),
      AppPlatform.ios || AppPlatform.macos => Container(
        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
        padding: label == null
            ? const EdgeInsets.all(4)
            : const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: label == null
            ? null
            : DefaultTextStyle.merge(
                style: theme.text.labelMedium?.copyWith(
                  color: foreground,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                child: label!,
              ),
      ),
    };

    if (child == null) return badge;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned.fill(
          child: Align(alignment: alignment, child: badge),
        ),
      ],
    );
  }
}

Color _severityColor(PlatformThemeData theme, PlatformBadgeSeverity severity) =>
    switch (severity) {
      PlatformBadgeSeverity.info => theme.primary,
      PlatformBadgeSeverity.success => theme.success,
      PlatformBadgeSeverity.warning => theme.warning,
      PlatformBadgeSeverity.error => theme.destructive,
    };

fluent.InfoBarSeverity _fluentSeverity(PlatformBadgeSeverity severity) =>
    switch (severity) {
      PlatformBadgeSeverity.info => fluent.InfoBarSeverity.info,
      PlatformBadgeSeverity.success => fluent.InfoBarSeverity.success,
      PlatformBadgeSeverity.warning => fluent.InfoBarSeverity.warning,
      PlatformBadgeSeverity.error => fluent.InfoBarSeverity.error,
    };

yaru.YaruInfoType _yaruSeverity(PlatformBadgeSeverity severity) =>
    switch (severity) {
      PlatformBadgeSeverity.info => yaru.YaruInfoType.information,
      PlatformBadgeSeverity.success => yaru.YaruInfoType.success,
      PlatformBadgeSeverity.warning => yaru.YaruInfoType.warning,
      PlatformBadgeSeverity.error => yaru.YaruInfoType.danger,
    };
