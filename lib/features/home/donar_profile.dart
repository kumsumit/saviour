import 'package:saviour/app_theme.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_native_controls.dart';
import 'package:saviour/platform_widgets/platform_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:saviour/features/home/feature_actions.dart';
import 'package:saviour/platform_widgets/platform_overlay.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  static const Color primaryRed = SaviourPalette.shade800;
  static const Color navyBlue = SaviourPalette.shade800;
  static const Color travelBlue = SaviourPalette.shade700;

  String _currentStatus = 'Available';
  String _notificationPreference = 'Instant Alerts (Urgent Only)';
  bool _travelDonorEnabled = true;

  DateTime? _fromDate;
  DateTime? _toDate;

  final TextEditingController _destinationController = TextEditingController();
  final TextEditingController _medicalNotesController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _relationshipController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool _ironDeficiency = false;
  bool _recentTattoo = false;
  bool _internationalTravel = false;

  int _currentNavIndex = 3;

  @override
  void dispose() {
    _destinationController.dispose();
    _medicalNotesController.dispose();
    _contactNameController.dispose();
    _relationshipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isFrom}) async {
    final picked = await showPlatformDatePicker(
      context: context,
      platform: FeatureActions.platformOf(context),
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _fromDate = picked;
        } else {
          _toDate = picked;
        }
      });
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'mm/dd/yyyy';
    return '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return NativeScaffold(
      appBar: _buildAppBar(),
      body: SafeArea(
        top: false,
        child: PlatformSingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Your Donor Identity',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: SaviourPalette.shade950,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Complete your registration to join the Vital Reserve network and start saving lives through smart blood donations.',
                style: TextStyle(
                  fontSize: 14,
                  color: SaviourPalette.shade800,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              _buildDonationAvailabilityCard(),
              const SizedBox(height: 16),
              _buildTravelDonorCard(),
              const SizedBox(height: 16),
              _buildMedicalRestrictionsCard(),
              const SizedBox(height: 16),
              _buildEmergencyContactCard(),
              const SizedBox(height: 24),
              _buildSaveButton(),
              const SizedBox(height: 16),
              _buildSkipButton(),
              const SizedBox(height: 20),
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
      leading: NativeIconButton(
        icon: const Icon(Icons.arrow_back, color: SaviourPalette.shade950),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: const Text(
        'Complete Profile',
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

  Widget _buildCard({
    required Widget child,
    Color? borderColor,
    Color? bgColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor ?? SaviourPalette.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor ?? SaviourPalette.shade200),
        boxShadow: [
          BoxShadow(
            color: SaviourPalette.shade950.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionHeader(IconData icon, String title, Color color) {
    return Row(
      children: [
        Icon(icon, size: 18, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: SaviourPalette.shade950),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: SaviourPalette.shade300),
      ),
      child: PlatformDropdown<String>(
        value: value,
        isExpanded: true,
        items: items
            .map((item) => PlatformDropdownItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDonationAvailabilityCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.event_note_outlined,
            'DONATION AVAILABILITY',
            navyBlue,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Current Status'),
          _buildDropdown(
            value: _currentStatus,
            items: const ['Available', 'Unavailable', 'On Hold'],
            onChanged: (val) => setState(() => _currentStatus = val!),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Notification Preference'),
          _buildDropdown(
            value: _notificationPreference,
            items: const [
              'Instant Alerts (Urgent Only)',
              'Daily Digest',
              'All Notifications',
              'Muted',
            ],
            onChanged: (val) => setState(() => _notificationPreference = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelDonorCard() {
    return _buildCard(
      borderColor: travelBlue.withValues(alpha: 0.4),
      bgColor: SaviourPalette.shade100,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _sectionHeader(
                  Icons.flight_takeoff,
                  'TRAVEL DONOR\nPROGRAM',
                  travelBlue,
                ),
              ),
              const Text('Enable', style: TextStyle(fontSize: 13)),
              const SizedBox(width: 8),
              NativeSwitch(
                value: _travelDonorEnabled,
                activeThumbColor: SaviourPalette.shade50,
                activeTrackColor: travelBlue,
                onChanged: (val) => setState(() => _travelDonorEnabled = val),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Planning a trip? Mark yourself as available in another city to receive local donation requests while traveling.',
            style: TextStyle(
              fontSize: 13,
              color: SaviourPalette.shade800,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Destination City'),
          NativeTextField(
            controller: _destinationController,
            decoration: _inputDecoration('e.g. New York, NY'),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Date Range'),
          Row(
            children: [
              Expanded(child: _buildDateField(isFrom: true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Text('to', style: TextStyle(fontSize: 13)),
              ),
              Expanded(child: _buildDateField(isFrom: false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    return PlatformGestureSurface(
      onTap: () => _pickDate(isFrom: isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: SaviourPalette.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: SaviourPalette.shade300),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 13,
                color: date == null
                    ? SaviourPalette.shade600
                    : SaviourPalette.shade950,
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 16,
              color: SaviourPalette.shade700,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMedicalRestrictionsCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.medical_services_outlined,
            'MEDICAL RESTRICTIONS',
            primaryRed,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Existing Conditions or Medications'),
          NativeTextField(
            controller: _medicalNotesController,
            maxLines: 3,
            decoration: _inputDecoration(
              'Please list any ongoing medical conditions or medications that might affect blood donation eligibility.',
            ),
          ),
          const SizedBox(height: 14),
          _buildCheckboxChip(
            'Iron Deficiency History',
            _ironDeficiency,
            (val) => setState(() => _ironDeficiency = val!),
          ),
          const SizedBox(height: 10),
          _buildCheckboxChip(
            'Recent Tattoo/Piercing',
            _recentTattoo,
            (val) => setState(() => _recentTattoo = val!),
          ),
          const SizedBox(height: 10),
          _buildCheckboxChip(
            'International Travel (Last 6mo)',
            _internationalTravel,
            (val) => setState(() => _internationalTravel = val!),
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxChip(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return PlatformGestureSurface(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: SaviourPalette.shade300),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: NativeCheckbox(
                value: value,
                onChanged: onChanged,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                visualDensity: VisualDensity.compact,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(label, style: const TextStyle(fontSize: 13.5)),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyContactCard() {
    return _buildCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            Icons.contact_emergency_outlined,
            'EMERGENCY CONTACT',
            navyBlue,
          ),
          const SizedBox(height: 16),
          _fieldLabel('Full Name'),
          NativeTextField(
            controller: _contactNameController,
            decoration: _inputDecoration('Contact Person Name'),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Relationship'),
          NativeTextField(
            controller: _relationshipController,
            decoration: _inputDecoration('e.g. Spouse, Parent'),
          ),
          const SizedBox(height: 16),
          _fieldLabel('Phone Number'),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: SaviourPalette.shade300),
                ),
                child: const Icon(Icons.keyboard_arrow_down, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: NativeTextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration('(555) 000-0000'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: SaviourPalette.shade600, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SaviourPalette.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: SaviourPalette.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primaryRed, width: 1.5),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: NativeElevatedButton(
        onPressed: () {
          FeatureActions.notice(context, 'Your donor profile has been saved.');
          Navigator.of(context).maybePop();
        },
        style: NativeElevatedButton.styleFrom(
          backgroundColor: primaryRed,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Save and Complete Profile',
          style: TextStyle(
            color: SaviourPalette.shade50,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
      ),
    );
  }

  Widget _buildSkipButton() {
    return Center(
      child: NativeTextButton(
        onPressed: () => Navigator.of(context).maybePop(),
        child: const Text(
          'Skip for Now',
          style: TextStyle(color: SaviourPalette.shade800, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    const primaryRedLocal = primaryRed;
    return NativeBottomNavigationBar(
      currentIndex: _currentNavIndex,
      onTap: (index) => setState(() => _currentNavIndex = index),
      type: BottomNavigationBarType.fixed,
      selectedItemColor: primaryRedLocal,
      unselectedItemColor: SaviourPalette.shade800,
      showUnselectedLabels: true,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Home',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.water_drop_outlined),
          label: 'Requests',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.location_on_outlined),
          label: 'Camps',
        ),
        BottomNavigationBarItem(
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: primaryRedLocal,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: SaviourPalette.shade50,
              size: 20,
            ),
          ),
          label: 'Profile',
        ),
      ],
    );
  }
}
