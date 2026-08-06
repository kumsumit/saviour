import 'package:flutter/material.dart';

/// The only color source for Saviour. Every token belongs to the tonal family
/// generated from the brand red `#B51635`; even near-neutral surfaces retain a
/// subtle red tint so the product stays intentionally monochromatic.
abstract final class SaviourPalette {
  static const Color seed = Color(0xFFB51635);
  static const Color shade50 = Color(0xFFFFF6F8);
  static const Color shade100 = Color(0xFFFDE8ED);
  static const Color shade200 = Color(0xFFF8C7D2);
  static const Color shade300 = Color(0xFFF099AD);
  static const Color shade400 = Color(0xFFE46782);
  static const Color shade500 = Color(0xFFD23A5D);
  static const Color shade600 = seed;
  static const Color shade700 = Color(0xFF94112C);
  static const Color shade800 = Color(0xFF731022);
  static const Color shade900 = Color(0xFF4E0B17);
  static const Color shade950 = Color(0xFF2B060D);
  static const Color transparent = Color(0x00000000);
}

abstract final class AppColors {
  static const Color defaultSeed = SaviourPalette.seed;

  static ColorScheme lightScheme([Color? seed]) =>
      ColorScheme.fromSeed(
        seedColor: seed ?? defaultSeed,
        brightness: Brightness.light,
        surface: SaviourPalette.shade50,
      ).copyWith(
        primary: seed ?? defaultSeed,
        onPrimary: SaviourPalette.shade50,
        primaryContainer: SaviourPalette.shade100,
        onPrimaryContainer: SaviourPalette.shade900,
        secondary: SaviourPalette.shade500,
        onSecondary: SaviourPalette.shade50,
        secondaryContainer: SaviourPalette.shade200,
        onSecondaryContainer: SaviourPalette.shade900,
        tertiary: SaviourPalette.shade400,
        error: SaviourPalette.shade700,
        outline: SaviourPalette.shade300,
        outlineVariant: SaviourPalette.shade200,
        surfaceContainerHighest: SaviourPalette.shade100,
        onSurface: SaviourPalette.shade950,
        onSurfaceVariant: SaviourPalette.shade800,
      );

  static ColorScheme darkScheme([Color? seed]) =>
      ColorScheme.fromSeed(
        seedColor: seed ?? defaultSeed,
        brightness: Brightness.dark,
        surface: SaviourPalette.shade950,
      ).copyWith(
        primary: SaviourPalette.shade300,
        onPrimary: SaviourPalette.shade950,
        primaryContainer: SaviourPalette.shade800,
        onPrimaryContainer: SaviourPalette.shade100,
        secondary: SaviourPalette.shade400,
        onSecondary: SaviourPalette.shade950,
        secondaryContainer: SaviourPalette.shade800,
        onSecondaryContainer: SaviourPalette.shade100,
        tertiary: SaviourPalette.shade500,
        error: SaviourPalette.shade400,
        outline: SaviourPalette.shade600,
        outlineVariant: SaviourPalette.shade800,
        surfaceContainerHighest: SaviourPalette.shade900,
        onSurface: SaviourPalette.shade50,
        onSurfaceVariant: SaviourPalette.shade200,
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

  static const Color teal50 = SaviourPalette.shade50;
  static const Color teal100 = SaviourPalette.shade100;
  static const Color teal200 = SaviourPalette.shade200;
  static const Color teal300 = SaviourPalette.shade300;
  static const Color teal400 = SaviourPalette.shade400;
  static const Color teal500 = SaviourPalette.shade500;
  static const Color teal600 = SaviourPalette.shade600;
  static const Color teal700 = SaviourPalette.shade700;
  static const Color teal800 = SaviourPalette.shade800;
  static const Color teal900 = SaviourPalette.shade900;

  static AccentScale accentScale(Color seed, {required bool dark}) => dark
      ? const AccentScale(
          lightest: SaviourPalette.shade950,
          lighter: SaviourPalette.shade900,
          light: SaviourPalette.shade700,
          normal: SaviourPalette.shade400,
          dark: SaviourPalette.shade300,
          darker: SaviourPalette.shade200,
          darkest: SaviourPalette.shade50,
        )
      : const AccentScale(
          lightest: SaviourPalette.shade50,
          lighter: SaviourPalette.shade100,
          light: SaviourPalette.shade300,
          normal: SaviourPalette.shade600,
          dark: SaviourPalette.shade700,
          darker: SaviourPalette.shade800,
          darkest: SaviourPalette.shade950,
        );

  static Color foregroundFor(
    Color background, {
    required Color light,
    required Color dark,
    required Color alternative,
    double minimumRatio = 3,
  }) {
    final candidate = background.computeLuminance() > .179 ? dark : light;
    return _contrastRatio(background, candidate) >= minimumRatio
        ? candidate
        : alternative;
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
    return foregroundFor(
      background,
      light: light,
      dark: dark,
      alternative: alternative,
      minimumRatio: minimumRatio,
    );
  }

  static double _contrastRatio(Color a, Color b) {
    final first = a.computeLuminance();
    final second = b.computeLuminance();
    final lighter = first > second ? first : second;
    final darker = first > second ? second : first;
    return (lighter + .05) / (darker + .05);
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
