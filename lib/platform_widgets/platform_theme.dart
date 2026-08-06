import 'package:flutter/widgets.dart';
import 'package:saviour/providers/app_colors_provider.dart';
import 'package:saviour/providers/app_platform_provider.dart';

class PlatformThemeData {
  const PlatformThemeData({
    required this.brightness,
    required this.platform,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.surface,
    required this.surfaceContainer,
    required this.onSurface,
    required this.onSurfaceVariant,
    required this.outline,
    required this.outlineVariant,
    required this.text,
    required this.controlRadius,
    required this.surfaceRadius,
  });

  factory PlatformThemeData.forPlatform({
    required AppPlatform platform,
    required Brightness brightness,
    Color? seed,
  }) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = isDark
        ? AppColors.darkScheme(seed)
        : AppColors.lightScheme(seed);
    final onSurface = colorScheme.onSurface;
    final onSurfaceVariant = colorScheme.onSurfaceVariant;
    final primary = colorScheme.primary;
    final surface = colorScheme.surface;
    return PlatformThemeData(
      brightness: brightness,
      platform: platform,
      // A lighter accent reads better on dark surfaces; flip the on-accent
      // foreground to a dark tone so labels stay legible on the lighter accent.
      primary: primary,
      onPrimary: AppColors.foregroundFor(
        primary,
        light: onSurface,
        dark: onSurface,
        alternative: surface,
      ),
      secondary: colorScheme.secondary,
      surface: surface,
      surfaceContainer: colorScheme.surfaceContainerHighest,
      onSurface: onSurface,
      onSurfaceVariant: onSurfaceVariant,
      outline: colorScheme.outline,
      outlineVariant: colorScheme.outlineVariant,
      text: PlatformTextStyles.forPlatform(
        platform: platform,
        onSurface: onSurface,
      ),
      controlRadius: switch (platform) {
        AppPlatform.ios => 12,
        AppPlatform.macos => 8,
        AppPlatform.windows => 4,
        AppPlatform.linux => 8,
        AppPlatform.android || AppPlatform.web || AppPlatform.fuchsia => 20,
      },
      surfaceRadius: switch (platform) {
        AppPlatform.ios => 16,
        AppPlatform.macos => 10,
        AppPlatform.windows => 4,
        AppPlatform.linux => 8,
        AppPlatform.android || AppPlatform.web || AppPlatform.fuchsia => 12,
      },
    );
  }

  final Brightness brightness;
  final AppPlatform platform;

  /// Brand accent used for primary actions and selection.
  final Color primary;

  /// Foreground (text / icon) color shown on top of [primary].
  final Color onPrimary;

  /// Secondary brand accent.
  final Color secondary;
  final Color surface;
  final Color surfaceContainer;
  final Color onSurface;
  final Color onSurfaceVariant;
  final Color outline;
  final Color outlineVariant;
  final PlatformTextStyles text;
  final double controlRadius;
  final double surfaceRadius;

  bool get isDark => brightness == Brightness.dark;
  PlatformThemeData get colorScheme => this;
  PlatformTextStyles get textTheme => text;
  Color get surfaceContainerHighest => surfaceContainer;

  /// Returns a readable foreground derived from this theme's own text tokens.
  Color foregroundFor(Color background) => AppColors.foregroundFor(
    background,
    light: onSurface,
    dark: onSurface,
    alternative: surface,
  );

  Color accessibleAccent(
    Color accent, {
    Color? background,
    double minimumRatio = 4.5,
  }) => AppColors.accessibleForeground(
    accent,
    background ?? surface,
    light: onSurface,
    dark: onSurface,
    alternative: surface,
    minimumRatio: minimumRatio,
  );

  /// A varied accent scale derived from the active primary color.
  Color accent(int index) {
    const light = <Color>[
      SaviourPalette.shade600,
      SaviourPalette.shade500,
      SaviourPalette.shade700,
      SaviourPalette.shade400,
      SaviourPalette.shade800,
      SaviourPalette.shade300,
      SaviourPalette.shade900,
    ];
    const dark = <Color>[
      SaviourPalette.shade300,
      SaviourPalette.shade400,
      SaviourPalette.shade200,
      SaviourPalette.shade500,
      SaviourPalette.shade100,
      SaviourPalette.shade600,
      SaviourPalette.shade50,
    ];
    final tones = isDark ? dark : light;
    return tones[index % tones.length];
  }

  Color get success => accent(3);
  Color get warning => accent(1);
  Color get destructive => accent(6);
}

class PlatformTextStyles {
  const PlatformTextStyles._({
    required this.headlineMedium,
    required this.headlineSmall,
    required this.titleLarge,
    required this.titleMedium,
    required this.titleSmall,
    required this.bodyLarge,
    required this.bodyMedium,
    required this.bodySmall,
    required this.labelMedium,
    required this.labelLarge,
  });

  /// Builds the text styles using the native system typeface of [platform]:
  /// San Francisco on iOS/macOS, Segoe UI on Windows, Ubuntu on Linux and
  /// Roboto on Android/web/fuchsia — so text feels native instead of forcing a
  /// single font everywhere.
  factory PlatformTextStyles.forPlatform({
    required AppPlatform platform,
    required Color onSurface,
  }) {
    final family = _fontFamilyFor(platform);
    final fallback = _fontFallbackFor(platform);

    TextStyle style(double size) => TextStyle(
      fontFamily: family,
      fontFamilyFallback: fallback,
      color: onSurface,
      fontSize: size,
    );

    return PlatformTextStyles._(
      headlineMedium: style(28),
      headlineSmall: style(24),
      titleLarge: style(22),
      titleMedium: style(16),
      titleSmall: style(14),
      bodyLarge: style(16),
      bodyMedium: style(14),
      bodySmall: style(12),
      labelMedium: style(12),
      labelLarge: style(14),
    );
  }

  /// The native system font family for [platform].
  ///
  /// `CupertinoSystemText` is a Flutter engine alias that resolves to the San
  /// Francisco system font on Apple platforms. `null` falls back to the
  /// embedder default (Roboto on Android/web/fuchsia).
  static String? _fontFamilyFor(AppPlatform platform) => switch (platform) {
    AppPlatform.ios || AppPlatform.macos => 'CupertinoSystemText',
    AppPlatform.windows => 'Segoe UI',
    AppPlatform.linux => 'Ubuntu',
    AppPlatform.android || AppPlatform.web || AppPlatform.fuchsia => null,
  };

  /// Generic fallbacks for when the native face isn't installed (e.g. running a
  /// desktop target on a machine without Segoe UI / Ubuntu).
  static List<String>? _fontFallbackFor(AppPlatform platform) =>
      switch (platform) {
        AppPlatform.windows => const ['Roboto', 'Arial'],
        AppPlatform.linux => const ['Roboto', 'DejaVu Sans'],
        AppPlatform.ios ||
        AppPlatform.macos ||
        AppPlatform.android ||
        AppPlatform.web ||
        AppPlatform.fuchsia => null,
      };

  // Kept nullable to stay drop-in compatible with the many existing
  // `textTheme.x?.copyWith(...)` call sites, even though the factory always
  // assigns a concrete style.
  final TextStyle? headlineMedium;
  final TextStyle? headlineSmall;
  final TextStyle? titleLarge;
  final TextStyle? titleMedium;
  final TextStyle? titleSmall;
  final TextStyle? bodyLarge;
  final TextStyle? bodyMedium;
  final TextStyle? bodySmall;
  final TextStyle? labelMedium;
  final TextStyle? labelLarge;
}

class PlatformTheme extends InheritedWidget {
  const PlatformTheme({super.key, required this.data, required super.child});

  final PlatformThemeData data;

  static PlatformThemeData of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<PlatformTheme>();
    assert(scope != null, 'No PlatformTheme found in context');
    return scope!.data;
  }

  @override
  bool updateShouldNotify(PlatformTheme oldWidget) => data != oldWidget.data;
}

extension PlatformThemeContext on BuildContext {
  PlatformThemeData get platformTheme => PlatformTheme.of(this);
}
