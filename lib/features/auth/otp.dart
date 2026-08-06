import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:saviour/features/home/app_shell.dart';
import 'package:saviour/platform_widgets/platform_app_bar.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_icon_button.dart';
import 'package:saviour/platform_widgets/platform_icons.dart';
import 'package:saviour/platform_widgets/platform_list.dart';
import 'package:saviour/platform_widgets/platform_otp_input.dart';
import 'package:saviour/platform_widgets/platform_otp_timer_button.dart';
import 'package:saviour/platform_widgets/platform_overlay.dart';
import 'package:saviour/platform_widgets/platform_route.dart';
import 'package:saviour/platform_widgets/platform_scaffold.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/services/saviour_api.dart';

class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    required this.challengeId,
    this.codeLength = 6,
    this.resendSeconds = 30,
    this.demoCode,
  });

  final String phoneNumber;
  final String challengeId;
  final int codeLength;
  final int resendSeconds;
  final String? demoCode;

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _otpKey = GlobalKey<PlatformOtpInputState>();
  final _timerController = PlatformOtpTimerButtonController();
  String _code = '';
  late String _challengeId = widget.challengeId;
  bool _verifying = false;

  Future<void> _verify() async {
    if (_code.length != widget.codeLength) {
      showPlatformSnackbar(
        context: context,
        platform: ref.read(appPlatformProvider),
        message: 'Enter the complete ${widget.codeLength}-digit code.',
      );
      return;
    }
    setState(() => _verifying = true);
    try {
      await SaviourApi.instance.verifyOtp(
        challengeId: _challengeId,
        code: _code,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PlatformPageRoute<void>(
          platform: ref.read(appPlatformProvider),
          builder: (_) => const SaviourHomeShell(),
        ),
        (_) => false,
      );
    } on SaviourApiException catch (error) {
      if (!mounted) return;
      showPlatformSnackbar(
        context: context,
        platform: ref.read(appPlatformProvider),
        message: error.message,
      );
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _resend() async {
    _timerController.loading();
    try {
      final challenge = await SaviourApi.instance.requestOtp(
        widget.phoneNumber.replaceAll(' ', ''),
      );
      if (!mounted) return;
      _challengeId = challenge.id;
      _otpKey.currentState?.clear();
      setState(() => _code = '');
      _timerController.startTimer();
      showPlatformSnackbar(
        context: context,
        platform: ref.read(appPlatformProvider),
        message: 'A fresh verification code has been sent.',
      );
    } on SaviourApiException catch (error) {
      if (!mounted) return;
      _timerController.enableButton();
      showPlatformSnackbar(
        context: context,
        platform: ref.read(appPlatformProvider),
        message: error.message,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return PlatformScaffold(
      backgroundColor: theme.surface,
      appBar: PlatformAppBar(
        leading: PlatformIconButton.kind(
          iconKind: PlatformIconKind.back,
          tooltip: 'Back',
          onPressed: () => Navigator.maybePop(context),
        ),
      ),
      body: SafeArea(
        child: PlatformListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: 64,
                        height: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: .1),
                          borderRadius: BorderRadius.circular(
                            theme.surfaceRadius + 7,
                          ),
                        ),
                        child: Icon(
                          Icons.sms_outlined,
                          color: theme.primary,
                          size: 30,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Check your messages',
                      style: theme.text.headlineMedium?.copyWith(
                        color: theme.onSurface,
                        fontWeight: FontWeight.w800,
                        fontSize: 31,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text.rich(
                      TextSpan(
                        text:
                            'We sent a ${widget.codeLength}-digit verification code to ',
                        children: [
                          TextSpan(
                            text: widget.phoneNumber,
                            style: TextStyle(
                              color: theme.onSurface,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      style: theme.text.bodyLarge?.copyWith(
                        color: theme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 34),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final gap = 8.0;
                        final width =
                            (constraints.maxWidth -
                                gap * (widget.codeLength - 1)) /
                            widget.codeLength;
                        return PlatformOtpInput(
                          key: _otpKey,
                          length: widget.codeLength,
                          boxWidth: width.clamp(38, 54),
                          boxHeight: 60,
                          onChanged: (value) => setState(() => _code = value),
                          onCompleted: (_) => _verify(),
                        );
                      },
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Didn’t receive it?',
                            style: theme.text.bodyMedium?.copyWith(
                              color: theme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        PlatformOtpTimerButton(
                          controller: _timerController,
                          duration: widget.resendSeconds,
                          onPressed: _resend,
                          label: 'Resend code',
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    PlatformButton.iconKind(
                      iconKind: PlatformIconKind.forward,
                      onPressed: _verifying ? null : _verify,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 17,
                      ),
                      label: Text(
                        _verifying ? 'Verifying…' : 'Verify & continue',
                      ),
                    ),
                    const SizedBox(height: 20),
                    PlatformCard(
                      color: theme.surfaceContainer,
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: theme.primary),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.demoCode == null
                                  ? 'The code expires shortly. Never share it with another person.'
                                  : 'Local development code: ${widget.demoCode}',
                              style: theme.text.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
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
}
