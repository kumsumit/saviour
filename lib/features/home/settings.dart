import 'package:flutter/material.dart';

/// Vital Reserve — Settings Screen
/// A single-file Flutter recreation of the "Settings" UI, matching the
/// same design system as the emergency request screen.
///
/// Drop this file into a Flutter project (lib/vital_reserve_settings_screen.dart)
/// and push it with:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));

class AppColors {
  static const Color primaryRed = Color(0xFFB91C3C);
  static const Color background = Color(0xFFF7F7F9);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const Color sectionLabel = Color(0xFFB4788A);
  static const Color chevron = Color(0xFFCFC2C6);
  static const Color divider = Color(0xFFF0EDEF);
  static const Color editProfileBg = Color(0xFFBFE0F5);
  static const Color editProfileText = Color(0xFF1B4E66);
  static const Color enabledChipBg = Color(0xFFE4E1E4);
  static const Color enabledChipText = Color(0xFF6B6B6B);
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileCard(),
              const SizedBox(height: 24),
              _buildSectionLabel('ACCOUNT'),
              const SizedBox(height: 8),
              _buildGroupedCard([
                _SettingsRow(
                  icon: Icons.location_on_outlined,
                  label: 'Manage Addresses',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.bloodtype_outlined,
                  label: 'Change Blood Type',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.notifications_none,
                  label: 'Notification Preferences',
                  onTap: () {},
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionLabel('SECURITY'),
              const SizedBox(height: 8),
              _buildGroupedCard([
                _SettingsRow(
                  icon: Icons.lock_outline,
                  label: 'Change Password',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.fingerprint,
                  label: 'Biometric Authentication',
                  trailing: _BiometricSwitch(),
                  onTap: null,
                ),
                _SettingsRow(
                  icon: Icons.shield_outlined,
                  label: 'Two-Factor Authentication',
                  centerLabel: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildEnabledChip(),
                      const SizedBox(width: 6),
                      const Icon(Icons.chevron_right, color: AppColors.chevron),
                    ],
                  ),
                  onTap: () {},
                  showDivider: false,
                  showOwnChevron: false,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSectionLabel('SUPPORT'),
              const SizedBox(height: 8),
              _buildGroupedCard([
                _SettingsRow(
                  icon: Icons.help_outline,
                  label: 'Help Center',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.description_outlined,
                  label: 'Privacy Policy',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.article_outlined,
                  label: 'Terms of Service',
                  onTap: () {},
                ),
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: 'About Vital Reserve',
                  onTap: () {},
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSignOutButton(context),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Version 2.4.1 (Build 1082)',
                  style: TextStyle(color: Color(0xFFE0AEB8), fontSize: 13),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // -------------------- App Bar --------------------

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leadingWidth: 40,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryRed),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 24,
        ),
      ),
    );
  }

  // -------------------- Profile Card --------------------

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 32,
            backgroundColor: Color(0xFFEDEDED),
            child: Icon(Icons.person, size: 34, color: Color(0xFFB0B0B0)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sarah Jenkins',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'O+',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Expanded(
                      child: Text(
                        'Universal Donor',
                        style: TextStyle(
                          color: AppColors.textDark,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.editProfileBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.editProfileText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------- Section Helpers --------------------

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.sectionLabel,
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildGroupedCard(List<_SettingsRow> rows) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: rows),
    );
  }

  Widget _buildEnabledChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.enabledChipBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Enabled',
        style: TextStyle(color: AppColors.enabledChipText, fontSize: 12),
      ),
    );
  }

  // -------------------- Sign Out --------------------

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed out')),
          );
        },
        icon: const Icon(Icons.logout, color: AppColors.textDark, size: 18),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: Color(0xFFDDD5D8)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  // -------------------- Bottom Navigation --------------------

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home_outlined, 'Home', false),
            _buildNavItem(Icons.bloodtype_outlined, 'Donate', false),
            _buildNavItem(Icons.bar_chart_outlined, 'Impact', false),
            _buildNavItem(Icons.settings, 'Settings', true),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected) {
    if (selected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.primaryRed,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textDark, size: 20),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppColors.textDark, fontSize: 11),
        ),
      ],
    );
  }
}

/// A single row inside a grouped settings card (icon, label, trailing widget).
class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;
  final bool showOwnChevron;
  final bool centerLabel;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.showDivider = true,
    this.showOwnChevron = true,
    this.centerLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primaryRed, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    textAlign: centerLabel ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                ?trailing,
                if (trailing == null && showOwnChevron)
                  const Icon(Icons.chevron_right, color: AppColors.chevron),
              ],
            ),
          ),
          if (showDivider)
            const Divider(height: 1, indent: 50, endIndent: 16, color: AppColors.divider),
        ],
      ),
    );
  }
}

/// The red biometric authentication toggle switch.
class _BiometricSwitch extends StatefulWidget {
  @override
  State<_BiometricSwitch> createState() => _BiometricSwitchState();
}

class _BiometricSwitchState extends State<_BiometricSwitch> {
  bool _value = true;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _value,
      activeThumbColor: Colors.white,
      activeTrackColor: AppColors.primaryRed,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}

// -------------------- Demo entry point --------------------
// Remove this if importing SettingsScreen into an existing app.

void main() {
  runApp(const SettingsApp());
}

class SettingsApp extends StatelessWidget {
  const SettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vital Reserve - Settings',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.background),
      home: const SettingsScreen(),
    );
  }
}