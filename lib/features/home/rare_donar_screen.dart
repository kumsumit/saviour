import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';

// ---------- Data Models ----------
class DonorContact {
  final String name;
  final String location;
  final String? imageUrl;
  final String initials;

  const DonorContact({
    required this.name,
    required this.location,
    this.imageUrl,
    required this.initials,
  });
}

class Contribution {
  final String title;
  final String date;
  final String volume;
  final String status;

  const Contribution({
    required this.title,
    required this.date,
    required this.volume,
    required this.status,
  });
}

class RareDonorPage extends StatefulWidget {
  const RareDonorPage({super.key});

  @override
  State<RareDonorPage> createState() => _RareDonorPageState();
}

class _RareDonorPageState extends State<RareDonorPage> {
  int currentNavIndex = 0;

  final List<DonorContact> donors = const [
    DonorContact(
      name: 'Dr. Elena Volkov',
      location: 'Zurich, CH • Rh-Null',
      imageUrl:
          'https://images.unsplash.com/photo-1573497019940-1c28c88b4f3e?w=200',
      initials: 'EV',
    ),
    DonorContact(
      name: 'Marcus Chen',
      location: 'Singapore • Bombay',
      imageUrl:
          'https://images.unsplash.com/photo-1600180758890-6b94519a8ba6?w=200',
      initials: 'MC',
    ),
    DonorContact(
      name: 'Sarah Miller',
      location: 'Toronto, CA • Rh-Null',
      imageUrl: null,
      initials: 'SM',
    ),
  ];

  final List<Contribution> contributions = const [
    Contribution(
      title: 'Global Emergency Reserve',
      date: 'August 12, 2023',
      volume: '450ml',
      status: 'CONFIRMED',
    ),
    Contribution(
      title: 'Regional Trauma Center',
      date: 'May 04, 2023',
      volume: '450ml',
      status: 'CONFIRMED',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      body: Stack(
        children: [
          SafeArea(
            child: PlatformListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _buildTopBar(),
                _buildHeroCard(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      _buildCriticalMatchAlert(),
                      const SizedBox(height: 16),
                      _buildEligibilityCard(),
                      const SizedBox(height: 16),
                      _buildLivesProtectedCard(),
                      const SizedBox(height: 24),
                      _buildDirectoryHeader(),
                      const SizedBox(height: 12),
                      ...donors.map(
                        (d) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _donorTile(d),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Recent Contributions',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...contributions.map(
                        (c) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _contributionTile(c),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 20,
            bottom: 90,
            child: NativeFloatingActionButton(
              backgroundColor: SaviourPalette.shade800,
              onPressed: () => FeatureActions.notice(
                context,
                'Showing rare donors nearest to your current location.',
              ),
              child: const Icon(
                Icons.location_on_outlined,
                color: SaviourPalette.shade50,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- Top Bar ----------
  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Row(
        children: [
          NativeIconButton(
            icon: const Icon(Icons.menu, color: SaviourPalette.shade950),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          const Spacer(),
          const Text(
            'Vital Reserve',
            style: TextStyle(
              color: SaviourPalette.shade800,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          NativeIconButton(
            icon: const Icon(
              Icons.notifications_none,
              color: SaviourPalette.shade950,
            ),
            onPressed: () => FeatureActions.notice(
              context,
              'You are all caught up on rare-donor alerts.',
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  // ---------- Hero Card ----------
  Widget _buildHeroCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: SaviourPalette.shade400.withValues(alpha: 0.6),
          ),
          gradient: const LinearGradient(
            colors: [SaviourPalette.shade900, SaviourPalette.shade950],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: SaviourPalette.shade400.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: SaviourPalette.shade400.withValues(alpha: 0.6),
                ),
              ),
              child: const Text(
                'RARE DONOR CLUB • ELITE',
                style: TextStyle(
                  color: SaviourPalette.shade400,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Rh-Null (Golden\nBlood)',
              style: TextStyle(
                color: SaviourPalette.shade50,
                fontSize: 26,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Your blood type is shared by fewer than 50 people worldwide. Your presence on this platform is vital for global healthcare resilience.',
              style: TextStyle(
                color: SaviourPalette.shade50.withValues(alpha: 0.75),
                fontSize: 13.5,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: SaviourPalette.shade50.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: SaviourPalette.shade50.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'GLOBAL PRIORITY ID',
                    style: TextStyle(
                      color: SaviourPalette.shade50.withValues(alpha: 0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'VR-992-ALPHA',
                    style: TextStyle(
                      color: SaviourPalette.shade50,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: List.generate(4, (i) {
                      final active = i < 3;
                      return Expanded(
                        child: Container(
                          height: 4,
                          margin: EdgeInsets.only(right: i == 3 ? 0 : 6),
                          decoration: BoxDecoration(
                            color: active
                                ? SaviourPalette.shade400
                                : SaviourPalette.shade50.withValues(
                                    alpha: 0.15,
                                  ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Critical Match Alert ----------
  Widget _buildCriticalMatchAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SaviourPalette.shade200,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SaviourPalette.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.auto_awesome,
                size: 16,
                color: SaviourPalette.shade900,
              ),
              const SizedBox(width: 6),
              Text(
                'CRITICAL MATCH ALERT',
                style: TextStyle(
                  color: SaviourPalette.shade900,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.4,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Immediate Need in Tokyo',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 19,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'A patient undergoing emergency cardiovascular surgery requires Rh-Null units. High-priority transport is authorized.',
            style: TextStyle(
              color: SaviourPalette.shade800,
              fontSize: 13.5,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: NativeElevatedButton(
              onPressed: () => FeatureActions.confirm(
                context: context,
                title: 'Contact rare donor network?',
                message:
                    'A verified coordinator will protect donor contact details until both parties confirm.',
                actionLabel: 'Contact',
                onConfirmed: () => FeatureActions.notice(
                  context,
                  'The rare donor coordinator has been notified.',
                ),
              ),
              style: NativeElevatedButton.styleFrom(
                backgroundColor: SaviourPalette.shade800,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Coordinate Donation',
                    style: TextStyle(
                      color: SaviourPalette.shade50,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward,
                    color: SaviourPalette.shade50,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Eligibility Window Card ----------
  Widget _buildEligibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SaviourPalette.shade200),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 78,
            height: 78,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 78,
                  height: 78,
                  child: PlatformCircularProgressIndicator(
                    value: 12 / 30,
                    size: 78,
                    strokeWidth: 6,
                    backgroundColor: SaviourPalette.shade200,
                    color: SaviourPalette.shade800,
                  ),
                ),
                const Text(
                  '12d',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Eligibility Window',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
          const SizedBox(height: 2),
          Text(
            'Until your next safe donation',
            style: TextStyle(color: SaviourPalette.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  // ---------- Lives Protected Card ----------
  Widget _buildLivesProtectedCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SaviourPalette.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SaviourPalette.shade400.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_rounded,
              color: SaviourPalette.shade400,
              size: 20,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '24',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 26),
          ),
          const SizedBox(height: 2),
          const Text(
            'Lives Protected',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          const SizedBox(height: 2),
          Text(
            'Lifetime direct impact',
            style: TextStyle(color: SaviourPalette.shade600, fontSize: 12.5),
          ),
        ],
      ),
    );
  }

  // ---------- Directory Header ----------
  Widget _buildDirectoryHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rare Donor Directory',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                'Connect with your global peer network for support and logistics.',
                style: TextStyle(
                  color: SaviourPalette.shade600,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Text(
              'View All',
              style: TextStyle(
                color: SaviourPalette.shade800,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const Icon(
              Icons.chevron_right,
              color: SaviourPalette.shade800,
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  Widget _donorTile(DonorContact donor) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          NativeAvatar(
            radius: 22,
            backgroundColor: SaviourPalette.shade800,
            child: Text(
              donor.initials,
              style: const TextStyle(
                color: SaviourPalette.shade50,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                donor.name,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                donor.location,
                style: TextStyle(
                  color: SaviourPalette.shade600,
                  fontSize: 12.5,
                ),
              ),
              const SizedBox(height: 3),
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    size: 12,
                    color: SaviourPalette.shade800,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'VERIFIED DONOR',
                    style: TextStyle(
                      color: SaviourPalette.shade800,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Contribution Tile ----------
  Widget _contributionTile(Contribution c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SaviourPalette.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.water_drop_outlined,
              color: SaviourPalette.shade800,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  c.date,
                  style: TextStyle(
                    color: SaviourPalette.shade600,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                c.volume,
                style: const TextStyle(
                  color: SaviourPalette.shade800,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                c.status,
                style: TextStyle(
                  color: SaviourPalette.shade600,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Bottom Navigation ----------
  Widget _buildBottomNav() {
    return NativeBottomNavigationBar(
      currentIndex: currentNavIndex,
      onTap: (i) => setState(() => currentNavIndex = i),
      selectedItemColor: SaviourPalette.shade800,
      unselectedItemColor: SaviourPalette.shade500,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.water_drop_outlined),
          label: 'Requests',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
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
