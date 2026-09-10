import 'package:saviour/app_theme.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/features/auth/login.dart';
import 'package:saviour/features/home/donation_history.dart' as history;
import 'package:saviour/features/home/elligibility_tracker.dart' as eligibility;
import 'package:saviour/features/home/emergency_sos.dart' as emergency;
import 'package:saviour/features/home/health_insights.dart' as insights;
import 'package:saviour/features/home/inventory_management.dart' as inventory;
import 'package:saviour/features/home/rare_donar_screen.dart' as rare_donors;
import 'package:saviour/features/home/settings.dart' as settings;
import 'package:saviour/platform_widgets/platform_badge.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_controls.dart';
import 'package:saviour/platform_widgets/platform_form.dart';
import 'package:saviour/platform_widgets/platform_icon_button.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_navigation.dart';
import 'package:saviour/platform_widgets/platform_overlay.dart';
import 'package:saviour/platform_widgets/platform_route.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/services/saviour_api.dart';

class SaviourHomeShell extends ConsumerStatefulWidget {
  const SaviourHomeShell({super.key, this.initialIndex = 0});

  final int initialIndex;

  @override
  ConsumerState<SaviourHomeShell> createState() => _SaviourHomeShellState();
}

class _SaviourHomeShellState extends ConsumerState<SaviourHomeShell> {
  late int _index = widget.initialIndex.clamp(0, 3);
  bool _available =
      SaviourApi.instance.currentUser?['available'] as bool? ?? false;

  @override
  void initState() {
    super.initState();
    SaviourApi.instance.revision.addListener(_updated);
  }

  void _updated() => setState(() {
    _available =
        SaviourApi.instance.currentUser?['available'] as bool? ?? false;
  });
  @override
  void dispose() {
    SaviourApi.instance.revision.removeListener(_updated);
    super.dispose();
  }

  static const _items = [
    PlatformNavigationItem(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
    ),
    PlatformNavigationItem(
      icon: Icons.water_drop_outlined,
      selectedIcon: Icons.water_drop,
      label: 'Requests',
    ),
    PlatformNavigationItem(
      icon: Icons.location_on_outlined,
      selectedIcon: Icons.location_on,
      label: 'Camps',
    ),
    PlatformNavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final pages = [
      _DashboardPage(
        onCreateRequest: _showRequestFlow,
        onOpenRequests: () => setState(() => _index = 1),
        onOpenCamps: () => setState(() => _index = 2),
        onNotifications: _showNotifications,
      ),
      _RequestsPage(onCreateRequest: _showRequestFlow),
      const _CampsPage(),
      _ProfilePage(
        available: _available,
        onAvailabilityChanged: _setAvailability,
        onSignOut: _signOut,
      ),
    ];

    return ColoredBox(
      color: theme.surface,
      child: SafeArea(
        child: PlatformNavigation(
          items: _items,
          selectedIndex: _index,
          onSelected: (index) => setState(() => _index = index),
          backgroundColor: theme.surface,
          header: Padding(
            padding: const EdgeInsets.all(16),
            child: Image.asset('logo/logo.png', width: 40, height: 40),
          ),
          footer: PlatformIconButton(
            icon: Icons.logout,
            tooltip: 'Sign out',
            onPressed: _signOut,
          ),
          body: IndexedStack(index: _index, children: pages),
        ),
      ),
    );
  }

  Future<void> _showRequestFlow() => showPlatformSheet<void>(
    context: context,
    platform: ref.read(appPlatformProvider),
    builder: (_) => const CreateBloodRequestSheet(),
  );

  Future<void> _showNotifications() => showPlatformSheet<void>(
    context: context,
    platform: ref.read(appPlatformProvider),
    builder: (_) => const NotificationsPanel(),
  );

  Future<void> _setAvailability(bool value) async {
    final previous = _available;
    setState(() => _available = value);
    try {
      await SaviourApi.instance.setAvailability(value);
      if (mounted) {
        _message(
          context,
          ref,
          value
              ? 'You are now available for compatible alerts.'
              : 'Donor alerts are paused.',
        );
      }
    } on SaviourApiException catch (error) {
      if (!mounted) return;
      setState(() => _available = previous);
      _message(context, ref, error.message);
    }
  }

  Future<void> _signOut() => showPlatformDialog(
    context: context,
    platform: ref.read(appPlatformProvider),
    title: 'Sign out of Saviour?',
    message: 'You can sign back in anytime with your verified mobile number.',
    actions: [
      const PlatformDialogAction(label: 'Cancel'),
      PlatformDialogAction(
        label: 'Sign out',
        isDefault: true,
        onPressed: () {
          SaviourApi.instance.signOut();
          Navigator.of(context).pushAndRemoveUntil(
            PlatformPageRoute<void>(
              platform: ref.read(appPlatformProvider),
              builder: (_) => const LoginScreen(),
            ),
            (_) => false,
          );
        },
      ),
    ],
  );
}

class _DashboardPage extends ConsumerWidget {
  const _DashboardPage({
    required this.onCreateRequest,
    required this.onOpenRequests,
    required this.onOpenCamps,
    required this.onNotifications,
  });
  final VoidCallback onCreateRequest,
      onOpenRequests,
      onOpenCamps,
      onNotifications;
  @override
  Widget build(BuildContext context, WidgetRef ref) => _ServerView(
    load: SaviourApi.instance.dashboard,
    builder: (data) {
      final profile = data['profile'] as Map;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            eyebrow: 'SAVIOUR',
            title: 'Welcome, ${profile['name'] ?? profile['phone']}',
            subtitle: 'Your donation network',
            action: PlatformIconButton(
              icon: Icons.notifications_none,
              tooltip: 'Notifications (${data['unreadNotifications']})',
              onPressed: onNotifications,
            ),
          ),
          const SizedBox(height: 24),
          _EmergencyCard(onPressed: onCreateRequest),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Urgent requests',
            actionLabel: 'View all',
            onPressed: onOpenRequests,
          ),
          for (final item in data['urgentRequests'] as List? ?? [])
            _serverRequestCard(item as Map),
          if ((data['urgentRequests'] as List? ?? []).isEmpty)
            const Text('No urgent requests.'),
          const SizedBox(height: 24),
          _SectionHeader(
            title: 'Upcoming camps',
            actionLabel: 'View all',
            onPressed: onOpenCamps,
          ),
          for (final item in data['upcomingCamps'] as List? ?? [])
            _serverCampCard(context, ref, item as Map),
          const SizedBox(height: 24),
          Text(
            'Donations: ${profile['donationCount']} • Litres donated: ${profile['litresDonated']} • Lives helped: ${profile['livesHelped']}',
          ),
        ],
      );
    },
  );
}

class _EmergencyCard extends StatelessWidget {
  const _EmergencyCard({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, SaviourPalette.shade900],
        ),
        borderRadius: BorderRadius.circular(theme.surfaceRadius + 10),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 560;
          final copy = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'NEED BLOOD URGENTLY?',
                style: TextStyle(
                  color: SaviourPalette.shade50,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .8,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Broadcast a verified request to nearby donors.',
                style: TextStyle(
                  color: SaviourPalette.shade50,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
              ),
              const SizedBox(height: 9),
              const Text(
                'We’ll prioritize compatible, available donors and keep sensitive details private.',
                style: TextStyle(color: SaviourPalette.shade50, height: 1.45),
              ),
              const SizedBox(height: 18),
              PlatformButton.icon(
                icon: Icons.campaign_outlined,
                accentColor: SaviourPalette.shade50,
                onPressed: onPressed,
                label: Text(
                  'Create emergency request',
                  style: TextStyle(color: theme.primary),
                ),
              ),
            ],
          );
          if (compact) return copy;
          return Row(
            children: [
              Expanded(child: copy),
              const SizedBox(width: 24),
              const Icon(
                Icons.bloodtype,
                size: 112,
                color: SaviourPalette.shade50,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RequestsPage extends StatefulWidget {
  const _RequestsPage({required this.onCreateRequest});
  final VoidCallback onCreateRequest;
  @override
  State<_RequestsPage> createState() => _RequestsPageState();
}

class _RequestsPageState extends State<_RequestsPage> {
  final _search = TextEditingController();
  bool _urgent = false;
  String _query = '';
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            PlatformButton(
              onPressed: widget.onCreateRequest,
              child: const Text('New blood request'),
            ),
            PlatformSearchField(
              controller: _search,
              placeholder: 'Search hospital or blood group',
              onChanged: (v) => setState(() => _query = v),
              onClear: () => setState(() => _query = ''),
            ),
            Row(
              children: [
                const Text('Urgent only'),
                PlatformSwitch(
                  value: _urgent,
                  onChanged: (v) => setState(() => _urgent = v),
                ),
              ],
            ),
          ],
        ),
      ),
      Expanded(
        child: _ServerView(
          key: ValueKey('$_query/$_urgent'),
          load: () async {
            final items = <Map<String, Object?>>[];
            while (true) {
              final page = await SaviourApi.instance.requests(
                query: _query,
                urgentOnly: _urgent,
                offset: items.length,
              );
              items.addAll(page);
              if (page.length < 50) break;
            }
            return {'items': items};
          },
          builder: (data) => Column(
            children: [
              if ((data['items'] as List).isEmpty)
                const Text('No matching requests.'),
              for (final item in data['items'] as List)
                _serverRequestCard(item as Map),
            ],
          ),
        ),
      ),
    ],
  );
}

Widget _serverRequestCard(Map item) => Padding(
  padding: const EdgeInsets.only(bottom: 12),
  child: _RequestCard(
    id: item['id'] as String,
    bloodGroup: item['bloodGroup'] as String,
    hospital: item['hospital'] as String,
    detail: item['component'] as String,
    units: item['units'] as int,
    urgent: item['urgent'] as bool,
  ),
);

class _RequestCard extends ConsumerWidget {
  const _RequestCard({
    required this.bloodGroup,
    required this.id,
    required this.hospital,
    required this.detail,
    required this.units,
    this.urgent = false,
  });

  final String id;
  final String bloodGroup;
  final String hospital;
  final String detail;
  final int units;
  final bool urgent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.platformTheme;
    return PlatformCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: theme.primary.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(theme.surfaceRadius),
            ),
            child: Text(
              bloodGroup,
              style: theme.text.titleMedium?.copyWith(
                color: theme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hospital,
                        style: theme.text.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    if (urgent)
                      const PlatformBadge(
                        label: Text('URGENT'),
                        severity: PlatformBadgeSeverity.error,
                      ),
                  ],
                ),
                const SizedBox(height: 5),
                Text(
                  '$detail • $units ${units == 1 ? 'unit' : 'units'}',
                  style: theme.text.bodySmall?.copyWith(
                    color: theme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          PlatformButton(
            kind: PlatformButtonKind.text,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
            onPressed: () => showPlatformDialog(
              context: context,
              platform: ref.read(appPlatformProvider),
              title: '$bloodGroup blood request',
              message:
                  '$hospital needs $units ${units == 1 ? 'unit' : 'units'}. Your contact details stay hidden until you confirm.',
              actions: [
                const PlatformDialogAction(label: 'Not now'),
                PlatformDialogAction(
                  label: 'I can donate',
                  isDefault: true,
                  onPressed: () => _serverAction(
                    context,
                    ref,
                    () => SaviourApi.instance.respondToRequest(id),
                    'Your response has been recorded.',
                  ),
                ),
              ],
            ),
            child: const Text('View'),
          ),
        ],
      ),
    );
  }
}

class _CampsPage extends ConsumerWidget {
  const _CampsPage();
  @override
  Widget build(BuildContext context, WidgetRef ref) => _ServerView(
    load: () async => {'items': await SaviourApi.instance.camps()},
    builder: (data) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Donation camps'),
        if ((data['items'] as List).isEmpty) const Text('No upcoming camps.'),
        for (final item in data['items'] as List)
          _serverCampCard(context, ref, item as Map),
      ],
    ),
  );
}

Widget _serverCampCard(BuildContext context, WidgetRef ref, Map item) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: _CampCard(
        title: item['title'] as String,
        location: item['location'] as String,
        date: (item['startsAt'] as String),
        time: '${item['availableSlots']} slots available',
        onRegister: () => _serverAction(
          context,
          ref,
          () => SaviourApi.instance.reserveCamp(item['id'] as String),
          'Your reservation is confirmed.',
        ),
      ),
    );
Future<void> _serverAction(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() action,
  String success,
) async {
  try {
    await action();
    if (context.mounted) _message(context, ref, success);
  } on SaviourApiException catch (error) {
    if (context.mounted) _message(context, ref, error.message);
  }
}

class _CampCard extends StatelessWidget {
  const _CampCard({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.onRegister,
  });
  final String title;
  final String location;
  final String date;
  final String time;
  final VoidCallback onRegister;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformCard(
      padding: const EdgeInsets.all(18),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.text.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                location,
                style: theme.text.bodySmall?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 18,
                runSpacing: 8,
                children: [
                  _IconLabel(icon: Icons.calendar_today_outlined, label: date),
                  _IconLabel(icon: Icons.schedule, label: time),
                ],
              ),
            ],
          );
          if (constraints.maxWidth < 520) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                content,
                const SizedBox(height: 16),
                PlatformButton(
                  onPressed: onRegister,
                  child: const Text('Reserve a slot'),
                ),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: content),
              const SizedBox(width: 18),
              PlatformButton(
                onPressed: onRegister,
                child: const Text('Reserve a slot'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ProfilePage extends ConsumerWidget {
  const _ProfilePage({
    required this.available,
    required this.onAvailabilityChanged,
    required this.onSignOut,
  });
  final bool available;
  final ValueChanged<bool> onAvailabilityChanged;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.platformTheme;
    void open(Widget screen) => Navigator.of(context).push(
      PlatformPageRoute<void>(
        platform: ref.read(appPlatformProvider),
        builder: (_) => screen,
      ),
    );
    return _PageScroll(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PageHeader(
            eyebrow: 'DONOR PROFILE',
            title:
                '${SaviourApi.instance.currentUser?['name'] ?? SaviourApi.instance.currentUser?['phone'] ?? 'Your profile'}',
            subtitle:
                '${SaviourApi.instance.currentUser?['bloodGroup'] ?? 'Blood group not set'}',
          ),
          const SizedBox(height: 22),
          PlatformCard(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: theme.primary.withValues(alpha: .12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${SaviourApi.instance.currentUser?['donationCount'] ?? 0}',
                    style: theme.text.titleLarge?.copyWith(
                      color: theme.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available to donate',
                        style: theme.text.titleMedium,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        available
                            ? 'Nearby urgent alerts are enabled'
                            : 'You will not receive donor alerts',
                        style: theme.text.bodySmall?.copyWith(
                          color: theme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                PlatformSwitch(
                  value: available,
                  semanticLabel: 'Donor availability',
                  onChanged: onAvailabilityChanged,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Health & donation', style: theme.text.titleMedium),
          const SizedBox(height: 8),
          PlatformCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                PlatformListTile(
                  title: const Text('Eligibility tracker'),
                  subtitle: Text(
                    '${SaviourApi.instance.currentUser?['eligibleOn'] ?? 'Eligibility not recorded'}',
                  ),
                  leading: const Icon(Icons.fact_check_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const eligibility.EligibilityScreen()),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Donation history'),
                  subtitle: Text(
                    '${SaviourApi.instance.currentUser?['donationCount'] ?? 0} donations',
                  ),
                  leading: const Icon(Icons.history),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const history.HomeScreen()),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Health insights'),
                  subtitle: const Text('Recovery and preparation guidance'),
                  leading: const Icon(Icons.monitor_heart_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const insights.HealthInsightsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Account', style: theme.text.titleMedium),
          const SizedBox(height: 8),
          PlatformCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                PlatformListTile(
                  title: const Text('Personal and medical details'),
                  leading: const Icon(Icons.badge_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => showPlatformSheet<void>(
                    context: context,
                    platform: ref.read(appPlatformProvider),
                    builder: (_) => const _EditProfileSheet(),
                  ),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Notification preferences'),
                  leading: const Icon(Icons.notifications_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const settings.SettingsScreen()),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Privacy and security'),
                  leading: const Icon(Icons.shield_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const settings.SettingsScreen()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Community tools', style: theme.text.titleMedium),
          const SizedBox(height: 8),
          PlatformCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                PlatformListTile(
                  title: const Text('Emergency SOS'),
                  subtitle: const Text('Coordinate urgent support'),
                  leading: const Icon(Icons.emergency_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const emergency.EmergencySosScreen()),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Blood inventory'),
                  subtitle: const Text('Live partner blood-bank levels'),
                  leading: const Icon(Icons.inventory_2_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const inventory.InventoryHomePage()),
                ),
                const PlatformDivider(indent: 56),
                PlatformListTile(
                  title: const Text('Rare donor network'),
                  subtitle: const Text('Protected rare-group coordination'),
                  leading: const Icon(Icons.hub_outlined),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => open(const rare_donors.RareDonorPage()),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          PlatformButton(
            kind: PlatformButtonKind.outlined,
            onPressed: onSignOut,
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
  }
}

class CreateBloodRequestSheet extends ConsumerStatefulWidget {
  const CreateBloodRequestSheet({super.key});

  @override
  ConsumerState<CreateBloodRequestSheet> createState() =>
      _CreateBloodRequestSheetState();
}

class _CreateBloodRequestSheetState
    extends ConsumerState<CreateBloodRequestSheet> {
  final _patient = TextEditingController();
  final _hospital = TextEditingController();
  final _contact = TextEditingController();
  String _bloodGroup = 'O+';
  String _urgency = 'urgent';
  int _step = 0;
  bool _submitting = false;

  @override
  void dispose() {
    _patient.dispose();
    _hospital.dispose();
    _contact.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 620),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _step == 0 ? 'Create a blood request' : 'Confirm request',
              style: theme.text.titleLarge,
            ),
            const SizedBox(height: 7),
            Text(
              'Step ${_step + 1} of 2',
              style: theme.text.bodySmall?.copyWith(
                color: theme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            if (_step == 0) ...[
              PlatformTextField(
                controller: _patient,
                placeholder: 'Patient name',
              ),
              const SizedBox(height: 12),
              PlatformTextField(
                controller: _hospital,
                placeholder: 'Hospital or blood bank',
              ),
              const SizedBox(height: 12),
              PlatformTextField(
                controller: _contact,
                placeholder: 'Coordinator mobile number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              Text('Blood group', style: theme.text.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final group in const [
                    'O+',
                    'O−',
                    'A+',
                    'A−',
                    'B+',
                    'B−',
                    'AB+',
                    'AB−',
                  ])
                    PlatformButton(
                      kind: group == _bloodGroup
                          ? PlatformButtonKind.primary
                          : PlatformButtonKind.outlined,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 13,
                        vertical: 9,
                      ),
                      onPressed: () => setState(() => _bloodGroup = group),
                      child: Text(group),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              PlatformSegmentedControl<String>(
                segments: const [
                  PlatformSegment(value: 'urgent', label: 'Urgent'),
                  PlatformSegment(value: 'planned', label: 'Planned'),
                ],
                value: _urgency,
                onChanged: (value) => setState(() => _urgency = value),
              ),
            ] else
              PlatformCard(
                padding: const EdgeInsets.all(18),
                child: Column(
                  children: [
                    _SummaryRow(label: 'Patient', value: _patient.text),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Hospital', value: _hospital.text),
                    const SizedBox(height: 12),
                    _SummaryRow(label: 'Blood group', value: _bloodGroup),
                    const SizedBox(height: 12),
                    _SummaryRow(
                      label: 'Priority',
                      value: _urgency == 'urgent' ? 'Urgent' : 'Planned',
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 22),
            Row(
              children: [
                if (_step == 1) ...[
                  Expanded(
                    child: PlatformButton(
                      kind: PlatformButtonKind.outlined,
                      onPressed: () => setState(() => _step = 0),
                      child: const Text('Back'),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Expanded(
                  child: PlatformButton(
                    onPressed: _submitting ? null : _next,
                    child: Text(
                      _step == 0 ? 'Review request' : 'Broadcast request',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _next() async {
    if (_submitting) return;
    if (_step == 0) {
      if (_patient.text.trim().isEmpty ||
          _hospital.text.trim().isEmpty ||
          _contact.text.trim().length < 8) {
        _message(
          context,
          ref,
          'Add the patient, hospital, and a valid coordinator number.',
        );
        return;
      }
      setState(() => _step = 1);
      return;
    }
    setState(() => _submitting = true);
    try {
      await SaviourApi.instance.createRequest(
        patientName: _patient.text.trim(),
        hospital: _hospital.text.trim(),
        contactPhone: _contact.text.trim(),
        bloodGroup: _bloodGroup,
        urgent: _urgency == 'urgent',
      );
      if (!mounted) return;
      Navigator.pop(context);
      _message(context, ref, 'Your blood request has been created.');
    } on SaviourApiException catch (error) {
      if (mounted) _message(context, ref, error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}

class NotificationsPanel extends StatelessWidget {
  const NotificationsPanel({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 440,
    child: _ServerView(
      load: () async => {'items': await SaviourApi.instance.notifications()},
      builder: (data) => Column(
        children: [
          const Text('Notifications'),
          if ((data['items'] as List).isEmpty) const Text('No notifications.'),
          for (final item in data['items'] as List)
            PlatformListTile(
              title: Text(item['title'] as String),
              subtitle: Text(item['body'] as String),
            ),
        ],
      ),
    ),
  );
}

class _ServerView extends StatefulWidget {
  const _ServerView({super.key, required this.load, required this.builder});
  final Future<Map<String, Object?>> Function() load;
  final Widget Function(Map<String, Object?>) builder;
  @override
  State<_ServerView> createState() => _ServerViewState();
}

class _ServerViewState extends State<_ServerView> {
  late Future<Map<String, Object?>> _data = widget.load();
  @override
  void initState() {
    super.initState();
    SaviourApi.instance.revision.addListener(_reload);
  }

  void _reload() => setState(() => _data = widget.load());
  @override
  void dispose() {
    SaviourApi.instance.revision.removeListener(_reload);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _PageScroll(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlatformButton(
          onPressed: () => setState(() => _data = widget.load()),
          child: const Text('Refresh'),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Map<String, Object?>>(
          future: _data,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Text('Loading…');
            }
            if (snapshot.hasError) return Text('${snapshot.error}');
            return widget.builder(snapshot.requireData);
          },
        ),
      ],
    ),
  );
}

class _PageScroll extends StatelessWidget {
  const _PageScroll({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => PlatformListView(
    padding: EdgeInsets.fromLTRB(
      MediaQuery.sizeOf(context).width > 700 ? 34 : 18,
      26,
      MediaQuery.sizeOf(context).width > 700 ? 34 : 18,
      34,
    ),
    children: [
      Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: child,
        ),
      ),
    ],
  );
}

class _PageHeader extends StatelessWidget {
  const _PageHeader({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    this.action,
  });
  final String eyebrow;
  final String title;
  final String subtitle;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                eyebrow,
                style: theme.text.labelMedium?.copyWith(
                  color: theme.primary,
                  fontWeight: FontWeight.w800,
                  letterSpacing: .7,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                style: theme.text.headlineMedium?.copyWith(
                  color: theme.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: theme.text.bodyMedium?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (action != null) ...[const SizedBox(width: 12), action!],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onPressed,
  });
  final String title;
  final String actionLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: theme.text.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        PlatformButton(
          kind: PlatformButtonKind.text,
          onPressed: onPressed,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Text(actionLabel),
        ),
      ],
    );
  }
}

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: theme.onSurfaceVariant),
        const SizedBox(width: 6),
        Text(
          label,
          style: theme.text.bodySmall?.copyWith(
            color: theme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.text.bodyMedium?.copyWith(
              color: theme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value.isEmpty ? 'Not provided' : value,
          style: theme.text.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

void _message(BuildContext context, WidgetRef ref, String message) =>
    showPlatformSnackbar(
      context: context,
      platform: ref.read(appPlatformProvider),
      message: message,
    );

class _EditProfileSheet extends ConsumerStatefulWidget {
  const _EditProfileSheet();
  @override
  ConsumerState<_EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  final _name = TextEditingController(
    text: SaviourApi.instance.currentUser?['name'] as String?,
  );
  final _group = TextEditingController(
    text: SaviourApi.instance.currentUser?['bloodGroup'] as String?,
  );
  bool _saving = false;
  @override
  void dispose() {
    _name.dispose();
    _group.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Edit donor profile'),
        PlatformTextField(controller: _name, placeholder: 'Full name'),
        const SizedBox(height: 12),
        PlatformTextField(
          controller: _group,
          placeholder: 'Blood group (e.g. O+)',
        ),
        const SizedBox(height: 16),
        PlatformButton(
          onPressed: _saving
              ? null
              : () async {
                  setState(() => _saving = true);
                  try {
                    await SaviourApi.instance.updateProfile(
                      name: _name.text.trim(),
                      bloodGroup: _group.text.trim(),
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  } on SaviourApiException catch (error) {
                    if (context.mounted) _message(context, ref, error.message);
                  } finally {
                    if (mounted) setState(() => _saving = false);
                  }
                },
          child: Text(_saving ? 'Saving…' : 'Save profile'),
        ),
      ],
    ),
  );
}
