import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_platform_provider.g.dart';

/// The platforms the app can run on.
///
/// This is the single source of truth for
/// "what platform are we on".
enum AppPlatform { android, ios, windows, linux, macos, web, fuchsia }

/// Current running platform.
@riverpod
AppPlatform appPlatform(Ref ref) {
  if (kIsWeb) return AppPlatform.web;

  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return AppPlatform.android;

    case TargetPlatform.iOS:
      return AppPlatform.ios;

    case TargetPlatform.windows:
      return AppPlatform.windows;

    case TargetPlatform.linux:
      return AppPlatform.linux;

    case TargetPlatform.macOS:
      return AppPlatform.macos;

    case TargetPlatform.fuchsia:
      return AppPlatform.fuchsia;
  }
}

/// Convenience extensions.
extension AppPlatformX on AppPlatform {
  bool get isAndroid => this == AppPlatform.android;

  bool get isIOS => this == AppPlatform.ios;

  bool get isWeb => this == AppPlatform.web;

  bool get isMobileOS => this == AppPlatform.android || this == AppPlatform.ios;

  bool get isDesktopOS =>
      this == AppPlatform.windows ||
      this == AppPlatform.linux ||
      this == AppPlatform.macos;
}
