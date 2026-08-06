import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/features/home/dashboard.dart';
import 'package:saviour/features/home/donar_profile.dart' as donor_profile;
import 'package:saviour/features/home/donation_history.dart' as history;
import 'package:saviour/features/home/drawer.dart' as account_drawer;
import 'package:saviour/features/home/elligibility_tracker.dart' as eligibility;
import 'package:saviour/features/home/emergency_sos.dart' as emergency;
import 'package:saviour/features/home/health_insights.dart' as insights;
import 'package:saviour/features/home/inventory_management.dart' as inventory;
import 'package:saviour/features/home/notification.dart' as notifications;
import 'package:saviour/features/home/profile_screen.dart' as profile;
import 'package:saviour/features/home/rare_donar_screen.dart' as rare_donors;
import 'package:saviour/features/home/recepient_form_screen.dart'
    as recipient_form;
import 'package:saviour/features/home/reciepient_details.dart' as recipient;
import 'package:saviour/features/home/request_details.dart' as request_details;
import 'package:saviour/features/home/settings.dart' as settings;
import 'package:saviour/features/home/vital_reserve.dart' as camps;
import 'package:saviour/platform_widgets/platform_app.dart';
import 'package:saviour/providers/app_platform_provider.dart';

void main() {
  for (final platform in AppPlatform.values) {
    testWidgets('dashboard opens on ${platform.name}', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appPlatformProvider.overrideWithValue(platform)],
          child: const PlatformApp(
            title: 'Saviour test',
            home: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(find.text('Welcome back, Sarah'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }

  final featureScreens = <(String, Widget)>[
    ('complete profile', const donor_profile.CompleteProfileScreen()),
    ('donation history', const history.HomeScreen()),
    ('account drawer', const account_drawer.AccountDrawer()),
    ('eligibility', const eligibility.EligibilityScreen()),
    ('emergency SOS', const emergency.EmergencySosScreen()),
    ('health insights', const insights.HealthInsightsScreen()),
    ('inventory', const inventory.InventoryHomePage()),
    ('notifications', const notifications.NotificationsScreen()),
    ('profile', const profile.ProfileScreen()),
    ('rare donors', const rare_donors.RareDonorPage()),
    ('recipient form', const recipient_form.RecipientFormScreen()),
    ('recipient details', const recipient.RecipientDetailsScreen()),
    ('request details', const request_details.VitalReserveScreen()),
    ('settings', const settings.SettingsScreen()),
    ('camps', const camps.VitalReserveHomeScreen()),
  ];

  for (final (name, screen) in featureScreens) {
    testWidgets('$name opens inside the iOS native app shell', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [appPlatformProvider.overrideWithValue(AppPlatform.ios)],
          child: PlatformApp(title: 'Saviour test', home: screen),
        ),
      );
      await tester.pump(const Duration(milliseconds: 1));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(milliseconds: 1));
    });
  }
}
