import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Vital Reserve - Notifications',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF7F5F5),
        useMaterial3: true,
      ),
      home: const NotificationsScreen(),
    );
  }
}

// ---------- Color palette ----------
const Color kPrimaryRed = Color(0xFFB71C2B);
const Color kBg = Color(0xFFF7F5F5);
const Color kUrgentBg = Color(0xFFFAD4D8);
const Color kBlueAccent = Color(0xFF1F5A8A);
const Color kBlueIconBg = Color(0xFFD9EBFB);
const Color kGreyIconBg = Color(0xFFE7E5E5);
const Color kBrownDot = Color(0xFF7A5A4E);

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: _buildAppBar(),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _sectionHeader('URGENT REQUESTS', kPrimaryRed),
          const SizedBox(height: 10),
          _buildUrgentCard(
            icon: Icons.water_drop,
            title: 'Critical Need: O- Negative',
            time: '2M AGO',
            description:
                'City Central Hospital requires urgent O- blood for an emergency procedure. Your donation could save a life today.',
            actionText: 'Donate Now',
          ),
          const SizedBox(height: 12),
          _buildUrgentCard(
            icon: Icons.add,
            title: 'Nearby Emergency Request',
            time: '1H AGO',
            description:
                'A patient at Mercy Medical, 2 miles away, is in critical need of plasma matching your type.',
          ),
          const SizedBox(height: 24),
          _sectionHeader('NEW DONATION CAMPS', kBlueAccent),
          const SizedBox(height: 10),
          _buildStandardCard(
            icon: Icons.location_on,
            iconColor: kBlueAccent,
            iconBg: kBlueIconBg,
            title: 'Riverside Community Drive',
            time: '4H AGO',
            description:
                'A new blood drive has been scheduled at Riverside Park for this Saturday. Earn 200 bonus points.',
          ),
          const SizedBox(height: 12),
          _buildStandardCard(
            icon: Icons.calendar_today,
            iconColor: kBlueAccent,
            iconBg: kBlueIconBg,
            title: 'Tech Hub Pop-up Clinic',
            time: 'YESTERDAY',
            description:
                "Donate while you work! We're bringing the mobile clinic to the downtown tech district.",
          ),
          const SizedBox(height: 24),
          _sectionHeader('SYSTEM UPDATES', kBrownDot),
          const SizedBox(height: 10),
          _buildStandardCard(
            icon: Icons.verified_user_outlined,
            iconColor: Colors.black54,
            iconBg: kGreyIconBg,
            title: 'Eligibility Restored',
            time: '2D AGO',
            description:
                'Great news! It has been 56 days since your last donation. You are now eligible to donate again.',
          ),
          const SizedBox(height: 12),
          _buildStandardCard(
            icon: Icons.settings_outlined,
            iconColor: Colors.black54,
            iconBg: kGreyIconBg,
            title: 'Security Update',
            time: '1W AGO',
            description:
                "We've updated our privacy policy to better protect your donor data.",
          ),
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
      actions: [
        Stack(
          children: [
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.notifications_none, color: kPrimaryRed),
            ),
            Positioned(
              right: 14,
              top: 2,
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: kPrimaryRed,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Header ----------
  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        Row(
          children: const [
            Icon(Icons.done_all, size: 18, color: kBlueAccent),
            SizedBox(width: 6),
            Text(
              'Mark all as read',
              style: TextStyle(
                color: kBlueAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------- Section header ----------
  Widget _sectionHeader(String title, Color dotColor) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: dotColor,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  // ---------- Urgent card ----------
  Widget _buildUrgentCard({
    required IconData icon,
    required String title,
    required String time,
    required String description,
    String? actionText,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kUrgentBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: kPrimaryRed,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          time,
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (actionText != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryRed,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  actionText,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ---------- Standard card (camps / system updates) ----------
  Widget _buildStandardCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String time,
    required String description,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: const TextStyle(
                        color: Colors.black45,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 13,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
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
          _navItemActive(),
          _navItem(Icons.location_on_outlined, 'Camps', false),
          _navItem(Icons.person_outline, 'Profile', false),
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
          child: const Icon(Icons.water_drop, color: kPrimaryRed, size: 22),
        ),
        const SizedBox(height: 2),
        const Text('Requests',
            style: TextStyle(
                color: kPrimaryRed, fontSize: 11, fontWeight: FontWeight.w600)),
      ],
    );
  }
}