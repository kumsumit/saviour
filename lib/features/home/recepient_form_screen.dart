import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';
import 'package:saviour/features/home/request_details.dart';

class RecipientFormScreen extends StatefulWidget {
  const RecipientFormScreen({super.key});

  @override
  State<RecipientFormScreen> createState() => _RecipientFormScreenState();
}

class _RecipientFormScreenState extends State<RecipientFormScreen> {
  static const Color primaryRed = SaviourPalette.shade800;
  static const Color lightBlue = SaviourPalette.shade300;
  static const Color fieldBg = SaviourPalette.shade100;
  static const Color fieldBorder = SaviourPalette.shade300;
  static const Color pageBg = SaviourPalette.shade100;
  static const Color backPink = SaviourPalette.shade200;

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _wardController = TextEditingController();
  String _relationship = 'Parent';
  String? _hospitalName;

  final List<String> _relationships = ['Parent', 'Sibling', 'Spouse', 'Child'];

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _wardController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      backgroundColor: pageBg,
      appBar: NativeAppBar(
        backgroundColor: pageBg,
        elevation: 0,
        leading: NativeIconButton(
          icon: const Icon(Icons.arrow_back, color: primaryRed),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Recipient Details',
          style: TextStyle(
            color: primaryRed,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        centerTitle: false,
        actions: [
          NativeIconButton(
            icon: const Icon(Icons.notifications_none, color: primaryRed),
            onPressed: () =>
                FeatureActions.notice(context, 'No new notifications.'),
          ),
        ],
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
                          'Step 2 of 3',
                          style: TextStyle(
                            color: SaviourPalette.shade800,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        Text(
                          '66% Complete',
                          style: TextStyle(
                            color: SaviourPalette.shade950,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: PlatformLinearProgressIndicator(
                        value: 0.66,
                        height: 6,
                        backgroundColor: SaviourPalette.shade300,
                        color: primaryRed,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Who needs blood?',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: SaviourPalette.shade950,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Please provide the details of your family member who requires the donation.',
                      style: TextStyle(
                        fontSize: 15,
                        color: SaviourPalette.shade800,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Form card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: SaviourPalette.shade50,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: SaviourPalette.shade950.withValues(
                              alpha: 0.04,
                            ),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _FieldLabel('Full Name'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _nameController,
                            hint: "Enter recipient's full name",
                          ),
                          const SizedBox(height: 20),
                          _FieldLabel('Relationship'),
                          const SizedBox(height: 10),
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _relationships.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing: 12,
                                  crossAxisSpacing: 12,
                                  childAspectRatio: 2.6,
                                ),
                            itemBuilder: (context, index) {
                              final option = _relationships[index];
                              final selected = _relationship == option;
                              return _RelationshipChip(
                                label: option,
                                selected: selected,
                                onTap: () =>
                                    setState(() => _relationship = option),
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          _FieldLabel('Age'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _ageController,
                            hint: "Recipient's age",
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(height: 20),
                          _FieldLabel('Ward Number (Optional)'),
                          const SizedBox(height: 8),
                          _StyledTextField(
                            controller: _wardController,
                            hint: 'e.g., ICU-201',
                          ),
                          const SizedBox(height: 20),
                          _FieldLabel('Hospital Name'),
                          const SizedBox(height: 8),
                          PlatformGestureSurface(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => FeatureActions.notice(
                              context,
                              'Hospital search is active. Start typing the verified facility name.',
                            ),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: fieldBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: fieldBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.add_box,
                                    color: primaryRed,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _hospitalName ??
                                        'Select or search hospital',
                                    style: TextStyle(
                                      color: _hospitalName == null
                                          ? SaviourPalette.shade800
                                          : SaviourPalette.shade950,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Verified Care Units banner
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          Container(
                            height: 160,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  SaviourPalette.shade300,
                                  SaviourPalette.shade200,
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                          Positioned(
                            left: 20,
                            bottom: 18,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Verified Care Units',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: SaviourPalette.shade950,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'We prioritize requests from accredited medical facilities.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: SaviourPalette.shade950,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            // Bottom buttons
            Container(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              decoration: BoxDecoration(
                color: pageBg,
                border: Border(
                  top: BorderSide(color: SaviourPalette.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: NativeElevatedButton(
                        style: NativeElevatedButton.styleFrom(
                          backgroundColor: backPink,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => Navigator.of(context).maybePop(),
                        child: const Text(
                          'Back',
                          style: TextStyle(
                            fontSize: 17,
                            color: primaryRed,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 52,
                      child: NativeElevatedButton(
                        style: NativeElevatedButton.styleFrom(
                          backgroundColor: primaryRed,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () => FeatureActions.open(
                          context,
                          const VitalReserveScreen(),
                        ),
                        child: const Text(
                          'Next Step',
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
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: SaviourPalette.shade950,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    this.keyboardType,
  });

  static const Color fieldBg = _RecipientFormScreenState.fieldBg;
  static const Color fieldBorder = _RecipientFormScreenState.fieldBorder;
  static const Color primaryRed = _RecipientFormScreenState.primaryRed;

  @override
  Widget build(BuildContext context) {
    return NativeTextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 15, color: SaviourPalette.shade950),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: SaviourPalette.shade700,
          fontSize: 15,
        ),
        filled: true,
        fillColor: fieldBg,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: fieldBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryRed, width: 1.5),
        ),
      ),
    );
  }
}

class _RelationshipChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RelationshipChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  static const Color lightBlue = _RecipientFormScreenState.lightBlue;
  static const Color fieldBorder = _RecipientFormScreenState.fieldBorder;

  @override
  Widget build(BuildContext context) {
    return PlatformGestureSurface(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? lightBlue : SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? lightBlue : fieldBorder,
            width: 1.2,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: selected ? SaviourPalette.shade800 : SaviourPalette.shade950,
          ),
        ),
      ),
    );
  }
}
