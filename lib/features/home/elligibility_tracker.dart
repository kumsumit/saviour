import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const VitalReserveApp());
}

class VitalReserveApp extends StatelessWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Reserve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F7),
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const EligibilityScreen(),
    );
  }
}

// ---------------------------------------------------------------------------
// Color palette (matched to the design)
// ---------------------------------------------------------------------------
class AppColors {
  static const crimson = Color(0xFFC22141); // brand red / buttons / ring / banner
  static const crimsonDark = Color(0xFFA81834);
  static const pendingBg = Color(0xFFF7D9DE);
  static const ringTrack = Color(0xFFE6E6E8);
  static const cardBorder = Color(0xFFEFEFEF);
  static const bodyGrey = Color(0xFF6B6B6B);
  static const iconBoxBg = Color(0xFFD9EAF5);
  static const iconBoxIcon = Color(0xFF1F6FA8);
  static const checkGreen = Color(0xFF2E9A5B);
  static const clockBlue = Color(0xFF4A90D9);
}

// ---------------------------------------------------------------------------
// Screen
// ---------------------------------------------------------------------------
class EligibilityScreen extends StatelessWidget {
  const EligibilityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VitalAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [
          StatusRingCard(),
          SizedBox(height: 16),
          LastDonationCard(),
          SizedBox(height: 16),
          BloodTypeBanner(),
          SizedBox(height: 16),
          EligibilityChecklistCard(),
          SizedBox(height: 20),
          FindCampButton(),
          SizedBox(height: 12),
          ScheduleAppointmentButton(),
          SizedBox(height: 16),
          QuoteImageBanner(),
        ],
      ),
      bottomNavigationBar: const VitalBottomNav(),
    );
  }
}

// ---------------------------------------------------------------------------
// App Bar
// ---------------------------------------------------------------------------
class VitalAppBar extends StatelessWidget implements PreferredSizeWidget {
  const VitalAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.menu, color: AppColors.crimson),
        onPressed: () {},
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: AppColors.crimson,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.crimson),
          onPressed: () {},
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: Colors.grey.shade200, height: 1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status + Ring Card
// ---------------------------------------------------------------------------
class StatusRingCard extends StatelessWidget {
  const StatusRingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          // "STATUS: PENDING" pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.pendingBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'STATUS: PENDING',
              style: TextStyle(
                color: AppColors.crimsonDark,
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Next Eligible in 12 Days',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "You're doing great! Your body is replenishing its red blood cell levels for your next life-saving gift.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 28),
          const ReadyRing(percent: 0.82),
        ],
      ),
    );
  }
}

/// Large circular ring with percentage + "Ready" label in the center.
class ReadyRing extends StatelessWidget {
  final double percent;
  final double size;

  const ReadyRing({super.key, required this.percent, this.size = 220});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(percent: percent),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${(percent * 100).round()}%',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 34,
                  color: AppColors.crimson,
                ),
              ),
              Text(
                'Ready',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  _RingPainter({required this.percent});

  @override
  void paint(Canvas canvas, Size size) {
    final strokeWidth = size.width * 0.07;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = AppColors.ringTrack
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    final progressPaint = Paint()
      ..color = AppColors.crimson
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.butt;

    canvas.drawCircle(center, radius, trackPaint);

    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * percent;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) => oldDelegate.percent != percent;
}

// ---------------------------------------------------------------------------
// Last Donation Card
// ---------------------------------------------------------------------------
class LastDonationCard extends StatelessWidget {
  const LastDonationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'LAST DONATION',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                ),
              ),
              const Icon(Icons.history, size: 20, color: AppColors.crimson),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.iconBoxBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.water_drop, color: AppColors.iconBoxIcon, size: 22),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Whole Blood',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Sept 24, 2023 • Mercy Central',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Blood Type Banner
// ---------------------------------------------------------------------------
class BloodTypeBanner extends StatelessWidget {
  const BloodTypeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.crimson,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'BLOOD TYPE',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontWeight: FontWeight.w700,
              fontSize: 12,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                'O-',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Universal Donor',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Eligibility Checklist Card
// ---------------------------------------------------------------------------
enum ChecklistStatus { done, pending }

class ChecklistItem {
  final IconData icon;
  final String label;
  final ChecklistStatus status;
  const ChecklistItem({required this.icon, required this.label, required this.status});
}

const List<ChecklistItem> checklistItems = [
  ChecklistItem(icon: Icons.shield_outlined, label: 'Age (18-65 years)', status: ChecklistStatus.done),
  ChecklistItem(icon: Icons.monitor_weight_outlined, label: 'Weight (Min 50kg)', status: ChecklistStatus.done),
  ChecklistItem(icon: Icons.favorite_border, label: 'General Health', status: ChecklistStatus.done),
  ChecklistItem(icon: Icons.public, label: 'Recent Travel', status: ChecklistStatus.pending),
];

class EligibilityChecklistCard extends StatelessWidget {
  const EligibilityChecklistCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Eligibility Checklist',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < checklistItems.length; i++) ...[
            ChecklistRow(item: checklistItems[i]),
            if (i != checklistItems.length - 1) const Divider(height: 24),
          ],
          const SizedBox(height: 12),
          Text(
            'Note: This is a preliminary tracker. Final eligibility will be determined by medical staff at the donation site.',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12.5,
              fontStyle: FontStyle.italic,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class ChecklistRow extends StatelessWidget {
  final ChecklistItem item;
  const ChecklistRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final isDone = item.status == ChecklistStatus.done;
    return Row(
      children: [
        Icon(item.icon, size: 20, color: AppColors.crimson),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            item.label,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ),
        Icon(
          isDone ? Icons.check_circle : Icons.access_time_filled,
          size: 20,
          color: isDone ? AppColors.checkGreen : AppColors.clockBlue,
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action Buttons
// ---------------------------------------------------------------------------
class FindCampButton extends StatelessWidget {
  const FindCampButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.crimson,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 0,
        ),
        icon: const Icon(Icons.location_on, color: Colors.white, size: 20),
        label: const Text(
          'Find a Donation Camp',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

class ScheduleAppointmentButton extends StatelessWidget {
  const ScheduleAppointmentButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {},
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.crimson, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        icon: const Icon(Icons.calendar_today, color: AppColors.crimson, size: 18),
        label: const Text(
          'Schedule Appointment',
          style: TextStyle(color: AppColors.crimson, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Quote Image Banner
// ---------------------------------------------------------------------------
class QuoteImageBanner extends StatelessWidget {
  const QuoteImageBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          // Replace this with Image.network / Image.asset for a real photo.
          Container(
            height: 170,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.grey.shade900, Colors.grey.shade800],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Center(
              child: Icon(Icons.biotech, color: Colors.white24, size: 60),
            ),
          ),
          // Dark gradient overlay so the quote text stays legible
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.75)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Text(
              '"Your single donation can save up to three lives."',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
                height: 1.3,
                shadows: [Shadow(color: Colors.black.withValues(alpha: 0.4), blurRadius: 4)],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bottom Navigation Bar
// ---------------------------------------------------------------------------
class VitalBottomNav extends StatefulWidget {
  const VitalBottomNav({super.key});

  @override
  State<VitalBottomNav> createState() => _VitalBottomNavState();
}

class _VitalBottomNavState extends State<VitalBottomNav> {
  int _selectedIndex = 3; // "Profile" active per design

  final _items = const [
    _NavItem(icon: Icons.home_outlined, label: 'Home'),
    _NavItem(icon: Icons.bloodtype_outlined, label: 'Requests'),
    _NavItem(icon: Icons.location_on_outlined, label: 'Camps'),
    _NavItem(icon: Icons.person_outline, label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final selected = index == _selectedIndex;
            final item = _items[index];
            return GestureDetector(
              onTap: () => setState(() => _selectedIndex = index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.crimson : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      item.icon,
                      color: selected ? Colors.white : Colors.grey.shade600,
                      size: 20,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      style: TextStyle(
                        color: selected ? Colors.white : Colors.grey.shade600,
                        fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                        fontSize: 12,
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

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}