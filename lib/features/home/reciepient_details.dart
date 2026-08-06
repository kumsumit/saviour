import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';
import 'package:saviour/features/home/recepient_form_screen.dart';

class RecipientDetailsScreen extends StatefulWidget {
  const RecipientDetailsScreen({super.key});

  @override
  State<RecipientDetailsScreen> createState() => _RecipientDetailsScreenState();
}

class _RecipientDetailsScreenState extends State<RecipientDetailsScreen> {
  static const Color primaryRed = SaviourPalette.shade800;
  static const Color lightRedBg = SaviourPalette.shade100;
  static const Color borderPink = SaviourPalette.shade300;
  static const Color pageBg = SaviourPalette.shade100;

  String _recipient = 'self'; // 'self' or 'family'
  String? _selectedBloodType;

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: pageBg,
      appBar: NativeAppBar(
        backgroundColor: pageBg,
        elevation: 0,
        centerTitle: true,
        leading: NativeIconButton(
          icon: const Icon(Icons.arrow_back, color: primaryRed),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Vital Reserve',
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PlatformSingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    // Step header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Text(
                          'Step 1 of 3: Recipient Details',
                          style: TextStyle(
                            color: SaviourPalette.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '33% Complete',
                          style: TextStyle(
                            color: SaviourPalette.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PlatformLinearProgressIndicator(
                        value: 0.33,
                        height: 6,
                        backgroundColor: SaviourPalette.shade300,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Who is it for?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: SaviourPalette.shade950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "We'll use this to tailor the message for potential donors.",
                      style: TextStyle(
                        fontSize: 15,
                        color: SaviourPalette.shade800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Self / Family Member cards
                    Row(
                      children: [
                        Expanded(
                          child: _RecipientCard(
                            label: 'Self',
                            icon: Icons.person,
                            selected: _recipient == 'self',
                            onTap: () => setState(() => _recipient = 'self'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _RecipientCard(
                            label: 'Family Member',
                            icon: Icons.people_alt,
                            selected: _recipient == 'family',
                            onTap: () => setState(() => _recipient = 'family'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    const Text(
                      'Required Blood Type',
                      style: TextStyle(
                        fontSize: 17,
                        color: SaviourPalette.shade950,
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _bloodTypes.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: 1.5,
                          ),
                      itemBuilder: (context, index) {
                        final type = _bloodTypes[index];
                        final selected = _selectedBloodType == type;
                        return _BloodTypeChip(
                          label: type,
                          selected: selected,
                          onTap: () =>
                              setState(() => _selectedBloodType = type),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            // Bottom Next button
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: pageBg,
                border: Border(
                  top: BorderSide(color: SaviourPalette.shade300, width: 1),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: NativeElevatedButton(
                  style: NativeElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () =>
                      FeatureActions.open(context, const RecipientFormScreen()),
                  child: const Text(
                    'Next',
                    style: TextStyle(
                      fontSize: 17,
                      color: SaviourPalette.shade50,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RecipientCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  static const Color primaryRed = _RecipientDetailsScreenState.primaryRed;
  static const Color lightRedBg = _RecipientDetailsScreenState.lightRedBg;
  static const Color borderPink = _RecipientDetailsScreenState.borderPink;

  @override
  Widget build(BuildContext context) {
    return PlatformGestureSurface(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: selected ? lightRedBg : SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? primaryRed : borderPink,
            width: selected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: primaryRed, size: 30),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                color: SaviourPalette.shade950,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BloodTypeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BloodTypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const Color primaryRed = _RecipientDetailsScreenState.primaryRed;
  static const Color lightRedBg = _RecipientDetailsScreenState.lightRedBg;
  static const Color borderPink = _RecipientDetailsScreenState.borderPink;

  @override
  Widget build(BuildContext context) {
    return PlatformGestureSurface(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? lightRedBg : SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? primaryRed : borderPink,
            width: selected ? 2 : 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: selected ? primaryRed : SaviourPalette.shade800,
          ),
        ),
      ),
    );
  }
}
