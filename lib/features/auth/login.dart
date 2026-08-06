import 'package:flutter/material.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_icons.dart';
import 'package:saviour/platform_widgets/platform_phone_input.dart';
import 'package:saviour/platform_widgets/platform_scaffold.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  static final Country _defaultCountry = Country(
    name: 'India',
    alpha2Code: 'IN',
    alpha3Code: 'IND',
    dialCode: '+91',
  );

  static final List<Country> _countries = <Country>[_defaultCountry];

  @override
  void dispose() {
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;

    return PlatformScaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: PlatformScrollbar(
          controller: _scrollController,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: platformScrollPhysics(context),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 48),
                    Image.asset('logo/logo.png', width: 96, height: 96),
                    const SizedBox(height: 24),
                    Text(
                      'Saviour',
                      textAlign: TextAlign.center,
                      style: theme.text.headlineMedium?.copyWith(
                        color: theme.onSurface,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 32),
                    PlatformCard(
                      padding: const EdgeInsets.all(24),
                      color: theme.surfaceContainer,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Enter Phone Number',
                            style: theme.text.titleSmall?.copyWith(
                              color: theme.onSurface,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 10),
                          PlatformPhoneNumberInput(
                            countries: _countries,
                            defaultCountry: _defaultCountry,
                            controller: _phoneController,
                            label: 'Phone number',
                            onChanged: (_) {},
                            onValidated: (_) {},
                            onSubmitted: (_) => _sendOtp(),
                            autofocus: true,
                            textStyle: theme.text.bodyMedium?.copyWith(
                              color: theme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                            selectorTextStyle: theme.text.bodyMedium?.copyWith(
                              color: theme.onSurfaceVariant,
                              fontSize: 15,
                            ),
                            useRoundedContainer: true,
                            containerColor: theme.surface,
                            shadowColor: theme.onSurface.withValues(
                              alpha: 0.05,
                            ),
                            hintColor: theme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            iconColor: theme.onSurfaceVariant.withValues(
                              alpha: 0.7,
                            ),
                            borderColor: theme.outlineVariant,
                            borderWidth: 1.5,
                            borderRadius: theme.controlRadius,
                            dividerColor: theme.outlineVariant,
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            width: double.infinity,
                            child: PlatformButton.iconKind(
                              iconKind: PlatformIconKind.forward,
                              label: const Text('Send OTP'),
                              onPressed: _sendOtp,
                              accentColor: theme.primary,
                              borderRadius: BorderRadius.circular(
                                theme.controlRadius,
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 17,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _TermsNotice(
                            onTermsPressed: _openTerms,
                            onPrivacyPressed: _openPrivacyPolicy,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.verified_user_outlined,
                          size: 18,
                          color: theme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.shield_outlined,
                          size: 18,
                          color: theme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.lock_outline,
                          size: 18,
                          color: theme.onSurfaceVariant,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your data is encrypted and secure.',
                      textAlign: TextAlign.center,
                      style: theme.text.bodySmall?.copyWith(
                        color: theme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _sendOtp() {
    // TODO: Send an OTP for _phoneController.text.
  }

  void _openTerms() {
    // TODO: Open Terms and Conditions.
  }

  void _openPrivacyPolicy() {
    // TODO: Open the Privacy Policy.
  }

  void _register() {
    // TODO: Navigate to donor registration.
  }
}

class _TermsNotice extends StatelessWidget {
  const _TermsNotice({
    required this.onTermsPressed,
    required this.onPrivacyPressed,
  });

  final VoidCallback onTermsPressed;
  final VoidCallback onPrivacyPressed;

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    final textStyle = theme.text.bodySmall?.copyWith(
      color: theme.onSurfaceVariant,
      fontSize: 13,
      height: 1.5,
    );

    return Column(
      children: [
        Text('By continuing, you agree to our', style: textStyle),
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            PlatformButton(
              kind: PlatformButtonKind.text,
              onPressed: onTermsPressed,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: const Text('Terms and Conditions'),
            ),
            Text('and', style: textStyle),
            PlatformButton(
              kind: PlatformButtonKind.text,
              onPressed: onPrivacyPressed,
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: const Text('Privacy Policy'),
            ),
            Text('.', style: textStyle),
          ],
        ),
      ],
    );
  }
}
