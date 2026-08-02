import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

ScrollPhysics platformScrollPhysics(BuildContext context) {
  return platformScrollPhysicsFor(context.platformTheme.platform);
}

ScrollPhysics platformScrollPhysicsFor(AppPlatform platform) {
  return switch (platform) {
    AppPlatform.ios || AppPlatform.macos => const BouncingScrollPhysics(),
    AppPlatform.android ||
    AppPlatform.windows ||
    AppPlatform.linux ||
    AppPlatform.web ||
    AppPlatform.fuchsia => const ClampingScrollPhysics(),
  };
}

/// Adds the current platform's native scrollbar around [child].
///
/// Android and Fuchsia rely on their native transient scroll affordances, so
/// they remain undecorated unless [showOnMobile] is set.
class PlatformScrollbar extends ConsumerWidget {
  const PlatformScrollbar({
    super.key,
    required this.child,
    this.controller,
    this.platform,
    this.showOnMobile = false,
  });

  final Widget child;
  final ScrollController? controller;

  /// Overrides the detected platform. Useful from [PlatformScrollBehavior],
  /// which already owns an explicit platform decision.
  final AppPlatform? platform;

  final bool showOnMobile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectivePlatform =
        platform ??
        ref.watch(appPlatformProvider) ??
        context.platformTheme.platform;
    return switch (effectivePlatform) {
      AppPlatform.ios => cupertino.CupertinoScrollbar(
        controller: controller,
        child: child,
      ),
      AppPlatform.macos => macos.MacosScrollbar(
        controller: controller,
        child: child,
      ),
      AppPlatform.windows => fluent.Scrollbar(
        controller: controller,
        child: child,
      ),
      AppPlatform.linux || AppPlatform.web => material.Scrollbar(
        controller: controller,
        child: child,
      ),
      AppPlatform.android || AppPlatform.fuchsia =>
        showOnMobile
            ? material.Scrollbar(controller: controller, child: child)
            : child,
    };
  }
}

/// Native scrolling policy for a whole app or a [ScrollConfiguration] subtree.
class PlatformScrollBehavior extends ScrollBehavior {
  const PlatformScrollBehavior({required this.platform});

  final AppPlatform platform;

  @override
  TargetPlatform getPlatform(BuildContext context) {
    return switch (platform) {
      AppPlatform.android => TargetPlatform.android,
      AppPlatform.ios => TargetPlatform.iOS,
      AppPlatform.windows => TargetPlatform.windows,
      AppPlatform.linux => TargetPlatform.linux,
      AppPlatform.macos => TargetPlatform.macOS,
      AppPlatform.fuchsia => TargetPlatform.fuchsia,
      // Preserve the browser's host platform for gestures such as trackpad
      // scrolling while using the web presentation branches elsewhere.
      AppPlatform.web => defaultTargetPlatform,
    };
  }

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return platformScrollPhysicsFor(platform);
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) == Axis.horizontal) return child;
    return PlatformScrollbar(
      platform: platform,
      controller: details.controller,
      child: child,
    );
  }

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return switch (platform) {
      AppPlatform.android || AppPlatform.fuchsia =>
        const material.MaterialScrollBehavior().buildOverscrollIndicator(
          context,
          child,
          details,
        ),
      AppPlatform.ios ||
      AppPlatform.macos ||
      AppPlatform.windows ||
      AppPlatform.linux ||
      AppPlatform.web => child,
    };
  }

  @override
  bool shouldNotify(covariant PlatformScrollBehavior oldDelegate) {
    return platform != oldDelegate.platform;
  }
}
