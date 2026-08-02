import 'package:flutter/widgets.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/material.dart' show Icons;
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/platform_widgets/platform_app.dart';
import 'package:saviour/platform_widgets/platform_badge.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_navigation.dart';
import 'package:saviour/platform_widgets/platform_scaffold.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/providers/app_platform_provider.dart';

void main() {
  for (final platform in AppPlatform.values) {
    testWidgets('builds the ${platform.name} native widget tree', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appPlatformProvider.overrideWithValue(platform)],
          child: PlatformApp(
            title: 'Platform test',
            home: PlatformScaffold(
              body: Center(
                child: PlatformCard(
                  child: GlassSurface(
                    child: PlatformBadge(
                      label: const Text('3'),
                      child: PlatformButton(
                        onPressed: _noop,
                        child: const Text('Continue'),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Continue'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // macos_ui defers its native visual-effect registration with Timer.run.
      // Dispose the tree and advance fake time so the plugin leaves no pending
      // registration timer behind in widget tests.
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }

  testWidgets('uses Fluent adaptive NavigationView on Windows', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appPlatformProvider.overrideWithValue(AppPlatform.windows)],
        child: PlatformApp(
          title: 'Navigation test',
          home: PlatformNavigation(
            items: const [
              PlatformNavigationItem(icon: Icons.home, label: 'Home'),
              PlatformNavigationItem(icon: Icons.settings, label: 'Settings'),
            ],
            selectedIndex: 0,
            onSelected: _onSelected,
            body: const Center(child: Text('Page content')),
          ),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 1));
    expect(find.byType(fluent.NavigationView), findsOneWidget);
    expect(find.text('Page content'), findsOneWidget);
  });
}

void _noop() {}

void _onSelected(int _) {}
