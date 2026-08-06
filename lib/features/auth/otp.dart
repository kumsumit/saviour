import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const SaviourApp());
}

class SaviourApp extends StatelessWidget {
  const SaviourApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sa',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF3F1F2),
      ),
      home: const OtpVerificationScreen(phoneNumber: '+1 000 000 0000'),
    );
  }
}

class OtpVerificationScreen extends StatefulWidget {
  final String phoneNumber;
  final int codeLength;
  final int resendSeconds;

  const OtpVerificationScreen({
    super.key,
    required this.phoneNumber,
    this.codeLength = 6,
    this.resendSeconds = 54,
  });

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  static const Color primaryRed = Color(0xFFB0102A);
  static const Color darkText = Color(0xFF221417);
  static const Color mutedText = Color(0xFF6B6265);
  static const Color borderColor = Color(0xFFE7C6CA);

  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  Timer? _timer;
  late int _secondsLeft;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.codeLength, (_) => TextEditingController());
    _focusNodes = List.generate(widget.codeLength, (_) => FocusNode());
    _secondsLeft = widget.resendSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() => _secondsLeft = widget.resendSeconds);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft <= 0) {
        timer.cancel();
      } else {
        setState(() => _secondsLeft--);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onChanged(int index, String value) {
    if (value.isNotEmpty) {
      if (index < widget.codeLength - 1) {
        _focusNodes[index + 1].requestFocus();
      } else {
        _focusNodes[index].unfocus();
      }
    }
  }

  void _onBackspace(int index) {
    if (index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
    }
  }

  String get _enteredCode =>
      _controllers.map((c) => c.text).join();

  void _verify() {
    if (_enteredCode.length == widget.codeLength) {
      // TODO: hook up verification logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verifying code: $_enteredCode')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the full code')),
      );
    }
  }

  void _resend() {
    if (_secondsLeft == 0) {
      // TODO: hook up resend OTP logic
      for (final c in _controllers) {
        c.clear();
      }
      _focusNodes.first.requestFocus();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top bar with back button
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    icon: const Icon(Icons.arrow_back, color: darkText),
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Verification Code',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: darkText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Subtitle
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.4,
                          color: mutedText,
                        ),
                        children: [
                          const TextSpan(text: "We've sent a 6-digit code to "),
                          TextSpan(
                            text: widget.phoneNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // OTP boxes
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(widget.codeLength, (index) {
                        return _OtpBox(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          borderColor: borderColor,
                          textColor: darkText,
                          onChanged: (value) => _onChanged(index, value),
                          onBackspace: () => _onBackspace(index),
                        );
                      }),
                    ),
                    const SizedBox(height: 20),

                    // Resend row
                    Row(
                      children: [
                        const Text(
                          "Didn't receive the code? ",
                          style: TextStyle(
                            fontSize: 14,
                            color: mutedText,
                          ),
                        ),
                        GestureDetector(
                          onTap: _resend,
                          child: Text(
                            _secondsLeft == 0
                                ? 'Resend code'
                                : 'Resend in $_formattedTime',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: _secondsLeft == 0
                                  ? primaryRed
                                  : mutedText,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Bottom button
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _verify,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'VERIFY & CONTINUE',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
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

class _OtpBox extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Color borderColor;
  final Color textColor;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.borderColor,
    required this.textColor,
    required this.onChanged,
    required this.onBackspace,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 56,
      child: RawKeyboardListener(
        focusNode: FocusNode(skipTraversal: true),
        onKey: (event) {
          if (event is RawKeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            counterText: '',
            hintText: '-',
            hintStyle: const TextStyle(color: Color(0xFFB9AEB1)),
            contentPadding: EdgeInsets.zero,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                  color: _OtpBoxFocusColor.color, width: 1.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _OtpBoxFocusColor {
  static const Color color = Color(0xFFB0102A);
}