import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/auth/login.dart';
import 'package:saviour/features/home/feature_actions.dart';

// ─────────────────────────────────────────────────────────────────────────
// Vital Reserve — Account Side Drawer
// Profile summary (avatar, ELITE badge, blood type, last donation), a
// menu list with a highlighted "active" item + notification dot, and a
// Sign Out button pinned to the bottom.
// ─────────────────────────────────────────────────────────────────────────

// A minimal host screen so the drawer can be opened and previewed, matching
// the "drawer over a dimmed background" look from the screenshot.
class DrawerDemoScreen extends StatelessWidget {
  const DrawerDemoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: SaviourPalette.shade100,
      appBar: NativeAppBar(
        backgroundColor: SaviourPalette.shade50,
        elevation: 0,
        title: const Text(
          'Vital Reserve',
          style: TextStyle(
            color: SaviourPalette.shade800,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Builder(
        builder: (context) => Center(
          child: NativeElevatedButton(
            onPressed: () =>
                FeatureActions.open(context, const AccountDrawer()),
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
  static const primaryRed = SaviourPalette.shade800;
  static const inkBlack = SaviourPalette.shade950;
  static const bodyBrown = SaviourPalette.shade700;

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
    return NativeDrawer(
      backgroundColor: SaviourPalette.shade100,
      width: MediaQuery.of(context).size.width * 0.82,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: SafeArea(
        child: PlatformSingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              _buildProfileHeader(),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Divider(height: 1, color: SaviourPalette.shade200),
              ),
              const SizedBox(height: 12),

              ...List.generate(_topItems.length, (index) {
                return _buildMenuTile(_topItems[index], index);
              }),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 4),
                child: Divider(height: 1, color: SaviourPalette.shade200),
              ),

              ...List.generate(_bottomItems.length, (index) {
                // Offset indices so they don't collide with top items.
                return _buildMenuTile(
                  _bottomItems[index],
                  _topItems.length + index,
                );
              }),

              const SizedBox(height: 20),

              _buildSignOutButton(),
            ],
          ),
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
                    color: SaviourPalette.shade200,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 54,
                      color: SaviourPalette.shade400,
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
                    border: Border.all(
                      color: SaviourPalette.shade100,
                      width: 2,
                    ),
                  ),
                  child: const Text(
                    'ELITE',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: SaviourPalette.shade50,
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
              color: SaviourPalette.shade200,
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
      child: PlatformGestureSurface(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _selectedIndex = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: selected
                ? SaviourPalette.shade300
                : SaviourPalette.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                item.icon,
                size: 20,
                color: selected ? SaviourPalette.shade700 : primaryRed,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 16.5,
                    color: selected ? SaviourPalette.shade700 : bodyBrown,
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
    );
  }

  // ── Sign out button ──────────────────────────────────────────────────
  Widget _buildSignOutButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        width: double.infinity,
        child: NativeOutlinedButton.icon(
          onPressed: () => FeatureActions.confirm(
            context: context,
            title: 'Sign out of Saviour?',
            message: 'You can return anytime with your verified mobile number.',
            actionLabel: 'Sign out',
            onConfirmed: () =>
                FeatureActions.replaceAll(context, const LoginScreen()),
          ),
          icon: const Icon(Icons.logout_rounded, size: 18, color: bodyBrown),
          label: const Text(
            'Sign Out',
            style: TextStyle(
              color: bodyBrown,
              fontWeight: FontWeight.w700,
              fontSize: 14.5,
            ),
          ),
          style: NativeOutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 15),
            side: const BorderSide(color: SaviourPalette.shade300),
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
