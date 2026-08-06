import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/platform_widgets/platform_overlay.dart';
import 'package:saviour/platform_widgets/platform_route.dart';
import 'package:saviour/providers/app_platform_provider.dart';

abstract final class FeatureActions {
  static AppPlatform platformOf(BuildContext context) =>
      ProviderScope.containerOf(context).read(appPlatformProvider);

  static void notice(BuildContext context, String message) {
    showPlatformSnackbar(
      context: context,
      platform: platformOf(context),
      message: message,
    );
  }

  static Future<void> confirm({
    required BuildContext context,
    required String title,
    required String message,
    required String actionLabel,
    required VoidCallback onConfirmed,
  }) => showPlatformDialog(
    context: context,
    platform: platformOf(context),
    title: title,
    message: message,
    actions: [
      const PlatformDialogAction(label: 'Cancel'),
      PlatformDialogAction(
        label: actionLabel,
        isDefault: true,
        onPressed: onConfirmed,
      ),
    ],
  );

  static Future<T?> open<T>(BuildContext context, Widget screen) =>
      Navigator.of(context).push<T>(
        PlatformPageRoute<T>(
          platform: platformOf(context),
          builder: (_) => screen,
        ),
      );

  static void replaceAll(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      PlatformPageRoute<void>(
        platform: platformOf(context),
        builder: (_) => screen,
      ),
      (_) => false,
    );
  }
}
