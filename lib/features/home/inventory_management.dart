import 'package:flutter/material.dart';

void main() => runApp(const VitalReserveApp());

class VitalReserveApp extends StatelessWidget {
  const VitalReserveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Reserve',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF5F6F8),
        useMaterial3: true,
      ),
      home: const InventoryHomePage(),
    );
  }
}

// ---------- Colors ----------
class AppColors {
  static const red = Color(0xFFB71C2C);
  static const darkRed = Color(0xFF8E1622);
  static const blue = Color(0xFF1D5FA6);
  static const lightBlueBg = Color(0xFFEFF5FC);
  static const criticalBg = Color(0xFFFDEEEE);
  static const criticalBorder = Color(0xFFF3C6C9);
  static const stableBadgeBg = Color(0xFFDCEBFA);
  static const lowBadgeBg = Color(0xFFFBDADD);
  static const cardBorder = Color(0xFFE7E7EA);
  static const trackGrey = Color(0xFFE7E9EC);
}

// ---------- Data Model ----------
enum BloodStatus { stable, low, critical }

class BloodGroupData {
  final String label;
  final int units;
  final int maxUnits;
  final BloodStatus status;

  const BloodGroupData({
    required this.label,
    required this.units,
    required this.maxUnits,
    required this.status,
  });

  double get fraction => (units / maxUnits).clamp(0.0, 1.0);
}

class InventoryHomePage extends StatefulWidget {
  const InventoryHomePage({super.key});

  @override
  State<InventoryHomePage> createState() => _InventoryHomePageState();
}

class _InventoryHomePageState extends State<InventoryHomePage> {
  bool publicVisibility = true;
  int currentNavIndex = 0;

  final List<BloodGroupData> bloodGroups = const [
    BloodGroupData(label: 'A+', units: 24, maxUnits: 50, status: BloodStatus.stable),
    BloodGroupData(label: 'A-', units: 12, maxUnits: 50, status: BloodStatus.stable),
    BloodGroupData(label: 'B+', units: 31, maxUnits: 50, status: BloodStatus.stable),
    BloodGroupData(label: 'B-', units: 5, maxUnits: 50, status: BloodStatus.low),
    BloodGroupData(label: 'AB+', units: 18, maxUnits: 50, status: BloodStatus.stable),
    BloodGroupData(label: 'AB-', units: 3, maxUnits: 50, status: BloodStatus.low),
    BloodGroupData(label: 'O+', units: 48, maxUnits: 50, status: BloodStatus.stable),
    BloodGroupData(label: 'O-', units: 1, maxUnits: 50, status: BloodStatus.critical),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            _buildTopBar(),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inventory Management',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Central Blood Bank - Station 04',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 16),
                  _buildVisibilityToggle(),
                  const SizedBox(height: 16),
                  _buildAddUpdateButton(),
                  const SizedBox(height: 16),
                  _buildCriticalShortageCard(),
                  const SizedBox(height: 12),
                  _buildNextSyncCard(),
                  const SizedBox(height: 12),
                  _buildDailyUsageCard(),
                  const SizedBox(height: 24),
                  _buildBloodGroupsHeader(),
                  const SizedBox(height: 12),
                  _buildBloodGroupsGrid(),
                  const SizedBox(height: 24),
                  const Text(
                    'Facility Activity',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentTransfersCard(),
                  const SizedBox(height: 16),
                  _buildStorageCapacityCard(),
                ],
              ),
            ),
          ],
        ),
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
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.black87),
            onPressed: () {},
          ),
          const Spacer(),
          const Text(
            'Vital Reserve',
            style: TextStyle(
              color: AppColors.red,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.black87),
            onPressed: () {},
          ),
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.blue,
            child: Icon(Icons.person, size: 18, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ---------- Public Visibility Toggle ----------
  Widget _buildVisibilityToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Public Visibility',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          Switch(
            value: publicVisibility,
            activeThumbColor: Colors.white,
            activeTrackColor: AppColors.blue,
            onChanged: (v) => setState(() => publicVisibility = v),
          ),
        ],
      ),
    );
  }

  // ---------- Add/Update Button ----------
  Widget _buildAddUpdateButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        icon: const Icon(Icons.add_circle_outline, color: Colors.white),
        label: const Text(
          'Add/Update Inventory',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  // ---------- Critical Shortage Card ----------
  Widget _buildCriticalShortageCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.criticalBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.criticalBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.warning_amber_rounded,
                color: AppColors.red, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'CRITICAL SHORTAGE',
                style: TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'O Negative (O-)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Next Sync Card ----------
  Widget _buildNextSyncCard() {
    return _infoCard(
      icon: Icons.sync,
      iconColor: AppColors.blue,
      label: 'NEXT SYNC',
      value: 'In 14 minutes',
    );
  }

  // ---------- Daily Usage Card ----------
  Widget _buildDailyUsageCard() {
    return _infoCard(
      icon: Icons.assignment_outlined,
      iconColor: AppColors.blue,
      label: 'DAILY USAGE',
      value: '42 Units Used',
    );
  }

  Widget _infoCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.blue.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightBlueBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------- Blood Groups Header ----------
  Widget _buildBloodGroupsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Blood Groups',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        Row(
          children: [
            _legendDot(AppColors.red, 'Critical'),
            const SizedBox(width: 12),
            _legendDot(AppColors.blue, 'Stable'),
          ],
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }

  // ---------- Blood Groups Grid ----------
  Widget _buildBloodGroupsGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bloodGroups.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, index) => _bloodGroupCard(bloodGroups[index]),
    );
  }

  Widget _bloodGroupCard(BloodGroupData data) {
    final isCritical = data.status == BloodStatus.critical;
    final isLow = data.status == BloodStatus.low;

    final borderColor = isCritical ? AppColors.red : AppColors.cardBorder;
    final progressColor = isCritical || isLow ? AppColors.red : AppColors.blue;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: isCritical ? 1.4 : 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                data.label,
                style: const TextStyle(
                  color: AppColors.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 22,
                ),
              ),
              _statusBadge(data.status),
            ],
          ),
          const Spacer(),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '${data.units}',
                  style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),
                ),
                TextSpan(
                  text: data.units == 1 ? ' Unit' : ' Units',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: data.fraction,
              minHeight: 6,
              backgroundColor: AppColors.trackGrey,
              valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            ),
          ),
          if (isCritical) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.campaign_outlined, size: 13, color: AppColors.red),
                const SizedBox(width: 4),
                Text(
                  'Broadcast Sent',
                  style: TextStyle(
                    color: AppColors.red,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _statusBadge(BloodStatus status) {
    late String text;
    late Color bg;
    late Color fg;

    switch (status) {
      case BloodStatus.stable:
        text = 'Stable';
        bg = AppColors.stableBadgeBg;
        fg = AppColors.blue;
        break;
      case BloodStatus.low:
        text = 'Low';
        bg = AppColors.lowBadgeBg;
        fg = AppColors.red;
        break;
      case BloodStatus.critical:
        text = 'CRITICAL';
        bg = AppColors.red;
        fg = Colors.white;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  // ---------- Recent Transfers ----------
  Widget _buildRecentTransfersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RECENT TRANSFERS',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  letterSpacing: 0.5,
                  color: Colors.black87,
                ),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View Log',
                  style: TextStyle(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _transferRow(
            icon: Icons.arrow_upward_rounded,
            iconColor: AppColors.red,
            iconBg: AppColors.criticalBg,
            title: 'O- Transferred (2 Units)',
            subtitle: 'To: Emergency Ward A',
            time: '12m ago',
          ),
          const Divider(height: 24),
          _transferRow(
            icon: Icons.arrow_downward_rounded,
            iconColor: AppColors.blue,
            iconBg: AppColors.lightBlueBg,
            title: 'A+ Received (10 Units)',
            subtitle: 'From: Regional Depot',
            time: '1h ago',
          ),
        ],
      ),
    );
  }

  Widget _transferRow({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle,
                  style: TextStyle(
                      fontSize: 12.5, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Text(time,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
      ],
    );
  }

  // ---------- Storage Capacity Card ----------
  Widget _buildStorageCapacityCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          Container(
            height: 150,
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF2B2B2E), Color(0xFF565659)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Icon(Icons.kitchen,
                  size: 64, color: Colors.white.withValues(alpha: 0.25)),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'TOTAL STORAGE CAPACITY',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '182 / 400 Units',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 34,
                    height: 34,
                    child: CircularProgressIndicator(
                      value: 182 / 400,
                      strokeWidth: 4,
                      backgroundColor: Colors.white24,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.blue),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Bottom Navigation ----------
  Widget _buildBottomNav() {
    return BottomNavigationBar(
      currentIndex: currentNavIndex,
      onTap: (i) => setState(() => currentNavIndex = i),
      selectedItemColor: AppColors.red,
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: true,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(Icons.water_drop_outlined), label: 'Stock'),
        BottomNavigationBarItem(
            icon: Icon(Icons.location_on_outlined), label: 'Camps'),
        BottomNavigationBarItem(
            icon: Icon(Icons.person_outline), label: 'Profile'),
      ],
    );
  }
}