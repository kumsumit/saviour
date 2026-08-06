import 'package:flutter/material.dart';

/// Vital Reserve — Emergency Blood Request Screen
/// A single-file Flutter recreation of the "Vital Reserve" UI.
///
/// Drop this file into a Flutter project (lib/vital_reserve_screen.dart)
/// and push it with:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const VitalReserveScreen()));

class AppColors {
  static const Color primaryRed = Color(0xFFB91C3C);
  static const Color darkRed = Color(0xFF8E1030);
  static const Color background = Color(0xFFF7F7F9);
  static const Color cardBackground = Colors.white;
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B6B6B);
  static const Color mapTeal = Color(0xFF2E6B75);
  static const Color chipPink = Color(0xFFFBE1E6);
  static const Color checkBlue = Color(0xFF2F6FE0);
}

class VitalReserveScreen extends StatelessWidget {
  const VitalReserveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 110),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMapCard(),
                  const SizedBox(height: 16),
                  _buildInfoRow(),
                  const SizedBox(height: 16),
                  _buildRequestDetailsCard(),
                  const SizedBox(height: 16),
                  _buildHospitalCard(),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildBottomBar(context),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- App Bar --------------------

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.primaryRed),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: AppColors.primaryRed,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.share_outlined, color: AppColors.textDark),
          onPressed: () {},
        ),
      ],
    );
  }

  // -------------------- Map / Destination Card --------------------

  Widget _buildMapCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Container(
        height: 260,
        color: AppColors.mapTeal,
        child: Stack(
          children: [
            // Placeholder for the actual map preview / image.
            Positioned.fill(
              child: Opacity(
                opacity: 0.85,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF2E6B75), Color(0xFF1F4A52)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(Icons.map_outlined, size: 64, color: Colors.white24),
                  ),
                ),
              ),
            ),
            // Destination overlay pill at the bottom.
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'DESTINATION',
                            style: TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'City General',
                            style: TextStyle(
                              color: AppColors.textDark,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryRed,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.navigation, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            '0.8 miles',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // -------------------- Blood Type / Urgency Row --------------------

  Widget _buildInfoRow() {
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            child: Column(
              children: [
                const Icon(Icons.bloodtype, color: AppColors.primaryRed, size: 32),
                const SizedBox(height: 8),
                const Text(
                  'Blood Type Needed',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O-',
                  style: TextStyle(
                    color: AppColors.primaryRed,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoCard(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.chipPink,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CRITICAL NEED',
                    style: TextStyle(
                      color: AppColors.primaryRed,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Urgency Level',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Immediate',
                  style: TextStyle(
                    color: AppColors.textDark,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // -------------------- Request Details Card --------------------

  Widget _buildRequestDetailsCard() {
    return _InfoCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFD6E9FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.assignment_outlined, color: AppColors.checkBlue),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 15, height: 1.5, color: AppColors.textDark),
              children: [
                TextSpan(
                  text: 'Emergency blood request issued for a patient undergoing ',
                ),
                TextSpan(
                  text: 'Immediate surgery',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text:
                      '. We are currently experiencing a shortage of O-negative units. Your contribution could be life-saving in the next 2-4 hours.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF0D5DA)),
          const SizedBox(height: 8),
          const _ChecklistItem(text: 'Donors must have eaten within the last 4 hours.'),
          const SizedBox(height: 10),
          const _ChecklistItem(text: 'Valid ID required for hospital entrance.'),
        ],
      ),
    );
  }

  // -------------------- Hospital Contact Card --------------------

  Widget _buildHospitalCard() {
    return _InfoCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 56,
              height: 56,
              color: const Color(0xFFDCE6F0),
              child: const Icon(Icons.local_hospital_outlined, color: AppColors.textGrey),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'City General Hospital',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '452 Medical Center Plaza, East Wing',
                  style: TextStyle(color: AppColors.textGrey, fontSize: 13),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: Color(0xFFF0F0F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.phone_outlined, color: AppColors.textDark),
          ),
        ],
      ),
    );
  }

  // -------------------- Bottom Bar --------------------

  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Thanks for stepping up to help!")),
                );
              },
              icon: const Icon(Icons.favorite, color: Colors.white),
              label: const Text(
                "I'm interested",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFF0C6CE)),
            ),
            child: IconButton(
              icon: const Icon(Icons.support_agent_outlined, color: AppColors.primaryRed),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable rounded white card used throughout the screen.
class _InfoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const _InfoCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
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
      child: child,
    );
  }
}

/// A single checklist row with a blue check-circle icon.
class _ChecklistItem extends StatelessWidget {
  final String text;

  const _ChecklistItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_outline, color: AppColors.checkBlue, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 14, color: AppColors.textDark, height: 1.4),
          ),
        ),
      ],
    );
  }
}

// -------------------- Demo entry point --------------------
// Remove this if importing VitalReserveScreen into an existing app.

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
      theme: ThemeData(useMaterial3: true, scaffoldBackgroundColor: AppColors.background),
      home: const VitalReserveScreen(),
    );
  }
}