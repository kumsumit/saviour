import 'package:flutter/material.dart';

/// Seed-driven color helpers for the Chumble design system.
///
/// Theme builders should use [lightScheme] and [darkScheme] with the user's
/// selected seed color. Static color getters remain as the default teal palette
/// for call sites that are not yet seed-aware.
abstract final class AppColors {
  static const Color defaultSeed =Color(0xFFB0102A); //Color(0xFF00796B)//Color(0xFF7B2FF7);

  static ColorScheme lightScheme([Color? seed]) => ColorScheme.fromSeed(
    seedColor: seed ?? defaultSeed,
    brightness: Brightness.light,
  );

  static ColorScheme darkScheme([Color? seed]) => ColorScheme.fromSeed(
    seedColor: seed ?? defaultSeed,
    brightness: Brightness.dark,
  );

  static final ColorScheme _light = lightScheme();
  static final ColorScheme _dark = darkScheme();

  static Color get primary => _light.primary;
  static Color get primaryLight => _dark.primary;
  static Color get secondary => _light.secondary;

  static Color get lightSurface => _light.surface;
  static Color get lightSurfaceVariant => _light.surfaceContainerHighest;
  static Color get darkSurface => _dark.surface;
  static Color get darkSurfaceVariant => _dark.surfaceContainerHighest;

  static Color get lightTextPrimary => _light.onSurface;
  static Color get lightTextSecondary => _light.onSurfaceVariant;
  static Color get darkTextPrimary => _dark.onSurface;
  static Color get darkTextSecondary => _dark.onSurfaceVariant;

  static Color get lightBorder => _light.outline;
  static Color get darkBorder => _dark.outline;

  static Color get teal50 => _tone(defaultSeed, 0.95);
  static Color get teal100 => _tone(defaultSeed, 0.88);
  static Color get teal200 => _tone(defaultSeed, 0.76);
  static Color get teal300 => _tone(defaultSeed, 0.66);
  static Color get teal400 => _tone(defaultSeed, 0.56);
  static Color get teal500 => _tone(defaultSeed, 0.48);
  static Color get teal600 => _tone(defaultSeed, 0.42);
  static Color get teal700 => defaultSeed;
  static Color get teal800 => _tone(defaultSeed, 0.28);
  static Color get teal900 => _tone(defaultSeed, 0.18);

  static AccentScale accentScale(Color seed, {required bool dark}) {
    final base = HSLColor.fromColor(seed);
    Color tone(double lightness) => base
        .withSaturation((base.saturation * 0.95).clamp(0.35, 0.82))
        .withLightness(lightness)
        .toColor();

    return dark
        ? AccentScale(
            lightest: tone(0.18),
            lighter: tone(0.26),
            light: tone(0.52),
            normal: tone(0.68),
            dark: tone(0.76),
            darker: tone(0.86),
            darkest: tone(0.94),
          )
        : AccentScale(
            lightest: tone(0.95),
            lighter: tone(0.88),
            light: tone(0.58),
            normal: tone(0.40),
            dark: tone(0.30),
            darker: tone(0.22),
            darkest: tone(0.16),
          );
  }

  /// Picks [light] or [dark] foreground based on the perceived luminance of
  /// [background]. Falls back to [alternative] when neither meets the minimum.
  static Color foregroundFor(
    Color background, {
    required Color light,
    required Color dark,
    required Color alternative,
    double minimumRatio = 3.0,
  }) {
    final candidate = _isLight(background) ? dark : light;
    if (_contrastRatio(background, candidate) >= minimumRatio) {
      return candidate;
    }
    return alternative;
  }

  static Color accessibleForeground(
    Color foreground,
    Color background, {
    required Color light,
    required Color dark,
    required Color alternative,
    double minimumRatio = 4.5,
  }) {
    if (_contrastRatio(background, foreground) >= minimumRatio) {
      return foreground;
    }
    final candidate = _isLight(background) ? dark : light;
    if (_contrastRatio(background, candidate) >= minimumRatio) {
      return candidate;
    }
    return alternative;
  }

  static Color _tone(Color color, double lightness) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withSaturation((hsl.saturation * 0.95).clamp(0.35, 0.82))
        .withLightness(lightness)
        .toColor();
  }

  static bool _isLight(Color color) => _relativeLuminance(color) > 0.179;

  static double _relativeLuminance(Color color) {
    double linearise(double c) => c <= 0.04045
        ? c / 12.92
        : ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055) * ((c + 0.055) / 1.055);
    final r = linearise(color.r);
    final g = linearise(color.g);
    final b = linearise(color.b);
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }

  static double _contrastRatio(Color a, Color b) {
    final la = _relativeLuminance(a);
    final lb = _relativeLuminance(b);
    final lighter = la > lb ? la : lb;
    final darker = la > lb ? lb : la;
    return (lighter + 0.05) / (darker + 0.05);
  }
}

class AccentScale {
  const AccentScale({
    required this.lightest,
    required this.lighter,
    required this.light,
    required this.normal,
    required this.dark,
    required this.darker,
    required this.darkest,
  });

  final Color lightest;
  final Color lighter;
  final Color light;
  final Color normal;
  final Color dark;
  final Color darker;
  final Color darkest;
}
