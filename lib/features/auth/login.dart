import 'package:saviour/app_theme.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/features/auth/otp.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_form.dart';
import 'package:saviour/platform_widgets/platform_icons.dart';
import 'package:saviour/platform_widgets/platform_overlay.dart';
import 'package:saviour/platform_widgets/platform_route.dart';
import 'package:saviour/platform_widgets/platform_scaffold.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/services/saviour_api.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _scrollController = ScrollController();
  bool _acceptedPrivacy = true;
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _phoneController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final digits = _phoneController.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    if (!_acceptedPrivacy) {
      _message('Please accept the Terms and Privacy Policy to continue.');
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final challenge = await SaviourApi.instance.requestOtp('+91$digits');
      if (!mounted) return;
      await Navigator.of(context).push(
        PlatformPageRoute<void>(
          platform: ref.read(appPlatformProvider),
          builder: (_) => OtpVerificationScreen(
            phoneNumber: '+91 $digits',
            challengeId: challenge.id,
            resendSeconds: challenge.expiresIn.clamp(30, 120),
            demoCode: challenge.demoCode,
          ),
        ),
      );
    } on SaviourApiException catch (error) {
      if (mounted) _message(error.message);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _message(String message) => showPlatformSnackbar(
    context: context,
    platform: ref.read(appPlatformProvider),
    message: message,
  );

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformScaffold(
      backgroundColor: theme.surface,
      body: SafeArea(
        child: PlatformScrollbar(
          controller: _scrollController,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 860;
              return PlatformSingleChildScrollView(
                controller: _scrollController,
                physics: platformScrollPhysics(context),
                padding: EdgeInsets.symmetric(
                  horizontal: wide ? 48 : 22,
                  vertical: 28,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1080),
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Expanded(child: _WelcomePanel()),
                              const SizedBox(width: 64),
                              SizedBox(width: 430, child: _buildForm(theme)),
                            ],
                          )
                        : _buildForm(theme),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(PlatformThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: theme.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(theme.surfaceRadius + 4),
              ),
              child: Image.asset('logo/logo.png'),
            ),
            const SizedBox(width: 13),
            Text(
              'Vital Reserve',
              style: theme.text.titleLarge?.copyWith(
                color: theme.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 42),
        Text(
          'Welcome to Saviour',
          style: theme.text.headlineMedium?.copyWith(
            color: theme.onSurface,
            fontWeight: FontWeight.w800,
            fontSize: 32,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Your verified community for finding blood, donating safely, and showing up when it matters.',
          style: theme.text.bodyLarge?.copyWith(
            color: theme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 30),
        Text(
          'Mobile number',
          style: theme.text.titleSmall?.copyWith(
            color: theme.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 9),
        PlatformTextField(
          controller: _phoneController,
          placeholder: '98765 43210',
          prefix: Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, end: 8),
            child: Center(
              widthFactor: 1,
              child: Text(
                '🇮🇳  +91',
                style: theme.text.bodyMedium?.copyWith(
                  color: theme.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          keyboardType: TextInputType.phone,
          textInputAction: TextInputAction.done,
          autofocus: true,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          autofillHints: const [AutofillHints.telephoneNumber],
          onChanged: (_) {
            if (_error != null) setState(() => _error = null);
          },
          onSubmitted: (_) => _continue(),
        ),
        if (_error != null) ...[
          const SizedBox(height: 7),
          Text(
            _error!,
            style: theme.text.bodySmall?.copyWith(color: theme.destructive),
          ),
        ],
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PlatformCheckbox(
              value: _acceptedPrivacy,
              semanticLabel: 'Accept terms and privacy policy',
              onChanged: (value) =>
                  setState(() => _acceptedPrivacy = value ?? false),
            ),
            const SizedBox(width: 9),
            Expanded(
              child: Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text('I agree to the ', style: theme.text.bodySmall),
                  PlatformButton(
                    kind: PlatformButtonKind.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    onPressed: () => _showPolicy('Terms of Service'),
                    child: const Text('Terms of Service'),
                  ),
                  Text(' and ', style: theme.text.bodySmall),
                  PlatformButton(
                    kind: PlatformButtonKind.text,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 2,
                      vertical: 3,
                    ),
                    onPressed: () => _showPolicy('Privacy Policy'),
                    child: const Text('Privacy Policy'),
                  ),
                  Text('.', style: theme.text.bodySmall),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        PlatformButton.iconKind(
          iconKind: PlatformIconKind.forward,
          onPressed: _submitting ? null : _continue,
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 17),
          label: Text(_submitting ? 'Sending code…' : 'Send OTP'),
        ),
        const SizedBox(height: 13),
        PlatformButton.icon(
          icon: Icons.volunteer_activism_outlined,
          kind: PlatformButtonKind.outlined,
          onPressed: () => _message(
            'Verify your number first—we’ll create your donor profile next.',
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          label: const Text('Register as a new donor'),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_outline, size: 16, color: theme.onSurfaceVariant),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                'Encrypted • Private • Community verified',
                style: theme.text.bodySmall?.copyWith(
                  color: theme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _showPolicy(String title) => showPlatformSheet<void>(
    context: context,
    platform: ref.read(appPlatformProvider),
    builder: (context) {
      final theme = context.platformTheme;
      return ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(title, style: theme.text.titleLarge),
              const SizedBox(height: 12),
              Text(
                'Saviour only uses your information to coordinate verified blood donation and emergency requests. You control your availability and can remove your account data at any time.',
                style: theme.text.bodyMedium?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              PlatformButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _WelcomePanel extends StatelessWidget {
  const _WelcomePanel();

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return Container(
      height: 620,
      padding: const EdgeInsets.all(44),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.primary, SaviourPalette.shade900],
        ),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          _PanelPill(),
          Spacer(),
          Icon(Icons.favorite, size: 62, color: SaviourPalette.shade50),
          SizedBox(height: 26),
          Text(
            'One verified donor can change an entire family’s story.',
            style: TextStyle(
              color: SaviourPalette.shade50,
              fontSize: 39,
              height: 1.08,
              fontWeight: FontWeight.w800,
              letterSpacing: -1.1,
            ),
          ),
          SizedBox(height: 20),
          Text(
            'Find urgent requests nearby, know when you are eligible, and donate with confidence.',
            style: TextStyle(
              color: SaviourPalette.shade50,
              fontSize: 17,
              height: 1.5,
            ),
          ),
          Spacer(),
          Text(
            '24/7 emergency coordination  •  Verified community',
            style: TextStyle(color: SaviourPalette.shade50, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _PanelPill extends StatelessWidget {
  const _PanelPill();

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
    decoration: BoxDecoration(
      color: SaviourPalette.shade50,
      borderRadius: BorderRadius.circular(99),
    ),
    child: const Text(
      'LIFE-SAVING NETWORK',
      style: TextStyle(
        color: SaviourPalette.shade50,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    ),
  );
}
