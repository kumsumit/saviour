import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// Drives a [PlatformOtpTimerButton]'s countdown from outside the widget.
class PlatformOtpTimerController {
  VoidCallback? _start;

  void startTimer() => _start?.call();

  void _detach(VoidCallback listener) {
    if (_start == listener) _start = null;
  }
}

/// A minimal, platform-aware OTP resend button: a [PlatformButton] that shows a
/// label and a countdown, used by the login flow.
class PlatformOtpTimerButton extends StatefulWidget {
  const PlatformOtpTimerButton({
    super.key,
    required this.controller,
    required this.onPressed,
    required this.label,
    required this.duration,
  });

  final PlatformOtpTimerController controller;
  final Future<void> Function()? onPressed;
  final String label;
  final int duration;

  @override
  State<PlatformOtpTimerButton> createState() => _PlatformOtpTimerButtonState();
}

class _PlatformOtpTimerButtonState extends State<PlatformOtpTimerButton> {
  Timer? _timer;
  int _remaining = 0;

  @override
  void initState() {
    super.initState();
    widget.controller._start = _start;
  }

  @override
  void didUpdateWidget(PlatformOtpTimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    oldWidget.controller._detach(_start);
    widget.controller._start = _start;
  }

  @override
  void dispose() {
    widget.controller._detach(_start);
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _timer?.cancel();
    if (widget.duration <= 0) {
      if (_remaining != 0) setState(() => _remaining = 0);
      return;
    }
    setState(() => _remaining = widget.duration);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() => _remaining = 0);
      } else {
        setState(() => _remaining--);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final enabled = _remaining == 0 && widget.onPressed != null;
    return PlatformButton(
      kind: PlatformButtonKind.text,
      accentColor: context.platformTheme.primary,
      onPressed: enabled
          ? () async {
              await widget.onPressed?.call();
              _start();
            }
          : null,
      child: Text(
        _remaining == 0 ? widget.label : '${widget.label} ($_remaining)',
      ),
    );
  }
}

enum ButtonState { enableButton, loading, timer }

enum ButtonType { elevatedButton, textButton, outlinedButton }

/// A richer OTP/resend button with a built-in countdown that also exposes a
/// loading state and selectable button kinds. It renders through the
/// platform-aware [PlatformButton] / [PlatformProgressIndicator] building
/// blocks, so it adopts the native look of iOS, macOS, Windows, Linux and
/// Android instead of forcing a single Material appearance.
class OtpTimerButton extends StatefulWidget {
  /// Called when the button is tapped or otherwise activated.
  final VoidCallback? onPressed;

  /// The button text.
  final Text text;

  /// The loading indicator shown while [ButtonState.loading].
  ///
  /// When null a platform-appropriate [PlatformProgressIndicator] is used.
  final Widget? loadingIndicator;

  /// Length of the timer in seconds.
  final int duration;

  /// Manual control of the button state [ButtonState].
  ///
  /// When the controller is not null, the auto-start timer is disabled on a
  /// pressed button.
  final OtpTimerButtonController? controller;

  /// Height of the button.
  final double? height;

  /// Accent / background color of the button.
  final Color? backgroundColor;

  /// Color of the loading indicator.
  final Color? loadingIndicatorColor;

  /// Button type: elevated_button, text_button, outlined_button [ButtonType].
  final ButtonType buttonType;

  /// The radius of the button border.
  final double? radius;

  const OtpTimerButton({
    super.key,
    required this.onPressed,
    required this.text,
    this.loadingIndicator,
    required this.duration,
    this.controller,
    this.height,
    this.backgroundColor,
    this.loadingIndicatorColor,
    this.buttonType = ButtonType.elevatedButton,
    this.radius,
  });

  @override
  State<OtpTimerButton> createState() => _OtpTimerButtonState();
}

class _OtpTimerButtonState extends State<OtpTimerButton> {
  Timer? _timer;
  int _counter = 0;
  ButtonState _state = ButtonState.timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
    widget.controller?._addListeners(_startTimer, _loading, _enableButton);
  }

  @override
  void didUpdateWidget(OtpTimerButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._removeListeners(
        _startTimer,
        _loading,
        _enableButton,
      );
      widget.controller?._addListeners(_startTimer, _loading, _enableButton);
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _state = ButtonState.timer;
    _counter = widget.duration.clamp(0, 1 << 31);

    setState(() {});

    if (_counter == 0) {
      _enableButton();
      return;
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (_counter <= 1) {
        _state = ButtonState.enableButton;
        setState(() {
          _counter = 0;
          timer.cancel();
        });
      } else {
        setState(() {
          _counter--;
        });
      }
    });
  }

  void _loading() {
    _timer?.cancel();
    _state = ButtonState.loading;
    setState(() {});
  }

  void _enableButton() {
    _timer?.cancel();
    _state = ButtonState.enableButton;
    setState(() {});
  }

  PlatformButtonKind get _kind => switch (widget.buttonType) {
    ButtonType.elevatedButton => PlatformButtonKind.primary,
    ButtonType.textButton => PlatformButtonKind.text,
    ButtonType.outlinedButton => PlatformButtonKind.outlined,
  };

  Widget _childBuilder() {
    switch (_state) {
      case ButtonState.enableButton:
        return widget.text;
      case ButtonState.loading:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.text,
            const SizedBox(width: 10),
            widget.loadingIndicator ??
                PlatformProgressIndicator(
                  size: 20,
                  color: widget.loadingIndicatorColor,
                ),
          ],
        );
      case ButtonState.timer:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            widget.text,
            const SizedBox(width: 10),
            Text('$_counter', style: widget.text.style),
          ],
        );
    }
  }

  void _onPressedButton() {
    widget.onPressed?.call();
    if (widget.controller == null) {
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final button = PlatformButton(
      kind: _kind,
      accentColor: widget.backgroundColor,
      onPressed: _state == ButtonState.enableButton ? _onPressedButton : null,
      borderRadius: widget.radius != null
          ? BorderRadius.circular(widget.radius!)
          : null,
      child: _childBuilder(),
    );

    return widget.height != null
        ? SizedBox(height: widget.height, child: button)
        : button;
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.controller?._removeListeners(_startTimer, _loading, _enableButton);
    super.dispose();
  }
}

class OtpTimerButtonController {
  VoidCallback? _startTimerListener;
  VoidCallback? _loadingListener;
  VoidCallback? _enableButtonListener;

  void _addListeners(
    VoidCallback startTimerListener,
    VoidCallback loadingListener,
    VoidCallback enableButtonListener,
  ) {
    _startTimerListener = startTimerListener;
    _loadingListener = loadingListener;
    _enableButtonListener = enableButtonListener;
  }

  void _removeListeners(
    VoidCallback startTimerListener,
    VoidCallback loadingListener,
    VoidCallback enableButtonListener,
  ) {
    if (_startTimerListener == startTimerListener) _startTimerListener = null;
    if (_loadingListener == loadingListener) _loadingListener = null;
    if (_enableButtonListener == enableButtonListener) {
      _enableButtonListener = null;
    }
  }

  /// Notify listener to start the timer.
  void startTimer() => _startTimerListener?.call();

  /// Notify listener to show loading.
  void loading() => _loadingListener?.call();

  /// Notify listener to enable button.
  void enableButton() => _enableButtonListener?.call();
}
