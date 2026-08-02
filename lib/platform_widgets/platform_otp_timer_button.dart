import 'dart:async';

import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:flutter/material.dart';

export 'package:saviour/platform_widgets/platform_button.dart'
    show PlatformButtonKind;

enum _OtpTimerState { countdown, ready, loading }

class PlatformOtpTimerButton extends StatefulWidget {
  const PlatformOtpTimerButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.duration = 120,
    this.kind = PlatformButtonKind.text,
    this.controller,
  });

  final VoidCallback onPressed;
  final String label;
  final int duration;
  final PlatformButtonKind kind;
  final PlatformOtpTimerButtonController? controller;

  @override
  State<PlatformOtpTimerButton> createState() => _PlatformOtpTimerButtonState();
}

class _PlatformOtpTimerButtonState extends State<PlatformOtpTimerButton> {
  Timer? _timer;
  int _counter = 0;
  _OtpTimerState _state = _OtpTimerState.countdown;

  @override
  void initState() {
    super.initState();
    _startTimer();
    widget.controller?._attach(_startTimer, _setLoading, _setReady);
  }

  void _startTimer() {
    _timer?.cancel();
    _counter = widget.duration;
    setState(() => _state = _OtpTimerState.countdown);
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_counter <= 1) {
        t.cancel();
        if (mounted) setState(() => _state = _OtpTimerState.ready);
      } else {
        if (mounted) setState(() => _counter--);
      }
    });
  }

  void _setLoading() => setState(() => _state = _OtpTimerState.loading);
  void _setReady() => setState(() => _state = _OtpTimerState.ready);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.platformTheme;
    return switch (_state) {
      _OtpTimerState.countdown => PlatformButton(
        kind: widget.kind,
        onPressed: null,
        child: Text(
          '${widget.label}  $_counter s',
          style: TextStyle(color: theme.onSurfaceVariant),
        ),
      ),
      _OtpTimerState.loading => PlatformButton(
        kind: widget.kind,
        onPressed: null,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label),
            const SizedBox(width: 8),
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.primary,
              ),
            ),
          ],
        ),
      ),
      _OtpTimerState.ready => PlatformButton(
        kind: widget.kind,
        onPressed: () {
          widget.onPressed();
          if (widget.controller == null) _startTimer();
        },
        child: Text(widget.label),
      ),
    };
  }
}

class PlatformOtpTimerButtonController {
  late VoidCallback _startTimer;
  late VoidCallback _setLoading;
  late VoidCallback _setReady;

  void _attach(
    VoidCallback startTimer,
    VoidCallback setLoading,
    VoidCallback setReady,
  ) {
    _startTimer = startTimer;
    _setLoading = setLoading;
    _setReady = setReady;
  }

  void startTimer() => _startTimer();
  void loading() => _setLoading();
  void enableButton() => _setReady();
}
