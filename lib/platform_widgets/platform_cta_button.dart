import 'package:flutter/widgets.dart';

import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// The brand's full-width gradient call-to-action button (Continue / Verify
/// OTP / Submit), platform-aware in its tap feedback, corner radius,
/// typography and progress indicator.
///
/// Unlike [PlatformButton] this deliberately keeps the primary→secondary
/// brand gradient on every platform — it is the app's signature CTA — while
/// everything around it (radius, font, ripple/cursor behaviour, spinner)
/// resolves natively via the platform theme and [PlatformTapSurface].
class PlatformCtaButton extends StatelessWidget {
  const PlatformCtaButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.trailingIcon,
    this.loading = false,
    this.enabled = true,
    this.height = 56,
  });

  final String label;
  final VoidCallback? onPressed;

  /// Optional icon rendered after the label (e.g. a forward arrow).
  final IconData? trailingIcon;

  /// Shows a platform progress indicator instead of the label and disables
  /// taps while true.
  final bool loading;

  /// When false the button renders in a muted disabled style and ignores taps.
  final bool enabled;

  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final active = enabled && !loading && onPressed != null;
    final radius = BorderRadius.circular(theme.controlRadius);

    final foreground = active
        ? theme.onPrimary
        : theme.onSurfaceVariant.withValues(alpha: 0.7);

    final decoration = BoxDecoration(
      gradient: active
          ? LinearGradient(
              colors: [theme.primary, theme.secondary],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
          : null,
      color: active ? null : theme.surfaceContainer,
      borderRadius: radius,
    );

    final content = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: PlatformCircularProgressIndicator(color: foreground),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: theme.text.titleMedium?.copyWith(
                  color: foreground,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (trailingIcon != null) ...[
                const SizedBox(width: 10),
                Icon(trailingIcon, color: foreground, size: 20),
              ],
            ],
          );

    return SizedBox(
      width: double.infinity,
      height: height,
      child: PlatformTapSurface(
        onTap: active ? onPressed : null,
        borderRadius: radius,
        child: DecoratedBox(
          decoration: decoration,
          child: Center(child: content),
        ),
      ),
    );
  }
}
