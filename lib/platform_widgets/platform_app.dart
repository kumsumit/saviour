import 'package:saviour/app_theme.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:yaru/yaru.dart' as yaru;

/// The native application root for the active operating system.
///
/// Besides choosing the correct app shell, this installs the matching native
/// theme and localization delegates. Platform controls must live below this
/// widget; wrapping them in a MaterialApp alone leaves Fluent, Cupertino and
/// macOS controls without the inherited data their current implementations
/// require.
class PlatformApp extends ConsumerWidget {
  const PlatformApp({
    super.key,
    required this.home,
    required this.title,
    this.seedColor = SaviourPalette.seed,
    this.debugShowCheckedModeBanner = false,
  });

  final Widget home;
  final String title;
  final Color seedColor;
  final bool debugShowCheckedModeBanner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    Widget platformThemeBuilder(BuildContext context, Widget? child) {
      return PlatformTheme(
        data: PlatformThemeData.forPlatform(
          platform: platform,
          brightness: MediaQuery.platformBrightnessOf(context),
          seed: seedColor,
        ),
        child: child ?? const SizedBox.shrink(),
      );
    }

    return switch (platform) {
      AppPlatform.ios => cupertino.CupertinoApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        theme: cupertino.CupertinoThemeData(primaryColor: seedColor),
        localizationsDelegates: const [
          material.DefaultMaterialLocalizations.delegate,
          cupertino.DefaultCupertinoLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        builder: platformThemeBuilder,
        home: home,
      ),
      AppPlatform.macos => macos.MacosApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        themeMode: material.ThemeMode.system,
        theme: macos.MacosThemeData(
          brightness: Brightness.light,
          primaryColor: seedColor,
        ),
        darkTheme: macos.MacosThemeData(
          brightness: Brightness.dark,
          primaryColor: seedColor,
        ),
        builder: platformThemeBuilder,
        home: home,
      ),
      AppPlatform.windows => fluent.FluentApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        themeMode: material.ThemeMode.system,
        theme: fluent.FluentThemeData(
          brightness: Brightness.light,
          accentColor: _fluentAccent(seedColor),
        ),
        darkTheme: fluent.FluentThemeData(
          brightness: Brightness.dark,
          accentColor: _fluentAccent(seedColor),
        ),
        builder: platformThemeBuilder,
        home: home,
      ),
      AppPlatform.linux => material.MaterialApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        themeMode: material.ThemeMode.system,
        theme: _yaruTheme(seedColor, Brightness.light),
        darkTheme: _yaruTheme(seedColor, Brightness.dark),
        builder: platformThemeBuilder,
        home: home,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.MaterialApp(
        title: title,
        debugShowCheckedModeBanner: debugShowCheckedModeBanner,
        themeMode: material.ThemeMode.system,
        theme: _materialTheme(seedColor, Brightness.light),
        darkTheme: _materialTheme(seedColor, Brightness.dark),
        builder: platformThemeBuilder,
        home: home,
      ),
    };
  }
}

material.ThemeData _materialTheme(Color seed, Brightness brightness) {
  return material.ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: brightness == Brightness.dark
        ? AppColors.darkScheme(seed)
        : AppColors.lightScheme(seed),
  );
}

material.ThemeData _yaruTheme(Color seed, Brightness brightness) {
  final native = const yaru.YaruThemeData(
    variant: yaru.YaruVariant.red,
    useMaterial3: true,
  );
  return (brightness == Brightness.dark ? native.darkTheme : native.theme)
      .copyWith(
        colorScheme: brightness == Brightness.dark
            ? AppColors.darkScheme(seed)
            : AppColors.lightScheme(seed),
      );
}

fluent.AccentColor _fluentAccent(Color color) {
  return fluent.AccentColor.swatch(<String, Color>{'normal': color});
}
