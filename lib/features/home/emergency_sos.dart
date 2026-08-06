import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';

class EmergencySosScreen extends StatefulWidget {
  const EmergencySosScreen({super.key});

  @override
  State<EmergencySosScreen> createState() => _EmergencySosScreenState();
}

class _EmergencySosScreenState extends State<EmergencySosScreen> {
  bool _notifyDonors = true;
  int _currentNavIndex = 1;

  static const Color primaryRed = SaviourPalette.shade800;
  static const Color darkRed = SaviourPalette.shade950;
  static const Color navyBlue = SaviourPalette.shade800;

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: PlatformSingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDisasterBanner(),
              const SizedBox(height: 16),
              _buildSosCard(),
              const SizedBox(height: 16),
              _buildImmediateAssistance(),
              const SizedBox(height: 16),
              _buildShareAndDonorsRow(),
              const SizedBox(height: 16),
              _buildLocationCard(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return NativeAppBar(
      backgroundColor: SaviourPalette.shade50,
      elevation: 0,
      leading: const Icon(Icons.menu, color: primaryRed),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: false,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 16.0),
          child: Icon(Icons.notifications_none, color: SaviourPalette.shade950),
        ),
      ],
    );
  }

  Widget _buildDisasterBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      color: primaryRed,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: SaviourPalette.shade50,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'DISASTER MODE ACTIVE',
                  style: TextStyle(
                    color: SaviourPalette.shade50,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Government Verified: State\nEmergency (Level 5)',
                  style: TextStyle(
                    color: SaviourPalette.shade50,
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          NativeElevatedButton(
            onPressed: () => FeatureActions.notice(
              context,
              'Emergency protocol: verify the patient, hospital, coordinator, and required units before broadcasting.',
            ),
            style: NativeElevatedButton.styleFrom(
              backgroundColor: SaviourPalette.shade50,
              foregroundColor: primaryRed,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              elevation: 0,
            ),
            child: const Text(
              'VIEW\nPROTOCOL',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSosCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        decoration: BoxDecoration(
          color: SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: SaviourPalette.shade950.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            const Text(
              'Emergency SOS',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: SaviourPalette.shade950,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Press and hold for 3 seconds to broadcast',
              style: TextStyle(fontSize: 13.5, color: SaviourPalette.shade800),
            ),
            const SizedBox(height: 32),
            PlatformGestureSurface(
              onLongPress: () {
                FeatureActions.notice(context, 'SOS broadcast sent.');
              },
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [primaryRed, darkRed],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primaryRed.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: SaviourPalette.shade50,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      transform: Matrix4.identity()..rotateZ(0.785398), // 45deg
                      child: Transform.rotate(
                        angle: -0.785398,
                        child: const Icon(
                          Icons.priority_high_rounded,
                          color: SaviourPalette.shade50,
                          size: 28,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'SOS',
                      style: TextStyle(
                        color: SaviourPalette.shade50,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: SaviourPalette.shade200,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.campaign_outlined,
                    color: primaryRed,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Notify Nearest Donors',
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  NativeSwitch(
                    value: _notifyDonors,
                    activeThumbColor: SaviourPalette.shade50,
                    activeTrackColor: primaryRed,
                    onChanged: (val) {
                      setState(() => _notifyDonors = val);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImmediateAssistance() {
    return Container(
      width: double.infinity,
      color: SaviourPalette.shade100,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Immediate Assistance',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: SaviourPalette.shade950,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _AssistanceButton(
                  icon: Icons.call,
                  label: 'Hospitals',
                  color: navyBlue,
                  onTap: () => FeatureActions.notice(
                    context,
                    'Calling nearby verified hospitals…',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _AssistanceButton(
                  icon: Icons.local_hospital_outlined,
                  label: 'Dispatch',
                  color: navyBlue,
                  onTap: () => FeatureActions.notice(
                    context,
                    'Medical dispatch has received the request.',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildShareAndDonorsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SaviourPalette.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.share, color: primaryRed, size: 22),
                  const SizedBox(height: 10),
                  const Text(
                    'Share Alert',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15.5,
                    ),
                  ),
                  const Text(
                    'WhatsApp & SMS',
                    style: TextStyle(
                      color: SaviourPalette.shade800,
                      fontSize: 12.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _CircleIconButton(
                        icon: Icons.chat,
                        bgColor: SaviourPalette.shade400,
                        onTap: () => FeatureActions.notice(
                          context,
                          'The verified alert is ready to share on WhatsApp.',
                        ),
                      ),
                      const SizedBox(width: 10),
                      _CircleIconButton(
                        icon: Icons.sms,
                        bgColor: SaviourPalette.shade400,
                        onTap: () => FeatureActions.notice(
                          context,
                          'The verified alert is ready to share by SMS.',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SaviourPalette.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.people_alt_outlined,
                    color: navyBlue,
                    size: 22,
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '124',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                  ),
                  const Text(
                    'Nearby Donors',
                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                  ),
                  const Text(
                    'Ready within 5km',
                    style: TextStyle(
                      color: SaviourPalette.shade800,
                      fontSize: 12.5,
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

  Widget _buildLocationCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SaviourPalette.shade300),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 160,
                  width: double.infinity,
                  color: SaviourPalette.shade200,
                  child: CustomPaint(
                    painter: _MapPatternPainter(),
                    child: const Center(
                      child: Icon(
                        Icons.my_location,
                        color: primaryRed,
                        size: 32,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: SaviourPalette.shade50,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: SaviourPalette.shade950.withValues(
                            alpha: 0.15,
                          ),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: SaviourPalette.shade950,
                        ),
                        SizedBox(width: 4),
                        Text(
                          "St. Mary's General",
                          style: TextStyle(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          '451 Health Ave, Sector 4',
                          style: TextStyle(
                            color: SaviourPalette.shade800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  NativeTextButton(
                    onPressed: () => FeatureActions.notice(
                      context,
                      'Hospital location details can now be updated.',
                    ),
                    child: const Text(
                      'UPDATE',
                      style: TextStyle(
                        color: primaryRed,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return NativeBottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryRed,
      unselectedItemColor: SaviourPalette.shade800,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: primaryRed,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emergency_share,
              color: SaviourPalette.shade50,
              size: 20,
            ),
          ),
          label: 'Alert',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.park_outlined),
          label: 'Camps',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profile',
        ),
      ],
    );
  }
}

class _AssistanceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _AssistanceButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NativeElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18, color: SaviourPalette.shade50),
      label: Text(
        label,
        style: const TextStyle(
          color: SaviourPalette.shade50,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: NativeElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 0,
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return PlatformGestureSurface(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(color: bgColor, shape: BoxShape.circle),
        child: Icon(icon, color: SaviourPalette.shade50, size: 18),
      ),
    );
  }
}

/// Simple decorative painter to mimic a stylized map background.
class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = SaviourPalette.shade200
      ..strokeWidth = 1;

    for (double x = 0; x < size.width; x += 24) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 24) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
