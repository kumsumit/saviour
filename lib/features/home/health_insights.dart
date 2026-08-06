import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';

// ---------- Color palette ----------
const Color kPrimaryRed = SaviourPalette.shade800;
const Color kDarkRedText = SaviourPalette.shade900;
const Color kBg = SaviourPalette.shade100;
const Color kCardBorder = SaviourPalette.shade200;
const Color kGreenBadgeBg = SaviourPalette.shade100;
const Color kGreenBadgeText = SaviourPalette.shade600;
const Color kBlueCard = SaviourPalette.shade200;
const Color kBlueDark = SaviourPalette.shade700;

class HealthInsightsScreen extends StatelessWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: PlatformListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildLifetimeImpactCard(),
          const SizedBox(height: 24),
          _sectionTitle('LATEST CHECK-UP'),
          const SizedBox(height: 12),
          _buildCheckupCard(
            icon: Icons.water_drop,
            iconBg: SaviourPalette.shade200,
            iconColor: kPrimaryRed,
            title: 'Hemoglobin',
            value: '14.2',
            unit: 'g/dL',
            badgeText: 'NORMAL',
            badgeIcon: Icons.trending_up,
          ),
          const SizedBox(height: 12),
          _buildCheckupCard(
            icon: Icons.favorite_border,
            iconBg: SaviourPalette.shade100,
            iconColor: SaviourPalette.shade700,
            title: 'Blood Pressure',
            value: '120/80',
            unit: 'mmHg',
            badgeText: 'IDEAL',
            badgeIcon: Icons.remove,
          ),
          const SizedBox(height: 12),
          _buildCheckupCard(
            icon: Icons.favorite,
            iconBg: SaviourPalette.shade100,
            iconColor: SaviourPalette.shade700,
            title: 'Pulse',
            value: '72',
            unit: 'bpm',
            badgeText: 'HEALTHY',
            badgeIcon: Icons.trending_down,
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('HEMOGLOBIN LEVELS'),
              _pillTag('Last 6 Months'),
            ],
          ),
          const SizedBox(height: 12),
          _buildHemoglobinChart(),
          const SizedBox(height: 24),
          _buildEligibilityCard(),
          const SizedBox(height: 24),
          _sectionTitle('TIPS FOR YOU'),
          const SizedBox(height: 12),
          _buildTipsRow(),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- App bar ----------
  PreferredSizeWidget _buildAppBar() {
    return NativeAppBar(
      backgroundColor: kBg,
      elevation: 0,
      centerTitle: false,
      leading: const Icon(Icons.arrow_back, color: kPrimaryRed),
      title: const Text(
        'Health Insights',
        style: TextStyle(
          color: kPrimaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  // ---------- Lifetime impact card ----------
  Widget _buildLifetimeImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [SaviourPalette.shade800, SaviourPalette.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: kPrimaryRed.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'YOUR LIFETIME IMPACT',
            style: TextStyle(
              color: SaviourPalette.shade100,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _impactStat('12', 'Lives Saved'),
              _impactStat('4.5', 'Liters Donated'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: SaviourPalette.shade50,
            fontSize: 34,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: SaviourPalette.shade100, fontSize: 13),
        ),
      ],
    );
  }

  // ---------- Section title ----------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: SaviourPalette.shade950,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _pillTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: SaviourPalette.shade200,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: kPrimaryRed,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  // ---------- Check-up card ----------
  Widget _buildCheckupCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String unit,
    required String badgeText,
    required IconData badgeIcon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              _statusBadge(badgeText, badgeIcon),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(
              color: SaviourPalette.shade800,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: value,
                  style: const TextStyle(
                    color: SaviourPalette.shade950,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextSpan(
                  text: ' $unit',
                  style: const TextStyle(
                    color: SaviourPalette.shade800,
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: kGreenBadgeBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: kGreenBadgeText),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              color: kGreenBadgeText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Hemoglobin chart ----------
  Widget _buildHemoglobinChart() {
    final months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN'];
    // Relative bar heights (0-1), APR highlighted as the peak/current month
    final values = [0.55, 0.62, 0.7, 1.0, 0.68, 0.8];
    const double maxBarHeight = 140;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        children: [
          SizedBox(
            height: maxBarHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(months.length, (index) {
                final isHighlighted = index == 3; // APR
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      height: maxBarHeight * values[index],
                      decoration: BoxDecoration(
                        color: isHighlighted
                            ? kPrimaryRed
                            : SaviourPalette.shade300,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: months
                .map(
                  (m) => Expanded(
                    child: Center(
                      child: Text(
                        m,
                        style: const TextStyle(
                          color: SaviourPalette.shade700,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  // ---------- Eligibility card ----------
  Widget _buildEligibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kBlueCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: kBlueDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_note,
              color: SaviourPalette.shade50,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Next Eligibility',
                  style: TextStyle(
                    color: kBlueDark.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Eligible in 14 days',
                  style: TextStyle(
                    color: kBlueDark,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Based on your whole blood donation on May 12',
                  style: TextStyle(
                    color: kBlueDark.withValues(alpha: 0.7),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Tips row ----------
  Widget _buildTipsRow() {
    return SizedBox(
      height: 190,
      child: PlatformListView(
        scrollDirection: Axis.horizontal,
        children: [
          _tipCard(
            icon: Icons.water_drop_outlined,
            iconColor: SaviourPalette.shade600,
            iconBg: SaviourPalette.shade100,
            title: 'Hydration is Key',
            description:
                'Stay hydrated by drinking at least 2L of water today to prepare for your next visit.',
            actionText: 'SET REMINDER',
          ),
          const SizedBox(width: 12),
          _tipCard(
            icon: Icons.eco_outlined,
            iconColor: SaviourPalette.shade500,
            iconBg: SaviourPalette.shade100,
            title: 'Iron-Rich Foods',
            description:
                'Boost your iron with lean meats, spinach, and legumes this week.',
            actionText: 'SEE LIST',
          ),
        ],
      ),
    );
  }

  Widget _tipCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String description,
    required String actionText,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kCardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: Text(
              description,
              style: const TextStyle(
                fontSize: 12,
                color: SaviourPalette.shade800,
                height: 1.3,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                actionText,
                style: const TextStyle(
                  color: kDarkRedText,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward_ios,
                size: 10,
                color: kDarkRedText,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Bottom nav ----------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: SaviourPalette.shade100,
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_outlined, 'Home', false),
          _navItemActive(),
          _navItem(Icons.campaign_outlined, 'Camps', false),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    final color = active ? kPrimaryRed : SaviourPalette.shade700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 11)),
      ],
    );
  }

  Widget _navItemActive() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
            color: kPrimaryRed,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.health_and_safety_outlined,
            color: SaviourPalette.shade50,
            size: 22,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          'Health',
          style: TextStyle(
            color: kPrimaryRed,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
