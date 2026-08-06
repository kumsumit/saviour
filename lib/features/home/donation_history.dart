import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:saviour/features/home/feature_actions.dart';

// ---------------------------------------------------------------------------
// Color palette (matched to the design)
// ---------------------------------------------------------------------------
// ---------------------------------------------------------------------------
// Home Screen
// ---------------------------------------------------------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      appBar: const VitalAppBar(),
      body: PlatformListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: const [
          StatusCard(),
          SizedBox(height: 28),
          DonationHistoryHeader(),
          SizedBox(height: 16),
          DonationTimeline(),
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
    return NativeAppBar(
      backgroundColor: SaviourPalette.shade50,
      elevation: 0,
      centerTitle: true,
      leading: NativeIconButton(
        icon: const Icon(Icons.menu, color: SaviourPalette.shade800),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: SaviourPalette.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: [
        NativeIconButton(
          icon: const Icon(
            Icons.notifications_none,
            color: SaviourPalette.shade800,
          ),
          onPressed: () => FeatureActions.notice(
            context,
            'You are all caught up on donation updates.',
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: SaviourPalette.shade200, height: 1),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status Card (Next Eligible Date + progress ring)
// ---------------------------------------------------------------------------
class StatusCard extends StatelessWidget {
  const StatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SaviourPalette.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'STATUS',
                  style: TextStyle(
                    color: SaviourPalette.shade800,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Next Eligible Date',
                  style: TextStyle(
                    color: SaviourPalette.shade950,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Nov 15, 2023',
                  style: TextStyle(
                    color: SaviourPalette.shade800,
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: SaviourPalette.shade600,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '8 weeks recovery period nearly complete.',
                        style: TextStyle(
                          color: SaviourPalette.shade700,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const ProgressRing(percent: 0.75),
        ],
      ),
    );
  }
}

/// Circular progress ring with a percentage label in the middle.
class ProgressRing extends StatelessWidget {
  final double percent; // 0.0 - 1.0
  final double size;

  const ProgressRing({super.key, required this.percent, this.size = 100});

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
          Text(
            '${(percent * 100).round()}%',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: SaviourPalette.shade950,
            ),
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
    final strokeWidth = size.width * 0.11;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final trackPaint = Paint()
      ..color = SaviourPalette.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = SaviourPalette.shade800
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

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
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.percent != percent;
}

// ---------------------------------------------------------------------------
// Donation History Header
// ---------------------------------------------------------------------------
class DonationHistoryHeader extends StatelessWidget {
  const DonationHistoryHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Donation History',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: SaviourPalette.shade200,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            '3 Total Saves',
            style: TextStyle(
              color: SaviourPalette.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Data model for a donation entry
// ---------------------------------------------------------------------------
class Donation {
  final String date;
  final String location;
  final String bloodType;
  final String volume;
  final bool verified;
  final bool isLatest;

  const Donation({
    required this.date,
    required this.location,
    required this.bloodType,
    required this.volume,
    this.verified = true,
    this.isLatest = false,
  });
}

const List<Donation> donations = [
  Donation(
    date: 'September 12, 2023',
    location: 'Mercy Hospital',
    bloodType: 'Whole Blood',
    volume: '450ml',
    isLatest: true,
  ),
  Donation(
    date: 'July 05, 2023',
    location: 'City Community Center',
    bloodType: 'Whole Blood',
    volume: '450ml',
  ),
  Donation(
    date: 'April 18, 2023',
    location: 'Red Cross Station 4',
    bloodType: 'Whole Blood',
    volume: '450ml',
  ),
];

// ---------------------------------------------------------------------------
// Timeline: dotted vertical line + marker dots + donation cards
// ---------------------------------------------------------------------------
class DonationTimeline extends StatelessWidget {
  const DonationTimeline({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(donations.length, (index) {
        final donation = donations[index];
        final isLast = index == donations.length - 1;
        return TimelineRow(donation: donation, showLineBelow: !isLast);
      }),
    );
  }
}

class TimelineRow extends StatelessWidget {
  final Donation donation;
  final bool showLineBelow;

  const TimelineRow({
    super.key,
    required this.donation,
    required this.showLineBelow,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline marker + dashed line
          SizedBox(
            width: 32,
            child: Column(
              children: [
                const SizedBox(height: 22),
                TimelineDot(filled: donation.isLatest),
                if (showLineBelow)
                  Expanded(
                    child: CustomPaint(
                      size: const Size(2, double.infinity),
                      painter: _DashedLinePainter(),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Donation card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: DonationCard(donation: donation),
            ),
          ),
        ],
      ),
    );
  }
}

class TimelineDot extends StatelessWidget {
  final bool filled;
  const TimelineDot({super.key, required this.filled});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? SaviourPalette.shade800 : SaviourPalette.shade400,
        border: Border.all(color: SaviourPalette.shade50, width: 3),
        boxShadow: [
          BoxShadow(
            color: (filled ? SaviourPalette.shade800 : SaviourPalette.shade500)
                .withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

class _DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SaviourPalette.shade300
      ..strokeWidth = 2;
    const dashHeight = 4.0;
    const dashSpace = 4.0;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------------------------------------------------------------------------
// Donation Card
// ---------------------------------------------------------------------------
class DonationCard extends StatelessWidget {
  final Donation donation;
  const DonationCard({super.key, required this.donation});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: SaviourPalette.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                donation.date,
                style: const TextStyle(
                  color: SaviourPalette.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              if (donation.verified) const VerifiedBadge(),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            donation.location,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              InfoChip(
                icon: Icons.water_drop_outlined,
                label: donation.bloodType,
              ),
              const SizedBox(width: 10),
              InfoChip(icon: Icons.timer_outlined, label: donation.volume),
            ],
          ),
          const SizedBox(height: 14),
          DownloadCertificateButton(
            onPressed: () => FeatureActions.notice(
              context,
              'The verified donation certificate is ready to share.',
            ),
          ),
        ],
      ),
    );
  }
}

class VerifiedBadge extends StatelessWidget {
  const VerifiedBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14, color: SaviourPalette.shade500),
          SizedBox(width: 4),
          Text(
            'Verified',
            style: TextStyle(
              color: SaviourPalette.shade500,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const InfoChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: SaviourPalette.shade700),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: SaviourPalette.shade700,
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class DownloadCertificateButton extends StatelessWidget {
  final VoidCallback onPressed;
  const DownloadCertificateButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NativeOutlinedButton.icon(
        onPressed: onPressed,
        style: NativeOutlinedButton.styleFrom(
          side: const BorderSide(color: SaviourPalette.shade800, width: 1.4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        icon: const Icon(
          Icons.download,
          color: SaviourPalette.shade800,
          size: 18,
        ),
        label: const Text(
          'Download Certificate',
          style: TextStyle(
            color: SaviourPalette.shade800,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
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
  int _selectedIndex = 1; // "Requests" active per design

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
        color: SaviourPalette.shade50,
        border: Border(top: BorderSide(color: SaviourPalette.shade200)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_items.length, (index) {
            final selected = index == _selectedIndex;
            final item = _items[index];
            return PlatformGestureSurface(
              onTap: () => setState(() => _selectedIndex = index),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: selected
                          ? SaviourPalette.shade800.withValues(alpha: 0.12)
                          : SaviourPalette.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      color: selected
                          ? SaviourPalette.shade800
                          : SaviourPalette.shade600,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 12,
                      color: selected
                          ? SaviourPalette.shade800
                          : SaviourPalette.shade600,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                ],
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
