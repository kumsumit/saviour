import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vital Reserve - Profile',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F5F5),
        useMaterial3: true,
      ),
      home: const ProfileScreen(),
    );
  }
}

// ---------- Color palette ----------
const Color kPrimaryRed = Color(0xFFB71C2B);
const Color kBg = Color(0xFFF7F5F5);
const Color kPinkBadgeBg = Color(0xFFF6DEE1);
const Color kBlueBadgeBg = Color(0xFFBFE0F5);
const Color kBlueBadgeText = Color(0xFF1F5A8A);
const Color kPinkImpactBg = Color(0xFFFBE2E4);
const Color kBlueImpactBg = Color(0xFFDCEEFA);
const Color kBlueImpactText = Color(0xFF1F5A8A);
const Color kGreyIconBg = Color(0xFFE7E5E5);

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          const SizedBox(height: 8),
          _buildProfileHeader(),
          const SizedBox(height: 24),
          _buildDonationImpactCard(),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('SAVED ADDRESSES'),
              _addNewAction(),
            ],
          ),
          const SizedBox(height: 12),
          _buildAddressCard(
            icon: Icons.home_outlined,
            title: 'Home',
            address: '124 Maplewood Dr, Portland, OR',
          ),
          const SizedBox(height: 12),
          _buildAddressCard(
            icon: Icons.work_outline,
            title: 'Work',
            address: 'Suite 400, Broadway Towers, Portland',
          ),
          const SizedBox(height: 24),
          _sectionTitle('ACCOUNT SETTINGS'),
          const SizedBox(height: 12),
          _buildSettingsTile(
            icon: Icons.person_outline,
            title: 'Personal Information',
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.notifications_none,
            title: 'Notification Preferences',
          ),
          const SizedBox(height: 10),
          _buildSettingsTile(
            icon: Icons.shield_outlined,
            title: 'Security & Privacy',
          ),
          const SizedBox(height: 28),
          _buildLogoutButton(),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ---------- App bar ----------
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBg,
      elevation: 0,
      centerTitle: true,
      leading: const Icon(Icons.menu, color: kPrimaryRed),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: kPrimaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16),
          child: Icon(Icons.notifications_none, color: Colors.black87),
        ),
      ],
    );
  }

  // ---------- Profile header ----------
  Widget _buildProfileHeader() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                color: const Color(0xFFDDE3E8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 60,
                color: Color(0xFF9AA5AD),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryRed,
                  shape: BoxShape.circle,
                  border: Border.all(color: kBg, width: 2),
                ),
                child: const Icon(Icons.edit, color: Colors.white, size: 14),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const Text(
          'Sarah Jenkins',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: kPinkBadgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                'O+ Positive',
                style: TextStyle(
                  color: kPrimaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: kBlueBadgeBg,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.check_circle, size: 14, color: kBlueBadgeText),
                  SizedBox(width: 5),
                  Text(
                    'Eligible to donate',
                    style: TextStyle(
                      color: kBlueBadgeText,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Donation impact card ----------
  Widget _buildDonationImpactCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFECE8E8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DONATION IMPACT',
            style: TextStyle(
              color: Colors.black87,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _impactBox(
                  bg: kPinkImpactBg,
                  icon: Icons.favorite,
                  iconColor: kPrimaryRed,
                  value: '24',
                  label: 'Lives Saved',
                  valueColor: kPrimaryRed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _impactBox(
                  bg: kBlueImpactBg,
                  icon: Icons.water_drop,
                  iconColor: kBlueImpactText,
                  value: '8.2L',
                  label: 'Total Donated',
                  valueColor: kBlueImpactText,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactBox({
    required Color bg,
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 22),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ---------- Section title ----------
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.black87,
        fontSize: 13,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _addNewAction() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: const [
        Icon(Icons.add, size: 16, color: kPrimaryRed),
        SizedBox(width: 4),
        Text(
          'Add New',
          style: TextStyle(
            color: kPrimaryRed,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  // ---------- Address card ----------
  Widget _buildAddressCard({
    required IconData icon,
    required String title,
    required String address,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFECE8E8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: kGreyIconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.black87, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  address,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------- Settings tile ----------
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFECE8E8)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.black87, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.black38, size: 20),
        ],
      ),
    );
  }

  // ---------- Logout button ----------
  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: () {},
        style: TextButton.styleFrom(
          foregroundColor: kPrimaryRed,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Icon(Icons.logout, size: 18, color: kPrimaryRed),
            SizedBox(width: 8),
            Text(
              'Log Out',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: kPrimaryRed,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Bottom nav ----------
  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
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
          _navItem(Icons.water_drop_outlined, 'Requests', false),
          _navItem(Icons.location_on_outlined, 'Camps', false),
          _navItemActive(),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    final color = active ? kPrimaryRed : Colors.black45;
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
          decoration: BoxDecoration(
            color: kPrimaryRed.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: kPrimaryRed, size: 22),
        ),
        const SizedBox(height: 2),
        const Text('Profile',
            style: TextStyle(
                color: kPrimaryRed, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}