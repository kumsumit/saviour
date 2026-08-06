import 'package:flutter/material.dart';


// ---------------------------------------------------------------------------
// Shared colors
// ---------------------------------------------------------------------------
class AppColors {
  static const primaryRed = Color(0xFFB0102A);
  static const darkText = Color(0xFF221417);
  static const mutedText = Color(0xFF6B6265);
  static const cardBg = Colors.white;
  static const borderColor = Color(0xFFE9E3E4);
  static const statBg = Color(0xFFECEAEB);
}

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
      bloodTypeColor: Color(0xFFF3D3D8),
      hospital: 'City General Hospital',
      status: 'URGENT',
      distance: '0.8 miles away',
      bloodComponent: 'Whole Blood',
    ),
    UrgentRequest(
      bloodType: 'A+',
      bloodTypeColor: Color(0xFFD3E3F3),
      hospital: 'Hope Medical Center',
      status: 'STABLE',
      distance: '2.4 miles away',
      bloodComponent: 'Platelets',
    ),
    UrgentRequest(
      bloodType: 'B-',
      bloodTypeColor: Color(0xFFF3D9D3),
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
      accentColor: Color(0xFF5E7C93),
    ),
    BloodCamp(
      day: '28',
      month: 'OCT',
      title: 'Tech Hub Blood Camp',
      location: 'Innovation Center',
      time: '10:00 AM - 05:00 PM',
      accentColor: Color(0xFF3A3F47),
    ),
  ];

  @override
  void dispose() {
    _campController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
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
              ..._requests.map((r) => Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: _UrgentRequestCard(request: r),
                  )),
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
    return AppBar(
      backgroundColor: const Color(0xFFF3F1F2),
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.darkText),
        onPressed: () {},
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.w800,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.primaryRed),
          onPressed: () {},
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
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 6),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 14, color: AppColors.mutedText),
              children: [
                TextSpan(text: 'You are eligible to donate in '),
                TextSpan(
                  text: '12 days',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryRed,
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
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Broadcast Blood Need',
              style: TextStyle(
                color: Colors.white,
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
                color: Color(0xFFF6DCE0),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 44,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primaryRed,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text(
                  'Start Broadcast',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
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
                    colors: [Color(0xFF14171C), Color(0xFF2A1418)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.local_hospital_outlined,
                    color: Colors.white24,
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
              color: AppColors.darkText,
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Text(
              actionLabel,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryRed,
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
              color: AppColors.darkText,
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
            iconColor: AppColors.primaryRed,
            value: '12',
            label: 'LIVES SAVED',
          ),
          _StatCard(
            icon: Icons.water_drop,
            iconColor: Color(0xFF3A6EA5),
            value: '4.8L',
            label: 'DONATED',
          ),
          _StatCard(
            icon: Icons.military_tech,
            iconColor: Color(0xFF8A6D1D),
            value: 'Gold',
            label: 'STATUS',
          ),
          _StatCard(
            icon: Icons.calendar_month,
            iconColor: AppColors.primaryRed,
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
    return BottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryRed,
      unselectedItemColor: AppColors.mutedText,
      selectedLabelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
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

    return Material(
      color: AppColors.cardBg,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {},
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: request.bloodTypeColor,
                child: Text(
                  request.bloodType,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkText,
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
                              color: AppColors.darkText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: isUrgent
                                ? const Color(0xFFF7DADD)
                                : const Color(0xFFE6E6E6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            request.status,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: isUrgent
                                  ? AppColors.primaryRed
                                  : AppColors.mutedText,
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
                        color: AppColors.mutedText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right, color: AppColors.mutedText),
            ],
          ),
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
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.borderColor),
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
                    color: Colors.white38,
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
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      Text(
                        camp.day,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryRed,
                          height: 1.0,
                        ),
                      ),
                      Text(
                        camp.month,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.mutedText,
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
                    color: AppColors.darkText,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 15, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        camp.location,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.mutedText,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.access_time,
                        size: 15, color: AppColors.mutedText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        camp.time,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.mutedText,
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
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primaryRed,
                      side: const BorderSide(color: AppColors.primaryRed),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Register Now',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
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
        color: AppColors.statBg,
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
              color: AppColors.darkText,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.mutedText,
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.borderColor),
        ),
        child: Icon(icon, size: 16, color: AppColors.darkText),
      ),
    );
  }
}