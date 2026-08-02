import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:saviour/providers/app_platform_provider.dart';

/// A platform-aware shortcut handler backed by Flutter's native shortcut
/// dispatch system.
class PlatformShortcutHandler extends StatelessWidget {
  const PlatformShortcutHandler({
    super.key,
    required this.shortcuts,
    required this.child,
    this.autofocus = true,
  });

  final Map<ShortcutActivator, VoidCallback> shortcuts;
  final Widget child;
  final bool autofocus;

  /// Creates the conventional primary shortcut for [key]:
  /// Command on Apple platforms, Control everywhere else.
  static SingleActivator primary(
    AppPlatform platform,
    LogicalKeyboardKey key, {
    bool shift = false,
    bool alt = false,
  }) {
    final apple = platform == AppPlatform.ios || platform == AppPlatform.macos;
    return SingleActivator(
      key,
      control: !apple,
      meta: apple,
      shift: shift,
      alt: alt,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      autofocus: autofocus,
      child: CallbackShortcuts(bindings: shortcuts, child: child),
    );
  }
}
