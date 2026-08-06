import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────
// Vital Reserve — Home / Camps Discovery Screen
// A blood-donation camp finder UI: search, quick filters, live map summary,
// upcoming camps list, and an eligibility-check prompt.
// ─────────────────────────────────────────────────────────────────────────

void main() {
  runApp(const VitalReserveApp());
}

class VitalReserveApp extends StatelessWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryRed = Color(0xFFB3202C);
    return MaterialApp(
      title: 'Vital Reserve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F5F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryRed,
          primary: primaryRed,
        ),
        fontFamily: 'Roboto',
      ),
      home: const VitalReserveHomeScreen(),
    );
  }
}

class VitalReserveHomeScreen extends StatefulWidget {
  const VitalReserveHomeScreen({super.key});

  @override
  State<VitalReserveHomeScreen> createState() =>
      _VitalReserveHomeScreenState();
}

class _VitalReserveHomeScreenState extends State<VitalReserveHomeScreen> {
  static const primaryRed = Color(0xFFB3202C);
  static const inkBlack = Color(0xFF1C1C1E);
  static const subtleGrey = Color(0xFF8A8A8E);

  // Which quick-filter chip is currently selected.
  int _selectedFilter = 0;
  int _currentNavIndex = 2; // "Camps" tab active, matching the screenshot.

  final List<_FilterChipData> _filters = const [
    _FilterChipData(icon: Icons.navigation_rounded, label: 'Nearby'),
    _FilterChipData(icon: Icons.calendar_today_rounded, label: 'This Week'),
    _FilterChipData(icon: Icons.bolt_rounded, label: 'Urgent Only'),
  ];

  final List<_CampData> _camps = const [
    _CampData(
      title: 'City Hospital Blood Drive',
      location: 'Central District, Medical Wing B',
      date: 'Oct 24, 2023',
      time: '09:00 - 17:00',
      urgent: true,
      isNgo: false,
      imageColor: Color(0xFF34495E),
      primaryActionLabel: 'Register',
      hasBellButton: true,
    ),
    _CampData(
      title: 'Hearts of Gold NGO',
      location: 'Community Center, West Side',
      date: 'Oct 26, 2023',
      time: '10:00 - 15:00',
      urgent: false,
      isNgo: true,
      imageColor: Color(0xFF5D7A94),
      primaryActionLabel: 'Remind Me',
      secondaryActionLabel: 'Details',
    ),
    _CampData(
      title: 'St. Jude Clinic Drive',
      location: 'St. Jude Plaza, North Wing',
      date: 'Oct 28, 2023',
      time: '08:00 - 14:00',
      urgent: false,
      isNgo: false,
      imageColor: Color(0xFF23384D),
      primaryActionLabel: 'Register',
      hasShareButton: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            const SizedBox(height: 8),
            _buildSearchBar(),
            const SizedBox(height: 14),
            _buildFilterChips(),
            const SizedBox(height: 18),
            _buildMapCard(),
            const SizedBox(height: 24),
            _buildSectionHeader('Upcoming Camps'),
            const SizedBox(height: 12),
            ..._camps.map(
              (camp) => Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: _CampCard(data: camp),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _buildEligibilityCard(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── App bar ──────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: primaryRed),
        onPressed: () {},
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: primaryRed,
          fontWeight: FontWeight.w700,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none_rounded, color: primaryRed),
          onPressed: () {},
        ),
      ],
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE6E1DF)),
        ),
        child: Row(
          children: [
            const Icon(Icons.search_rounded, color: subtleGrey, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search blood camps, cities, or NGOs',
                  hintStyle: const TextStyle(color: subtleGrey, fontSize: 14.5),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Quick filter chips ───────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final selected = index == _selectedFilter;
          return ChoiceChip(
            selected: selected,
            onSelected: (_) => setState(() => _selectedFilter = index),
            showCheckmark: false,
            avatar: Icon(
              filter.icon,
              size: 16,
              color: selected ? Colors.white : inkBlack,
            ),
            label: Text(filter.label),
            labelStyle: TextStyle(
              color: selected ? Colors.white : inkBlack,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            backgroundColor: const Color(0xFFEDEAE8),
            selectedColor: const Color(0xFF2F5D6B),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            shape: StadiumBorder(
              side: BorderSide(
                color: selected ? Colors.transparent : const Color(0xFFE0DBD8),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Live map summary card ────────────────────────────────────────────
  Widget _buildMapCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 170,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Dark "city map" background.
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment(0.1, -0.2),
                    radius: 1.1,
                    colors: [Color(0xFF3A2A28), Color(0xFF17181B)],
                  ),
                ),
              ),
              CustomPaint(painter: _CityGridPainter()),
              // Bottom gradient for text legibility.
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black87],
                    stops: [0.4, 1.0],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 14,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '5 Camps Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Within 5 miles of your location',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryRed,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Expand Map',
                        style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Section header with "View All" ───────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: inkBlack,
            ),
          ),
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'View All',
              style: TextStyle(
                color: primaryRed,
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Eligibility CTA card ─────────────────────────────────────────────
  Widget _buildEligibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF5B7086),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.fact_check_outlined,
                color: Colors.white, size: 24),
          ),
          const SizedBox(height: 14),
          const Text(
            'Are you eligible?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Check your health status before heading to a camp to '
            'ensure a smooth donation experience.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF2F4358),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Assessment',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom navigation ────────────────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      (Icons.home_outlined, 'Home'),
      (Icons.water_drop_outlined, 'Requests'),
      (Icons.local_shipping_outlined, 'Camps'),
      (Icons.person_outline_rounded, 'Profile'),
    ];

    return BottomAppBar(
      color: Colors.white,
      elevation: 8,
      padding: EdgeInsets.zero,
      child: SizedBox(
        height: 66,
        child: Row(
          children: List.generate(items.length, (index) {
            final selected = index == _currentNavIndex;
            final (icon, label) = items[index];
            return Expanded(
              child: InkWell(
                onTap: () => setState(() => _currentNavIndex = index),
                child: selected
                    ? Center(
                        child: Container(
                          width: 52,
                          height: 52,
                          decoration: const BoxDecoration(
                            color: primaryRed,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, color: Colors.white, size: 24),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(icon, color: const Color(0xFF2F5D6B), size: 22),
                          const SizedBox(height: 3),
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF2F5D6B),
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Camp card widget
// ─────────────────────────────────────────────────────────────────────────

class _CampCard extends StatelessWidget {
  final _CampData data;
  const _CampCard({required this.data});

  static const primaryRed = Color(0xFFB3202C);
  static const inkBlack = Color(0xFF1C1C1E);
  static const subtleGrey = Color(0xFF8A8A8E);
  static const tealDark = Color(0xFF2F5D6B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEFE9E6)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: 64,
                      height: 64,
                      color: data.imageColor,
                      child: const Icon(Icons.image_outlined,
                          color: Colors.white38, size: 22),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            data.title,
                            style: const TextStyle(
                              fontSize: 15.5,
                              fontWeight: FontWeight.w700,
                              color: inkBlack,
                              height: 1.2,
                            ),
                          ),
                        ),
                        if (data.urgent) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: primaryRed,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'URGENT NEED',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ] else if (data.isNgo) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCEBF3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'NGO',
                              style: TextStyle(
                                color: tealDark,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: subtleGrey),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            data.location,
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: subtleGrey,
                            ),
                            maxLines: 2,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: Color(0xFFF0ECEA)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _InfoBlock(label: 'DATE', value: data.date),
              ),
              Expanded(
                child: _InfoBlock(label: 'TIME', value: data.time),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        data.primaryActionLabel == 'Remind Me'
                            ? tealDark
                            : primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    data.primaryActionLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
              ),
              if (data.secondaryActionLabel != null) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: inkBlack,
                      side: const BorderSide(color: Color(0xFFE0DBD8)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      data.secondaryActionLabel!,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
              ] else if (data.hasBellButton) ...[
                const SizedBox(width: 10),
                _SquareIconButton(icon: Icons.notifications_none_rounded),
              ] else if (data.hasShareButton) ...[
                const SizedBox(width: 10),
                _SquareIconButton(icon: Icons.share_outlined),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoBlock extends StatelessWidget {
  final String label;
  final String value;
  const _InfoBlock({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: Color(0xFF8A8A8E),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF1C1C1E),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _SquareIconButton extends StatelessWidget {
  final IconData icon;
  const _SquareIconButton({required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE0DBD8)),
      ),
      child: Icon(icon, color: const Color(0xFF2F5D6B), size: 20),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────
// Decorative city-grid painter for the map summary card.
// ─────────────────────────────────────────────────────────────────────────

class _CityGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..strokeWidth = 1;

    const spacing = 22.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Faint glow to suggest an "active" hotspot on the map.
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFB3202C).withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(
        Rect.fromCircle(
          center: Offset(size.width * 0.32, size.height * 0.38),
          radius: 60,
        ),
      );
    canvas.drawCircle(
      Offset(size.width * 0.32, size.height * 0.38),
      60,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─────────────────────────────────────────────────────────────────────────
// Data models
// ─────────────────────────────────────────────────────────────────────────

class _FilterChipData {
  final IconData icon;
  final String label;
  const _FilterChipData({required this.icon, required this.label});
}

class _CampData {
  final String title;
  final String location;
  final String date;
  final String time;
  final bool urgent;
  final bool isNgo;
  final Color imageColor;
  final String primaryActionLabel;
  final String? secondaryActionLabel;
  final bool hasBellButton;
  final bool hasShareButton;

  const _CampData({
    required this.title,
    required this.location,
    required this.date,
    required this.time,
    required this.urgent,
    required this.isNgo,
    required this.imageColor,
    required this.primaryActionLabel,
    this.secondaryActionLabel,
    this.hasBellButton = false,
    this.hasShareButton = false,
  });
}