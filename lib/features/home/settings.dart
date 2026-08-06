import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';

/// Vital Reserve — Settings Screen
/// A single-file Flutter recreation of the "Settings" UI, matching the
/// same design system as the emergency request screen.
///
/// Drop this file into a Flutter project (lib/vital_reserve_settings_screen.dart)
/// and push it with:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen()));

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: SaviourPalette.shade50,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: PlatformSingleChildScrollView(
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
                  onTap: () => FeatureActions.notice(
                    context,
                    'Address management is ready.',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.bloodtype_outlined,
                  label: 'Change Blood Type',
                  onTap: () => FeatureActions.notice(
                    context,
                    'Your blood type can be updated after identity verification.',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.notifications_none,
                  label: 'Notification Preferences',
                  onTap: () => FeatureActions.notice(
                    context,
                    'Notification preferences are saved automatically.',
                  ),
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
                  onTap: () => FeatureActions.notice(
                    context,
                    'A secure password reset link has been requested.',
                  ),
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
                      const Icon(
                        Icons.chevron_right,
                        color: SaviourPalette.shade300,
                      ),
                    ],
                  ),
                  onTap: () => FeatureActions.notice(
                    context,
                    'Language selection is available for supported locales.',
                  ),
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
                  onTap: () => FeatureActions.notice(
                    context,
                    'Opening the Saviour help centre.',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.description_outlined,
                  label: 'Privacy Policy',
                  onTap: () => FeatureActions.notice(
                    context,
                    'Your privacy controls and policy are available here.',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.article_outlined,
                  label: 'Terms of Service',
                  onTap: () => FeatureActions.notice(
                    context,
                    'Terms of Service opened.',
                  ),
                ),
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: 'About Vital Reserve',
                  onTap: () => FeatureActions.notice(
                    context,
                    'Saviour connects verified donors, hospitals, and recipients.',
                  ),
                  showDivider: false,
                ),
              ]),
              const SizedBox(height: 24),
              _buildSignOutButton(context),
              const SizedBox(height: 12),
              const Center(
                child: Text(
                  'Version 2.4.1 (Build 1082)',
                  style: TextStyle(
                    color: SaviourPalette.shade300,
                    fontSize: 13,
                  ),
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
    return NativeAppBar(
      backgroundColor: SaviourPalette.shade50,
      elevation: 0,
      leadingWidth: 40,
      titleSpacing: 0,
      leading: NativeIconButton(
        icon: const Icon(Icons.arrow_back, color: SaviourPalette.shade800),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Settings',
        style: TextStyle(
          color: SaviourPalette.shade800,
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
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const NativeAvatar(
            radius: 32,
            backgroundColor: SaviourPalette.shade100,
            child: Icon(Icons.person, size: 34, color: SaviourPalette.shade400),
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
                    color: SaviourPalette.shade950,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: SaviourPalette.shade800,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'O+',
                        style: TextStyle(
                          color: SaviourPalette.shade50,
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
                          color: SaviourPalette.shade950,
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
              color: SaviourPalette.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Edit Profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: SaviourPalette.shade800,
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
          color: SaviourPalette.shade500,
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
        color: SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.04),
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
        color: SaviourPalette.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'Enabled',
        style: TextStyle(color: SaviourPalette.shade600, fontSize: 12),
      ),
    );
  }

  // -------------------- Sign Out --------------------

  Widget _buildSignOutButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: NativeOutlinedButton.icon(
        onPressed: () => FeatureActions.notice(context, 'Signed out.'),
        icon: const Icon(
          Icons.logout,
          color: SaviourPalette.shade950,
          size: 18,
        ),
        label: const Text(
          'Sign Out',
          style: TextStyle(
            color: SaviourPalette.shade950,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: NativeOutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: const BorderSide(color: SaviourPalette.shade200),
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
        color: SaviourPalette.shade50,
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.05),
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
          color: SaviourPalette.shade800,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: SaviourPalette.shade50, size: 20),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: SaviourPalette.shade50,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: SaviourPalette.shade950, size: 20),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: SaviourPalette.shade950, fontSize: 11),
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
    return PlatformGestureSurface(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: SaviourPalette.shade800, size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    textAlign: centerLabel ? TextAlign.center : TextAlign.start,
                    style: const TextStyle(
                      fontSize: 15.5,
                      color: SaviourPalette.shade950,
                    ),
                  ),
                ),
                ?trailing,
                if (trailing == null && showOwnChevron)
                  const Icon(
                    Icons.chevron_right,
                    color: SaviourPalette.shade300,
                  ),
              ],
            ),
          ),
          if (showDivider)
            const Divider(
              height: 1,
              indent: 50,
              endIndent: 16,
              color: SaviourPalette.shade100,
            ),
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
    return NativeSwitch(
      value: _value,
      activeThumbColor: SaviourPalette.shade50,
      activeTrackColor: SaviourPalette.shade800,
      onChanged: (v) => setState(() => _value = v),
    );
  }
}
