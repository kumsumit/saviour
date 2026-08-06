import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_app_bar.dart';
import 'package:saviour/platform_widgets/platform_button.dart';
import 'package:saviour/platform_widgets/platform_form.dart';
import 'package:saviour/platform_widgets/platform_icon_button.dart';
import 'package:saviour/platform_widgets/platform_interaction.dart';
import 'package:saviour/platform_widgets/platform_navigation.dart';
import 'package:saviour/platform_widgets/platform_scaffold.dart';
import 'package:saviour/platform_widgets/platform_surface.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// Migration adapters for feature screens that were originally authored with
/// Material controls. They preserve the old constructor shape while routing
/// every interactive control through Saviour's native platform widgets.
class NativeScaffold extends StatelessWidget {
  const NativeScaffold({
    super.key,
    this.appBar,
    this.body,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.floatingActionButton,
    this.drawer,
  });

  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? drawer;

  @override
  Widget build(BuildContext context) {
    final bar = appBar;
    final content = Column(
      children: [
        Expanded(child: body ?? const SizedBox.shrink()),
        ?bottomNavigationBar,
      ],
    );
    if (bar is NativeAppBar) {
      return PlatformScaffold(
        backgroundColor: backgroundColor,
        appBar: PlatformAppBar(
          title: bar.title,
          leading: bar.leading,
          actions: bar.actions,
          centerTitle: bar.centerTitle,
          backgroundColor: bar.backgroundColor,
          automaticallyImplyLeading: bar.automaticallyImplyLeading,
        ),
        body: content,
        floatingActionButton: floatingActionButton,
      );
    }
    return PlatformScaffold(
      backgroundColor: backgroundColor,
      materialAppBar: bar,
      body: content,
      floatingActionButton: floatingActionButton,
    );
  }
}

class NativeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const NativeAppBar({
    super.key,
    this.title,
    this.leading,
    this.actions = const [],
    this.backgroundColor,
    this.centerTitle,
    this.elevation,
    this.scrolledUnderElevation,
    this.bottom,
    this.automaticallyImplyLeading = true,
    this.leadingWidth,
    this.titleSpacing,
  });

  final Widget? title;
  final Widget? leading;
  final List<Widget> actions;
  final Color? backgroundColor;
  final bool? centerTitle;
  final double? elevation;
  final double? scrolledUnderElevation;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;
  final double? leadingWidth;
  final double? titleSpacing;

  @override
  Size get preferredSize => Size.fromHeight(
    material.kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

class NativeElevatedButton extends StatelessWidget {
  const NativeElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : icon = null,
       label = null;

  const NativeElevatedButton.icon({
    super.key,
    required this.onPressed,
    required Widget this.icon,
    required Widget this.label,
    this.style,
  }) : child = null;

  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final material.ButtonStyle? style;

  static material.ButtonStyle styleFrom({
    Color? backgroundColor,
    Color? foregroundColor,
    double? elevation,
    EdgeInsetsGeometry? padding,
    OutlinedBorder? shape,
    Size? minimumSize,
  }) => material.ElevatedButton.styleFrom(
    backgroundColor: backgroundColor,
    foregroundColor: foregroundColor,
    elevation: elevation,
    padding: padding,
    shape: shape,
    minimumSize: minimumSize,
  );

  @override
  Widget build(BuildContext context) => PlatformButton(
    onPressed: onPressed,
    child:
        child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [icon!, const SizedBox(width: 8), label!],
        ),
  );
}

class NativeOutlinedButton extends StatelessWidget {
  const NativeOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  }) : icon = null,
       label = null;

  const NativeOutlinedButton.icon({
    super.key,
    required this.onPressed,
    required Widget this.icon,
    required Widget this.label,
    this.style,
  }) : child = null;

  final VoidCallback? onPressed;
  final Widget? child;
  final Widget? icon;
  final Widget? label;
  final material.ButtonStyle? style;

  static material.ButtonStyle styleFrom({
    Color? foregroundColor,
    Color? backgroundColor,
    material.BorderSide? side,
    EdgeInsetsGeometry? padding,
    OutlinedBorder? shape,
    Size? minimumSize,
  }) => material.OutlinedButton.styleFrom(
    foregroundColor: foregroundColor,
    backgroundColor: backgroundColor,
    side: side,
    padding: padding,
    shape: shape,
    minimumSize: minimumSize,
  );

  @override
  Widget build(BuildContext context) => PlatformButton(
    kind: PlatformButtonKind.outlined,
    onPressed: onPressed,
    child:
        child ??
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [icon!, const SizedBox(width: 8), label!],
        ),
  );
}

class NativeTextButton extends StatelessWidget {
  const NativeTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final material.ButtonStyle? style;

  static material.ButtonStyle styleFrom({
    Color? foregroundColor,
    EdgeInsetsGeometry? padding,
    Size? minimumSize,
    material.MaterialTapTargetSize? tapTargetSize,
  }) => material.TextButton.styleFrom(
    foregroundColor: foregroundColor,
    padding: padding,
    minimumSize: minimumSize,
    tapTargetSize: tapTargetSize,
  );

  @override
  Widget build(BuildContext context) => PlatformButton(
    kind: PlatformButtonKind.text,
    onPressed: onPressed,
    child: child,
  );
}

class NativeIconButton extends StatelessWidget {
  const NativeIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.tooltip,
    this.color,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final value = icon is Icon ? icon as Icon : null;
    return PlatformIconButton(
      icon: value?.icon ?? material.Icons.more_horiz,
      onPressed: onPressed,
      tooltip: tooltip,
      color: color ?? value?.color,
      size: value?.size ?? 22,
    );
  }
}

class NativeSwitch extends StatelessWidget {
  const NativeSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.activeColor,
    this.activeThumbColor,
    this.activeTrackColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? activeThumbColor;
  final Color? activeTrackColor;

  @override
  Widget build(BuildContext context) => PlatformSwitch(
    value: value,
    onChanged: onChanged,
    activeColor: activeTrackColor ?? activeColor ?? activeThumbColor,
  );
}

class NativeCheckbox extends StatelessWidget {
  const NativeCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.materialTapTargetSize,
    this.visualDensity,
    this.shape,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final material.MaterialTapTargetSize? materialTapTargetSize;
  final material.VisualDensity? visualDensity;
  final OutlinedBorder? shape;

  @override
  Widget build(BuildContext context) =>
      PlatformCheckbox(value: value, onChanged: onChanged);
}

class NativeTextField extends StatelessWidget {
  const NativeTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.decoration,
    this.keyboardType,
    this.textInputAction,
    this.style,
    this.autofocus = false,
    this.readOnly = false,
    this.obscureText = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.onChanged,
    this.onSubmitted,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final material.InputDecoration? decoration;
  final TextInputType? keyboardType;
  final material.TextInputAction? textInputAction;
  final TextStyle? style;
  final bool autofocus;
  final bool readOnly;
  final bool obscureText;
  final bool enabled;
  final int? maxLines;
  final int? minLines;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) => PlatformTextField(
    controller: controller,
    focusNode: focusNode,
    placeholder: decoration?.hintText ?? decoration?.labelText,
    prefix: decoration?.prefixIcon,
    suffix: decoration?.suffixIcon,
    keyboardType: keyboardType,
    textInputAction: textInputAction,
    style: style,
    autofocus: autofocus,
    readOnly: readOnly,
    obscureText: obscureText,
    enabled: enabled,
    maxLines: maxLines,
    minLines: minLines,
    onChanged: onChanged,
    onSubmitted: onSubmitted,
  );
}

class NativeBottomNavigationBar extends StatelessWidget {
  const NativeBottomNavigationBar({
    super.key,
    required this.items,
    this.currentIndex = 0,
    this.onTap,
    this.type,
    this.backgroundColor,
    this.selectedItemColor,
    this.unselectedItemColor,
    this.showUnselectedLabels,
    this.selectedLabelStyle,
    this.unselectedLabelStyle,
  });

  final List<material.BottomNavigationBarItem> items;
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final material.BottomNavigationBarType? type;
  final Color? backgroundColor;
  final Color? selectedItemColor;
  final Color? unselectedItemColor;
  final bool? showUnselectedLabels;
  final TextStyle? selectedLabelStyle;
  final TextStyle? unselectedLabelStyle;

  @override
  Widget build(BuildContext context) => PlatformNavigationBar(
    items: [
      for (final item in items)
        PlatformNavigationItem(
          icon: _icon(item.icon),
          selectedIcon: _icon(item.activeIcon),
          label: item.label ?? '',
        ),
    ],
    selectedIndex: currentIndex,
    onSelected: onTap ?? (_) {},
    backgroundColor: backgroundColor,
  );
}

IconData _icon(Widget widget) => widget is Icon && widget.icon != null
    ? widget.icon!
    : material.Icons.circle;

class NativeDrawer extends StatelessWidget {
  const NativeDrawer({
    super.key,
    required this.child,
    this.backgroundColor,
    this.width,
    this.shape,
  });

  final Widget child;
  final Color? backgroundColor;
  final double? width;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) => Align(
    alignment: AlignmentDirectional.centerStart,
    child: SizedBox(
      width: width,
      child: PlatformCard(
        color: backgroundColor,
        padding: EdgeInsets.zero,
        child: child,
      ),
    ),
  );
}

/// Platform-layer avatar used by feature screens. Keeping the shape here lets
/// each native shell supply its own surrounding typography and interaction.
class NativeAvatar extends StatelessWidget {
  const NativeAvatar({
    super.key,
    required this.radius,
    this.backgroundColor,
    this.child,
  });

  final double radius;
  final Color? backgroundColor;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
    width: radius * 2,
    height: radius * 2,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: backgroundColor ?? context.platformTheme.surfaceContainer,
      shape: BoxShape.circle,
    ),
    child: child,
  );
}

/// Custom bottom-bar surface for screens whose navigation layout is richer
/// than a standard tab bar.
class NativeBottomBar extends StatelessWidget {
  const NativeBottomBar({
    super.key,
    required this.child,
    this.color,
    this.padding = EdgeInsets.zero,
  });

  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) =>
      PlatformCard(color: color, padding: padding, child: child);
}

/// Circular prominent action that remains toolkit-independent in features.
class NativeFloatingActionButton extends StatelessWidget {
  const NativeFloatingActionButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) => PlatformGestureSurface(
    onTap: onPressed,
    borderRadius: BorderRadius.circular(28),
    child: Container(
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? context.platformTheme.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: context.platformTheme.outline.withValues(alpha: 0.35),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    ),
  );
}
