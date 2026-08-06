import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────
// Vital Reserve — Account Side Drawer
// Profile summary (avatar, ELITE badge, blood type, last donation), a
// menu list with a highlighted "active" item + notification dot, and a
// Sign Out button pinned to the bottom.
// ─────────────────────────────────────────────────────────────────────────

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
      theme: ThemeData(useMaterial3: true, fontFamily: 'Roboto'),
      home: const _DrawerDemoScreen(),
    );
  }
}

// A minimal host screen so the drawer can be opened and previewed, matching
// the "drawer over a dimmed background" look from the screenshot.
class _DrawerDemoScreen extends StatelessWidget {
  const _DrawerDemoScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F0EF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Vital Reserve',
          style: TextStyle(color: Color(0xFFB3202C), fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      drawer: const AccountDrawer(),
      body: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            child: const Text('Open Menu'),
          ),
        ),
      ),
    );
  }
}

class AccountDrawer extends StatefulWidget {
  const AccountDrawer({super.key});

  @override
  State<AccountDrawer> createState() => _AccountDrawerState();
}

class _AccountDrawerState extends State<AccountDrawer> {
  static const primaryRed = Color(0xFFB3202C);
  static const inkBlack = Color(0xFF1C1C1E);
  static const bodyBrown = Color(0xFF6B5B57);

  // Index of the currently selected/active menu item.
  int _selectedIndex = 1;

  final List<_MenuItemData> _topItems = const [
    _MenuItemData(icon: Icons.history_rounded, label: 'Donation History'),
    _MenuItemData(
      icon: Icons.fact_check_outlined,
      label: 'Eligibility Tracker',
      showDot: true,
    ),
    _MenuItemData(icon: Icons.bar_chart_rounded, label: 'Health Insights'),
  ];

  final List<_MenuItemData> _bottomItems = const [
    _MenuItemData(icon: Icons.settings_outlined, label: 'Settings'),
    _MenuItemData(icon: Icons.help_outline_rounded, label: 'Help & Support'),
  ];

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: const Color(0xFFF2F0EF),
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            _buildProfileHeader(),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Divider(height: 1, color: Color(0xFFE3D8D5)),
            ),
            const SizedBox(height: 12),

            ...List.generate(_topItems.length, (index) {
              return _buildMenuTile(_topItems[index], index);
            }),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
              child: Divider(height: 1, color: Color(0xFFE3D8D5)),
            ),

            ...List.generate(_bottomItems.length, (index) {
              // Offset indices so they don't collide with top items.
              return _buildMenuTile(_bottomItems[index], _topItems.length + index);
            }),

            const Spacer(),

            _buildSignOutButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ── Profile header: avatar, ELITE badge, name, blood type, last donation
  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 92,
                height: 92,
                padding: const EdgeInsets.all(3),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: primaryRed,
                ),
                child: ClipOval(
                  child: Container(
                    color: const Color(0xFFDCEAF5),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 54,
                      color: Color(0xFF7FA8C9),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -4,
                left: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    color: primaryRed,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFF2F0EF), width: 2),
                  ),
                  child: const Text(
                    'ELITE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Sarah Jenkins',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: inkBlack,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFF7D4D6),
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'O+ POSITIVE',
              style: TextStyle(
                color: primaryRed,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.3,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Last Donated: 2 months ago',
            style: TextStyle(fontSize: 13.5, color: bodyBrown),
          ),
        ],
      ),
    );
  }

  // ── Individual menu tile ─────────────────────────────────────────────
  Widget _buildMenuTile(_MenuItemData item, int index) {
    final selected = index == _selectedIndex;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _selectedIndex = index),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF9FD1F0) : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  item.icon,
                  size: 20,
                  color: selected ? const Color(0xFF1D5D82) : primaryRed,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 16.5,
                      color: selected ? const Color(0xFF1D5D82) : bodyBrown,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
                if (item.showDot)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: primaryRed,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Sign out button ──────────────────────────────────────────────────
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.logout_rounded, size: 18, color: bodyBrown),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: bodyBrown,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: const BorderSide(color: Color(0xFFCBB9B5)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final bool showDot;

  const _MenuItemData({
    required this.icon,
    required this.label,
    this.showDot = false,
  });
}