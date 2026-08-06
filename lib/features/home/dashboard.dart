import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';
import 'package:saviour/features/home/notification.dart';
import 'package:saviour/features/home/reciepient_details.dart';
import 'package:saviour/features/home/request_details.dart';

// ---------------------------------------------------------------------------
// Shared colors
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Models
// ---------------------------------------------------------------------------
class UrgentRequest {
  final String bloodType;
  final Color bloodTypeColor;
  final String hospital;
  final String status; // URGENT or STABLE
  final String distance;
  final String bloodComponent;

  const UrgentRequest({
    required this.bloodType,
    required this.bloodTypeColor,
    required this.hospital,
    required this.status,
    required this.distance,
    required this.bloodComponent,
  });
}

class BloodCamp {
  final String day;
  final String month;
  final String title;
  final String location;
  final String time;
  final Color accentColor;

  const BloodCamp({
    required this.day,
    required this.month,
    required this.title,
    required this.location,
    required this.time,
    required this.accentColor,
  });
}

// ---------------------------------------------------------------------------
// Home Dashboard
// ---------------------------------------------------------------------------
class HomeDashboardScreen extends StatefulWidget {
  const HomeDashboardScreen({super.key});

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  int _currentNavIndex = 0;
  final PageController _campController = PageController(viewportFraction: 0.82);

  final List<UrgentRequest> _requests = const [
    UrgentRequest(
      bloodType: 'O-',
      bloodTypeColor: SaviourPalette.shade200,
      hospital: 'City General Hospital',
      status: 'URGENT',
      distance: '0.8 miles away',
      bloodComponent: 'Whole Blood',
    ),
    UrgentRequest(
      bloodType: 'A+',
      bloodTypeColor: SaviourPalette.shade200,
      hospital: 'Hope Medical Center',
      status: 'STABLE',
      distance: '2.4 miles away',
      bloodComponent: 'Platelets',
    ),
    UrgentRequest(
      bloodType: 'B-',
      bloodTypeColor: SaviourPalette.shade200,
      hospital: 'Mercy Children\'s Wing',
      status: 'URGENT',
      distance: '4.1 miles away',
      bloodComponent: 'Whole Blood',
    ),
  ];

  final List<BloodCamp> _camps = const [
    BloodCamp(
      day: '24',
      month: 'OCT',
      title: 'Community Center Drive',
      location: 'Downtown Plaza, Bldg 4',
      time: '09:00 AM - 04:00 PM',
      accentColor: SaviourPalette.shade600,
    ),
    BloodCamp(
      day: '28',
      month: 'OCT',
      title: 'Tech Hub Blood Camp',
      location: 'Innovation Center',
      time: '10:00 AM - 05:00 PM',
      accentColor: SaviourPalette.shade800,
    ),
  ];

  @override
  void dispose() {
    _campController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: PlatformSingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildWelcomeHeader(),
              const SizedBox(height: 16),
              _buildBroadcastCard(),
              const SizedBox(height: 28),
              _buildSectionHeader('Urgent Requests Nearby', 'View All'),
              const SizedBox(height: 12),
              ..._requests.map(
                (r) => Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: _UrgentRequestCard(request: r),
                ),
              ),
              const SizedBox(height: 16),
              _buildCampsHeader(),
              const SizedBox(height: 14),
              _buildCampsCarousel(),
              const SizedBox(height: 28),
              _buildStatsGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------------------------------------------------------------------
  // App bar
  // ---------------------------------------------------------------------
  PreferredSizeWidget _buildAppBar() {
    return NativeAppBar(
      backgroundColor: SaviourPalette.shade100,
      elevation: 0,
      centerTitle: true,
      leading: NativeIconButton(
        icon: const Icon(Icons.menu, color: SaviourPalette.shade950),
        onPressed: () => FeatureActions.notice(
          context,
          'Use the main navigation to access every Saviour service.',
        ),
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: SaviourPalette.shade800,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        NativeIconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: SaviourPalette.shade800,
          ),
          onPressed: () =>
              FeatureActions.open(context, const NotificationsScreen()),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------
  // Welcome header
  // ---------------------------------------------------------------------
  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Welcome back, Sarah',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: SaviourPalette.shade600),
              children: [
                TextSpan(text: 'You are eligible to donate in '),
                TextSpan(
                  text: '12 days',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: SaviourPalette.shade800,
                  ),
                ),
                TextSpan(text: '.'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Broadcast card
  // ---------------------------------------------------------------------
  Widget _buildBroadcastCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: SaviourPalette.shade800,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Broadcast Blood Need',
              style: TextStyle(
                color: SaviourPalette.shade50,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Is there an emergency? Alert nearby donors in your community '
              'and save a life today. High priority requests are processed '
              'instantly.',
              style: TextStyle(
                color: SaviourPalette.shade200,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: NativeElevatedButton(
                onPressed: () => FeatureActions.open(
                  context,
                  const RecipientDetailsScreen(),
                ),
                style: NativeElevatedButton.styleFrom(
                  backgroundColor: SaviourPalette.shade50,
                  foregroundColor: SaviourPalette.shade800,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text(
                  'Start Broadcast',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Container(
                height: 130,
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [SaviourPalette.shade950, SaviourPalette.shade950],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: SaviourPalette.shade200,
                    size: 44,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Section header (Urgent Requests Nearby / View All)
  // ---------------------------------------------------------------------
  Widget _buildSectionHeader(String title, String actionLabel) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: SaviourPalette.shade950,
            ),
          ),
          PlatformGestureSurface(
            onTap: () => FeatureActions.notice(
              context,
              'All nearby verified requests are available in the Requests tab.',
            ),
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: SaviourPalette.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Camps header with arrow controls
  // ---------------------------------------------------------------------
  Widget _buildCampsHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Upcoming Blood Camps',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: SaviourPalette.shade950,
            ),
          ),
          Row(
            children: [
              _CircleIconButton(
                icon: Icons.arrow_back,
                onTap: () {
                  _campController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
              const SizedBox(width: 10),
              _CircleIconButton(
                icon: Icons.arrow_forward,
                onTap: () {
                  _campController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Camps carousel
  // ---------------------------------------------------------------------
  Widget _buildCampsCarousel() {
    return SizedBox(
      height: 300,
      child: PageView.builder(
        controller: _campController,
        itemCount: _camps.length,
        padEnds: false,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: index == _camps.length - 1 ? 20 : 8,
            ),
            child: _BloodCampCard(camp: _camps[index]),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Stats grid
  // ---------------------------------------------------------------------
  Widget _buildStatsGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 1.5,
        children: const [
          _StatCard(
            icon: Icons.favorite,
            iconColor: SaviourPalette.shade800,
            value: '12',
            label: 'LIVES SAVED',
          ),
          _StatCard(
            icon: Icons.water_drop,
            iconColor: SaviourPalette.shade600,
            value: '4.8L',
            label: 'DONATED',
          ),
          _StatCard(
            icon: Icons.military_tech,
            iconColor: SaviourPalette.shade600,
            value: 'Gold',
            label: 'STATUS',
          ),
          _StatCard(
            icon: Icons.calendar_month,
            iconColor: SaviourPalette.shade800,
            value: '42',
            label: 'DONATIONS',
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Bottom navigation
  // ---------------------------------------------------------------------
  Widget _buildBottomNav() {
    return NativeBottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: SaviourPalette.shade50,
      selectedItemColor: SaviourPalette.shade800,
      unselectedItemColor: SaviourPalette.shade600,
      selectedLabelStyle: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.water_drop_outlined),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.campaign_outlined),
          label: 'Camps',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Urgent request card widget
// ---------------------------------------------------------------------------
class _UrgentRequestCard extends StatelessWidget {
  final UrgentRequest request;

  const _UrgentRequestCard({required this.request});

  @override
  Widget build(BuildContext context) {
    final bool isUrgent = request.status == 'URGENT';

    return PlatformGestureSurface(
      borderRadius: BorderRadius.circular(16),
      onTap: () => FeatureActions.open(context, const VitalReserveScreen()),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SaviourPalette.shade200),
        ),
        child: Row(
          children: [
            NativeAvatar(
              radius: 24,
              backgroundColor: request.bloodTypeColor,
              child: Text(
                request.bloodType,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: SaviourPalette.shade950,
                  fontSize: 14,
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
                          request.hospital,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: SaviourPalette.shade950,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isUrgent
                              ? SaviourPalette.shade200
                              : SaviourPalette.shade200,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          request.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isUrgent
                                ? SaviourPalette.shade800
                                : SaviourPalette.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${request.distance} • ${request.bloodComponent}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: SaviourPalette.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right, color: SaviourPalette.shade600),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blood camp card
// ---------------------------------------------------------------------------
class _BloodCampCard extends StatelessWidget {
  final BloodCamp camp;

  const _BloodCampCard({required this.camp});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: SaviourPalette.shade200),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                height: 140,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      camp.accentColor.withValues(alpha: 0.85),
                      camp.accentColor,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.medical_services_outlined,
                    color: SaviourPalette.shade200,
                    size: 40,
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  width: 46,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: SaviourPalette.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        camp.day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: SaviourPalette.shade800,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        camp.month,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: SaviourPalette.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  camp.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: SaviourPalette.shade950,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 15,
                      color: SaviourPalette.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        camp.location,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: SaviourPalette.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      size: 15,
                      color: SaviourPalette.shade600,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        camp.time,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: SaviourPalette.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 40,
                  child: NativeOutlinedButton(
                    onPressed: () => FeatureActions.confirm(
                      context: context,
                      title: 'Register for ${camp.title}?',
                      message: '${camp.location} • ${camp.time}',
                      actionLabel: 'Register',
                      onConfirmed: () => FeatureActions.notice(
                        context,
                        'Your camp slot is reserved.',
                      ),
                    ),
                    style: NativeOutlinedButton.styleFrom(
                      foregroundColor: SaviourPalette.shade800,
                      side: const BorderSide(color: SaviourPalette.shade800),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stat card
// ---------------------------------------------------------------------------
class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: SaviourPalette.shade600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Small circular icon button (carousel arrows)
// ---------------------------------------------------------------------------
class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return PlatformGestureSurface(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: SaviourPalette.shade200),
        ),
        child: Icon(icon, size: 16, color: SaviourPalette.shade950),
      ),
    );
  }
}
