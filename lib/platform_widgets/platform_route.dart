import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:saviour/providers/app_platform_provider.dart';

/// Resolves page motion to the current platform's navigation language.
abstract final class PlatformTransitions {
  static Duration durationFor(AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => const Duration(milliseconds: 400),
      AppPlatform.macos => const Duration(milliseconds: 180),
      AppPlatform.windows => const Duration(milliseconds: 220),
      AppPlatform.linux => const Duration(milliseconds: 250),
      AppPlatform.android ||
      AppPlatform.fuchsia => const Duration(milliseconds: 300),
      AppPlatform.web => const Duration(milliseconds: 180),
    };
  }

  static Duration reverseDurationFor(AppPlatform platform) {
    return switch (platform) {
      AppPlatform.ios => const Duration(milliseconds: 300),
      AppPlatform.macos => const Duration(milliseconds: 140),
      AppPlatform.windows => const Duration(milliseconds: 180),
      AppPlatform.linux => const Duration(milliseconds: 200),
      AppPlatform.android ||
      AppPlatform.fuchsia => const Duration(milliseconds: 300),
      AppPlatform.web => const Duration(milliseconds: 140),
    };
  }

  /// Builds the native transition for [platform].
  static Widget build<T>({
    required AppPlatform platform,
    required PageRoute<T> route,
    required BuildContext context,
    required Animation<double> animation,
    required Animation<double> secondaryAnimation,
    required Widget child,
  }) {
    return switch (platform) {
      AppPlatform.ios =>
        const cupertino.CupertinoPageTransitionsBuilder().buildTransitions(
          route,
          context,
          animation,
          secondaryAnimation,
          child,
        ),
      AppPlatform.macos => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        child: child,
      ),
      AppPlatform.windows => fluent.EntrancePageTransition(
        animation: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        ),
        child: child,
      ),
      AppPlatform.linux =>
        const material.FadeUpwardsPageTransitionsBuilder().buildTransitions(
          route,
          context,
          animation,
          secondaryAnimation,
          child,
        ),
      AppPlatform.android || AppPlatform.fuchsia =>
        const material.ZoomPageTransitionsBuilder().buildTransitions(
          route,
          context,
          animation,
          secondaryAnimation,
          child,
        ),
      AppPlatform.web => FadeTransition(
        opacity: CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
        child: child,
      ),
    };
  }

  /// Creates a declarative [Page] for use with `GoRoute.pageBuilder`.
  static Page<T> page<T>({
    required AppPlatform platform,
    required Widget child,
    LocalKey? key,
    String? name,
    Object? arguments,
    String? restorationId,
    bool maintainState = true,
    bool fullscreenDialog = false,
  }) {
    return _PlatformTransitionPage<T>(
      platform: platform,
      child: child,
      key: key,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
    );
  }
}

/// A platform-aware route for imperative `Navigator.push` navigation.
class PlatformPageRoute<T> extends PageRoute<T> {
  PlatformPageRoute({
    required this.platform,
    required this.builder,
    this.maintainState = true,
    super.settings,
    super.requestFocus,
    super.fullscreenDialog,
    super.allowSnapshotting = true,
    super.barrierDismissible = false,
    super.traversalEdgeBehavior,
    super.directionalTraversalEdgeBehavior,
  });

  final AppPlatform platform;
  final WidgetBuilder builder;

  @override
  final bool maintainState;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => PlatformTransitions.durationFor(platform);

  @override
  Duration get reverseTransitionDuration {
    return PlatformTransitions.reverseDurationFor(platform);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: builder(context),
    );
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return PlatformTransitions.build<T>(
      platform: platform,
      route: this,
      context: context,
      animation: animation,
      secondaryAnimation: secondaryAnimation,
      child: child,
    );
  }
}

class _PlatformTransitionPage<T> extends Page<T> {
  const _PlatformTransitionPage({
    required this.platform,
    required this.child,
    required this.maintainState,
    required this.fullscreenDialog,
    super.key,
    super.name,
    super.arguments,
    super.restorationId,
  });

  final AppPlatform platform;
  final Widget child;
  final bool maintainState;
  final bool fullscreenDialog;

  @override
  Route<T> createRoute(BuildContext context) {
    return PlatformPageRoute<T>(
      platform: platform,
      settings: this,
      maintainState: maintainState,
      fullscreenDialog: fullscreenDialog,
      builder: (_) => child,
    );
  }
}
