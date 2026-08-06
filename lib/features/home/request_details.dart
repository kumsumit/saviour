import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';

/// Vital Reserve — Emergency Blood Request Screen
/// A single-file Flutter recreation of the "Vital Reserve" UI.
///
/// Drop this file into a Flutter project (lib/vital_reserve_screen.dart)
/// and push it with:
///   Navigator.push(context, MaterialPageRoute(builder: (_) => const VitalReserveScreen()));

class VitalReserveScreen extends StatelessWidget {
  const VitalReserveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: SaviourPalette.shade50,
      appBar: _buildAppBar(context),
      body: SafeArea(
        top: false,
        child: Stack(
          children: [
            PlatformSingleChildScrollView(
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
    return NativeAppBar(
      backgroundColor: SaviourPalette.shade50,
      elevation: 0,
      leading: NativeIconButton(
        icon: const Icon(Icons.arrow_back, color: SaviourPalette.shade800),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Vital Reserve',
        style: TextStyle(
          color: SaviourPalette.shade800,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
      centerTitle: true,
      actions: [
        NativeIconButton(
          icon: const Icon(
            Icons.share_outlined,
            color: SaviourPalette.shade950,
          ),
          onPressed: () => FeatureActions.notice(
            context,
            'A privacy-safe request summary is ready to share.',
          ),
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
        color: SaviourPalette.shade600,
        child: Stack(
          children: [
            // Placeholder for the actual map preview / image.
            Positioned.fill(
              child: Opacity(
                opacity: 0.85,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        SaviourPalette.shade600,
                        SaviourPalette.shade800,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: SaviourPalette.shade200,
                    ),
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
                  color: SaviourPalette.shade50.withValues(alpha: 0.95),
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
                              color: SaviourPalette.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'City General',
                            style: TextStyle(
                              color: SaviourPalette.shade950,
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: SaviourPalette.shade800,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.navigation,
                            color: SaviourPalette.shade50,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            '0.8 miles',
                            style: TextStyle(
                              color: SaviourPalette.shade50,
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
                const Icon(
                  Icons.bloodtype,
                  color: SaviourPalette.shade800,
                  size: 32,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Blood Type Needed',
                  style: TextStyle(
                    color: SaviourPalette.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'O-',
                  style: TextStyle(
                    color: SaviourPalette.shade800,
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: SaviourPalette.shade200,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'CRITICAL NEED',
                    style: TextStyle(
                      color: SaviourPalette.shade800,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Urgency Level',
                  style: TextStyle(
                    color: SaviourPalette.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Immediate',
                  style: TextStyle(
                    color: SaviourPalette.shade950,
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
                  color: SaviourPalette.shade200,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.assignment_outlined,
                  color: SaviourPalette.shade600,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Request Details',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: SaviourPalette.shade950,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontSize: 15,
                height: 1.5,
                color: SaviourPalette.shade950,
              ),
              children: [
                TextSpan(
                  text:
                      'Emergency blood request issued for a patient undergoing ',
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
          const Divider(color: SaviourPalette.shade200),
          const SizedBox(height: 8),
          const _ChecklistItem(
            text: 'Donors must have eaten within the last 4 hours.',
          ),
          const SizedBox(height: 10),
          const _ChecklistItem(
            text: 'Valid ID required for hospital entrance.',
          ),
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
              color: SaviourPalette.shade200,
              child: const Icon(
                Icons.local_hospital_outlined,
                color: SaviourPalette.shade600,
              ),
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
                    color: SaviourPalette.shade950,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  '452 Medical Center Plaza, East Wing',
                  style: TextStyle(
                    color: SaviourPalette.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: SaviourPalette.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.phone_outlined,
              color: SaviourPalette.shade950,
            ),
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
        color: SaviourPalette.shade50,
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: NativeElevatedButton.icon(
              onPressed: () => FeatureActions.notice(
                context,
                'Thanks for stepping up to help!',
              ),
              icon: const Icon(Icons.favorite, color: SaviourPalette.shade50),
              label: const Text(
                "I'm interested",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: SaviourPalette.shade50,
                ),
              ),
              style: NativeElevatedButton.styleFrom(
                backgroundColor: SaviourPalette.shade800,
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
              border: Border.all(color: SaviourPalette.shade300),
            ),
            child: NativeIconButton(
              icon: const Icon(
                Icons.support_agent_outlined,
                color: SaviourPalette.shade800,
              ),
              onPressed: () => FeatureActions.notice(
                context,
                'Connecting you with a verified support coordinator.',
              ),
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
        const Icon(
          Icons.check_circle_outline,
          color: SaviourPalette.shade600,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: SaviourPalette.shade950,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
