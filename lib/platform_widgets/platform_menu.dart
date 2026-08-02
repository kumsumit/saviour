import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A command rendered inside a [PlatformContextMenu] or [PlatformMenuBar].
class PlatformMenuAction {
  const PlatformMenuAction({
    required this.label,
    this.icon,
    this.onPressed,
    this.isDestructive = false,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool isDestructive;

  bool get enabled => onPressed != null;
}

/// A top-level menu in a [PlatformMenuBar].
class PlatformMenu {
  const PlatformMenu({required this.label, required this.actions});

  final String label;
  final List<PlatformMenuAction> actions;
}

/// An attached platform-aware context or pull-down menu.
///
/// iOS wraps [child] in a native long-press context menu. Desktop platforms
/// expose their native attached menu button; [label] names that button.
class PlatformContextMenu extends ConsumerWidget {
  const PlatformContextMenu({
    super.key,
    required this.child,
    required this.actions,
    this.label = 'Actions',
    this.icon,
  }) : assert(actions.length > 0);

  final Widget child;
  final List<PlatformMenuAction> actions;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoContextMenu(
        actions: [
          for (final action in actions)
            cupertino.CupertinoContextMenuAction(
              isDestructiveAction: action.isDestructive,
              trailingIcon: action.icon,
              onPressed: action.enabled
                  ? () {
                      Navigator.of(context).pop();
                      action.onPressed?.call();
                    }
                  : null,
              child: Text(action.label),
            ),
        ],
        child: child,
      ),
      AppPlatform.macos => macos.MacosPulldownButton(
        title: icon == null ? label : null,
        icon: icon,
        items: _macosEntries(actions),
      ),
      AppPlatform.windows => fluent.DropDownButton(
        buttonBuilder: (context, onOpen) => GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onOpen,
          child: child,
        ),
        items: _fluentEntries(actions),
      ),
      AppPlatform.linux => yaru.YaruPopupMenuButton<PlatformMenuAction>(
        child: child,
        itemBuilder: (context) => _materialEntries(actions),
        onSelected: (action) => action.onPressed?.call(),
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.PopupMenuButton<PlatformMenuAction>(
        itemBuilder: (context) => _materialEntries(actions),
        onSelected: (action) => action.onPressed?.call(),
        child: child,
      ),
    };
  }
}

/// A horizontal platform-aware menu bar.
class PlatformMenuBar extends ConsumerWidget {
  const PlatformMenuBar({super.key, required this.menus})
    : assert(menus.length > 0);

  final List<PlatformMenu> menus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final menu in menus)
            cupertino.CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              onPressed: () => _showCupertinoMenu(context, menu.actions),
              child: Text(menu.label),
            ),
        ],
      ),
      AppPlatform.macos => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final menu in menus)
            macos.MacosPulldownButton(
              title: menu.label,
              items: _macosEntries(menu.actions),
            ),
        ],
      ),
      AppPlatform.windows => fluent.MenuBar(
        items: [
          for (final menu in menus)
            fluent.MenuBarItem(
              title: menu.label,
              items: _fluentEntries(menu.actions),
            ),
        ],
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.MenuBar(
        children: [
          for (final menu in menus)
            material.SubmenuButton(
              menuChildren: _materialButtons(menu.actions),
              child: Text(menu.label),
            ),
        ],
      ),
    };
  }
}

Future<void> _showCupertinoMenu(
  BuildContext context,
  List<PlatformMenuAction> actions,
) {
  return cupertino.showCupertinoModalPopup<void>(
    context: context,
    builder: (context) => cupertino.CupertinoActionSheet(
      actions: [
        for (final action in actions)
          if (action.enabled)
            cupertino.CupertinoActionSheetAction(
              isDestructiveAction: action.isDestructive,
              onPressed: () {
                Navigator.of(context).pop();
                action.onPressed?.call();
              },
              child: Text(action.label),
            ),
      ],
    ),
  );
}

List<macos.MacosPulldownMenuEntry> _macosEntries(
  List<PlatformMenuAction> actions,
) {
  return [
    for (final action in actions)
      macos.MacosPulldownMenuItem(
        enabled: action.enabled,
        onTap: action.onPressed,
        title: _MenuLabel(action: action),
      ),
  ];
}

List<fluent.MenuFlyoutItemBase> _fluentEntries(
  List<PlatformMenuAction> actions,
) {
  return [
    for (final action in actions)
      fluent.MenuFlyoutItem(
        leading: action.icon == null ? null : Icon(action.icon),
        text: Text(action.label),
        onPressed: action.onPressed,
      ),
  ];
}

List<material.PopupMenuEntry<PlatformMenuAction>> _materialEntries(
  List<PlatformMenuAction> actions,
) {
  return [
    for (final action in actions)
      material.PopupMenuItem<PlatformMenuAction>(
        value: action,
        enabled: action.enabled,
        child: _MenuLabel(action: action),
      ),
  ];
}

List<Widget> _materialButtons(List<PlatformMenuAction> actions) {
  return [
    for (final action in actions)
      material.MenuItemButton(
        leadingIcon: action.icon == null ? null : Icon(action.icon),
        onPressed: action.onPressed,
        child: Text(action.label),
      ),
  ];
}

class _MenuLabel extends StatelessWidget {
  const _MenuLabel({required this.action});

  final PlatformMenuAction action;

  @override
  Widget build(BuildContext context) {
    final color = action.isDestructive
        ? context.platformTheme.destructive
        : null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (action.icon != null) ...[
          Icon(action.icon, size: 16, color: color),
          const SizedBox(width: 8),
        ],
        Text(action.label, style: TextStyle(color: color)),
      ],
    );
  }
}
