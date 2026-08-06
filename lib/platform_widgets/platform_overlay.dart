import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:saviour/platform_widgets/platform_button.dart';

/// Shows [builder] in the platform's modal sheet surface — a Cupertino popup on
/// iOS, a `MacosSheet` on macOS, a Fluent `ContentDialog` on Windows, a Material
/// dialog on Linux and a draggable bottom sheet on Android / web / fuchsia.
Future<T?> showPlatformSheet<T>({
  required BuildContext context,
  required AppPlatform platform,
  required WidgetBuilder builder,
}) {
  return switch (platform) {
    AppPlatform.ios => cupertino.showCupertinoModalPopup<T>(
      context: context,
      builder: (context) => cupertino.CupertinoPopupSurface(
        child: SafeArea(child: builder(context)),
      ),
    ),
    AppPlatform.macos => macos.showMacosSheet<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: cupertino.CupertinoLocalizations.of(
        context,
      ).modalBarrierDismissLabel,
      builder: (context) => macos.MacosSheet(child: builder(context)),
    ),
    AppPlatform.windows => fluent.showDialog<T>(
      context: context,
      barrierDismissible: true,
      builder: (context) => fluent.ContentDialog(
        constraints: const BoxConstraints(maxWidth: 520),
        content: builder(context),
      ),
    ),
    AppPlatform.linux => material.showDialog<T>(
      context: context,
      builder: (context) => material.Dialog(child: builder(context)),
    ),
    AppPlatform.android ||
    AppPlatform.web ||
    AppPlatform.fuchsia => material.showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      backgroundColor: context.platformTheme.surface,
      builder: builder,
    ),
  };
}

Future<DateTime?> showPlatformDatePicker({
  required BuildContext context,
  required AppPlatform platform,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  if (platform == AppPlatform.android ||
      platform == AppPlatform.linux ||
      platform == AppPlatform.web ||
      platform == AppPlatform.fuchsia) {
    return material.showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
  }
  return showPlatformSheet<DateTime>(
    context: context,
    platform: platform,
    builder: (_) => _PlatformDatePickerPanel(
      platform: platform,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    ),
  );
}

class _PlatformDatePickerPanel extends StatefulWidget {
  const _PlatformDatePickerPanel({
    required this.platform,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
  });

  final AppPlatform platform;
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_PlatformDatePickerPanel> createState() =>
      _PlatformDatePickerPanelState();
}

class _PlatformDatePickerPanelState extends State<_PlatformDatePickerPanel> {
  late DateTime _selected = widget.initialDate;

  @override
  Widget build(BuildContext context) {
    final picker = switch (widget.platform) {
      AppPlatform.ios => SizedBox(
        height: 220,
        child: cupertino.CupertinoDatePicker(
          mode: cupertino.CupertinoDatePickerMode.date,
          initialDateTime: widget.initialDate,
          minimumDate: widget.firstDate,
          maximumDate: widget.lastDate,
          onDateTimeChanged: (value) => _selected = value,
        ),
      ),
      AppPlatform.macos => macos.MacosDatePicker(
        initialDate: widget.initialDate,
        onDateChanged: (value) => _selected = value,
      ),
      AppPlatform.windows => fluent.DatePicker(
        selected: widget.initialDate,
        startDate: widget.firstDate,
        endDate: widget.lastDate,
        onChanged: (value) => setState(() => _selected = value),
      ),
      AppPlatform.android ||
      AppPlatform.linux ||
      AppPlatform.web ||
      AppPlatform.fuchsia => const SizedBox.shrink(),
    };
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 440),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            picker,
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: PlatformButton(
                    kind: PlatformButtonKind.outlined,
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: PlatformButton(
                    onPressed: () => Navigator.pop(context, _selected),
                    child: const Text('Done'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Shows a transient message in the platform's native notification surface — a
/// Fluent `InfoBar` on Windows, a floating banner on iOS / macOS, and a Material
/// `SnackBar` on Android / web / Linux.
void showPlatformSnackbar({
  required BuildContext context,
  required AppPlatform platform,
  required String message,
}) {
  switch (platform) {
    case AppPlatform.windows:
      fluent.displayInfoBar(
        context,
        builder: (context, close) =>
            fluent.InfoBar.info(title: Text(message), onClose: close),
      );
      break;
    case AppPlatform.ios:
      _showAppleNotification(context, message, isMacos: false);
      break;
    case AppPlatform.macos:
      _showAppleNotification(context, message, isMacos: true);
      break;
    case AppPlatform.android:
    case AppPlatform.web:
    case AppPlatform.fuchsia:
      material.ScaffoldMessenger.of(
        context,
      ).showSnackBar(material.SnackBar(content: Text(message)));
      break;
    case AppPlatform.linux:
      // Yaru supplies its desktop snackbar styling through the Material theme.
      material.ScaffoldMessenger.of(
        context,
      ).showSnackBar(material.SnackBar(content: Text(message)));
      break;
  }
}

void _showAppleNotification(
  BuildContext context,
  String message, {
  required bool isMacos,
}) {
  final overlay = Overlay.of(context);
  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) {
      final theme = context.platformTheme;
      final content = Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(color: theme.onSurface),
        ),
      );

      return Positioned(
        left: 20,
        right: 20,
        bottom: MediaQuery.paddingOf(context).bottom + 20,
        child: SafeArea(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: isMacos
                ? DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: theme.onSurface.withValues(alpha: 0.15),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: GlassSurface(
                      borderRadius: BorderRadius.circular(8),
                      tint: theme.surface,
                      child: content,
                    ),
                  )
                : cupertino.CupertinoPopupSurface(child: content),
          ),
        ),
      );
    },
  );

  overlay.insert(entry);
  Future<void>.delayed(const Duration(seconds: 3), () {
    if (entry.mounted) entry.remove();
  });
}

/// An action button in a [showPlatformDialog].
class PlatformDialogAction {
  const PlatformDialogAction({
    required this.label,
    this.onPressed,
    this.isDefault = false,
    this.isDestructive = false,
  });

  final String label;

  /// Called after the dialog is dismissed when this action is tapped.
  final VoidCallback? onPressed;

  /// Whether this is the confirming / default action (emphasized).
  final bool isDefault;

  /// Whether this action is destructive (shown in red where supported).
  final bool isDestructive;
}

/// Shows a native alert dialog — `CupertinoAlertDialog` on iOS, `MacosAlertDialog`
/// on macOS, Fluent `ContentDialog` on Windows and Material `AlertDialog` on
/// Linux / Android / web / fuchsia.
///
/// macOS shows at most two actions (a primary and an optional secondary); on
/// other platforms every action is rendered. Each action dismisses the dialog,
/// then invokes its [PlatformDialogAction.onPressed].
Future<void> showPlatformDialog({
  required BuildContext context,
  required AppPlatform platform,
  required String title,
  String? message,
  required List<PlatformDialogAction> actions,
  Widget? icon,
}) {
  assert(actions.isNotEmpty, 'A platform dialog needs at least one action.');
  if (actions.isEmpty) return Future.value();

  void handle(BuildContext ctx, PlatformDialogAction action) {
    Navigator.of(ctx).pop();
    action.onPressed?.call();
  }

  final destructiveColor = context.platformTheme.destructive;

  switch (platform) {
    case AppPlatform.ios:
      return cupertino.showCupertinoDialog<void>(
        context: context,
        builder: (ctx) => cupertino.CupertinoAlertDialog(
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            for (final action in actions)
              cupertino.CupertinoDialogAction(
                isDefaultAction: action.isDefault,
                isDestructiveAction: action.isDestructive,
                onPressed: () => handle(ctx, action),
                child: Text(action.label),
              ),
          ],
        ),
      );

    case AppPlatform.macos:
      final primary = actions.last;
      final secondary = actions.length > 1 ? actions[actions.length - 2] : null;
      return macos.showMacosAlertDialog<void>(
        context: context,
        builder: (ctx) => macos.MacosAlertDialog(
          appIcon:
              icon ??
              const Icon(cupertino.CupertinoIcons.info_circle_fill, size: 56),
          title: Text(title),
          message: Text(message ?? ''),
          primaryButton: macos.PushButton(
            controlSize: macos.ControlSize.large,
            onPressed: () => handle(ctx, primary),
            child: Text(primary.label),
          ),
          secondaryButton: secondary == null
              ? null
              : macos.PushButton(
                  controlSize: macos.ControlSize.large,
                  secondary: true,
                  onPressed: () => handle(ctx, secondary),
                  child: Text(secondary.label),
                ),
        ),
      );

    case AppPlatform.windows:
      return fluent.showDialog<void>(
        context: context,
        builder: (ctx) => fluent.ContentDialog(
          constraints: const BoxConstraints(maxWidth: 420),
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            for (final action in actions)
              action.isDefault
                  ? fluent.FilledButton(
                      onPressed: () => handle(ctx, action),
                      child: Text(action.label),
                    )
                  : fluent.Button(
                      onPressed: () => handle(ctx, action),
                      child: Text(action.label),
                    ),
          ],
        ),
      );

    case AppPlatform.linux:
    case AppPlatform.android:
    case AppPlatform.web:
    case AppPlatform.fuchsia:
      return material.showDialog<void>(
        context: context,
        builder: (ctx) => material.AlertDialog(
          title: Text(title),
          content: message == null ? null : Text(message),
          actions: [
            for (final action in actions)
              material.TextButton(
                onPressed: () => handle(ctx, action),
                style: action.isDestructive
                    ? material.TextButton.styleFrom(
                        foregroundColor: destructiveColor,
                      )
                    : null,
                child: Text(action.label),
              ),
          ],
        ),
      );
  }
}

/// An item in a [showPlatformMenu].
class PlatformMenuItem<T> {
  const PlatformMenuItem({
    required this.label,
    this.value,
    this.icon,
    this.isDestructive = false,
  });

  final String label;

  /// The value returned by [showPlatformMenu] when this item is selected.
  final T? value;

  final IconData? icon;

  /// Whether the item is destructive (shown in red where supported).
  final bool isDestructive;
}

/// Shows a popup / context menu and resolves to the selected item's value.
///
/// iOS uses a native `CupertinoActionSheet`; the other platforms use a Material
/// popup menu anchored to [globalPosition] (or to the [context] widget when
/// omitted), since Fluent flyouts / macOS pull-downs require an attached
/// controller rather than an imperative show.
Future<T?> showPlatformMenu<T>({
  required BuildContext context,
  required AppPlatform platform,
  required List<PlatformMenuItem<T>> items,
  Offset? globalPosition,
}) {
  final destructiveColor = context.platformTheme.destructive;

  if (platform == AppPlatform.ios) {
    return cupertino.showCupertinoModalPopup<T>(
      context: context,
      builder: (ctx) => cupertino.CupertinoActionSheet(
        actions: [
          for (final item in items)
            cupertino.CupertinoActionSheetAction(
              isDestructiveAction: item.isDestructive,
              onPressed: () => Navigator.of(ctx).pop(item.value),
              child: Text(item.label),
            ),
        ],
      ),
    );
  }

  final overlay = Overlay.of(context).context.findRenderObject();
  if (overlay is! RenderBox) return Future.value();
  final RelativeRect position;
  if (globalPosition != null) {
    position = RelativeRect.fromRect(
      globalPosition & const Size(40, 40),
      Offset.zero & overlay.size,
    );
  } else {
    final box = context.findRenderObject();
    if (box is! RenderBox) return Future.value();
    position = RelativeRect.fromRect(
      Rect.fromPoints(
        box.localToGlobal(Offset.zero, ancestor: overlay),
        box.localToGlobal(box.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
  }

  final onSurface = context.platformTheme.onSurface;
  return material.showMenu<T>(
    context: context,
    position: position,
    items: [
      for (final item in items)
        material.PopupMenuItem<T>(
          value: item.value,
          child: Row(
            children: [
              if (item.icon != null) ...[
                Icon(
                  item.icon,
                  size: 18,
                  color: item.isDestructive ? destructiveColor : onSurface,
                ),
                const SizedBox(width: 12),
              ],
              Text(
                item.label,
                style: TextStyle(
                  color: item.isDestructive ? destructiveColor : onSurface,
                ),
              ),
            ],
          ),
        ),
    ],
  );
}
