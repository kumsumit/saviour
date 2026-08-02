import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart';

import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_app_bar.dart';

class PlatformScaffold extends ConsumerWidget {
  final Widget body;
  final Color? backgroundColor;

  /// A platform-aware bar that is rendered into the correct native slot for the
  /// current platform. The typed slots below override it per platform when a
  /// fully custom bar is required.
  final PlatformAppBar? appBar;

  // Material
  final PreferredSizeWidget? materialAppBar;

  // Cupertino
  final ObstructingPreferredSizeWidget? cupertinoNavigationBar;

  // macOS
  final ToolBar? macosToolbar;

  // Fluent UI
  final Widget? fluentHeader;

  final Widget? floatingActionButton;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.backgroundColor,
    this.appBar,
    this.materialAppBar,
    this.cupertinoNavigationBar,
    this.macosToolbar,
    this.fluentHeader,
    this.floatingActionButton,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final content = backgroundColor == null
        ? body
        : ColoredBox(color: backgroundColor!, child: body);

    switch (platform) {
      case AppPlatform.ios:
        return CupertinoPageScaffold(
          backgroundColor: backgroundColor,
          navigationBar:
              cupertinoNavigationBar ?? appBar?.buildCupertino(context),
          child: content,
        );

      case AppPlatform.macos:
        return MacosScaffold(
          toolBar: macosToolbar ?? appBar?.buildMacosToolBar(context),
          children: [ContentArea(builder: (context, _) => content)],
        );

      case AppPlatform.windows:
        return fluent.NavigationView(
          titleBar: fluentHeader ?? appBar?.buildFluentHeader(context),
          content: content,
        );

      case AppPlatform.linux:
        // Yaru's scaffold implementation is the themed Material scaffold.
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: materialAppBar ?? appBar?.buildLinux(context),
          body: content,
          floatingActionButton: floatingActionButton,
        );

      case AppPlatform.android:
      case AppPlatform.web:
      case AppPlatform.fuchsia:
        return Scaffold(
          backgroundColor: backgroundColor,
          appBar: materialAppBar ?? appBar?.buildMaterial(context),
          body: content,
          floatingActionButton: floatingActionButton,
        );
    }
  }
}
