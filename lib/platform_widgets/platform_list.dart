import 'package:saviour/app_theme.dart';
import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/rendering.dart' show ScrollCacheExtent;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_scroll.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A platform-aware list row with native layout and interaction behavior.
class PlatformListTile extends ConsumerWidget {
  const PlatformListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.enabled = true,
    this.selected = false,
    this.contentPadding,
    this.semanticLabel,
  });

  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool enabled;
  final bool selected;
  final EdgeInsetsGeometry? contentPadding;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveOnTap = enabled ? onTap : null;
    final effectiveOnLongPress = enabled ? onLongPress : null;
    final selectedColor = context.platformTheme.primary.withValues(alpha: 0.12);

    return Semantics(
      label: semanticLabel,
      enabled: enabled,
      selected: selected,
      button: effectiveOnTap != null,
      child: switch (ref.watch(appPlatformProvider)) {
        AppPlatform.ios => cupertino.CupertinoListTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          padding: contentPadding,
          backgroundColor: selected ? selectedColor : null,
          onTap: effectiveOnTap,
        ),
        AppPlatform.macos => ColoredBox(
          color: selected ? selectedColor : SaviourPalette.transparent,
          child: Padding(
            padding:
                contentPadding ??
                const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: macos.MacosListTile(
              leading: leading,
              title: _TitleWithTrailing(title: title, trailing: trailing),
              subtitle: subtitle,
              mouseCursor: effectiveOnTap == null
                  ? MouseCursor.defer
                  : SystemMouseCursors.click,
              onClick: effectiveOnTap,
              onLongPress: effectiveOnLongPress,
            ),
          ),
        ),
        AppPlatform.windows =>
          selected
              ? fluent.ListTile.selectable(
                  title: title,
                  subtitle: subtitle,
                  leading: leading,
                  trailing: trailing,
                  selected: true,
                  contentPadding:
                      contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  semanticLabel: semanticLabel,
                  onPressed: effectiveOnTap,
                )
              : fluent.ListTile(
                  title: title,
                  subtitle: subtitle,
                  leading: leading,
                  trailing: trailing,
                  contentPadding:
                      contentPadding ??
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  semanticLabel: semanticLabel,
                  onPressed: effectiveOnTap,
                ),
        AppPlatform.linux => ColoredBox(
          color: selected ? selectedColor : SaviourPalette.transparent,
          child: yaru.YaruListTile(
            title: title,
            subtitle: subtitle,
            leading: leading,
            trailing: trailing,
            enabled: enabled,
            contentPadding: contentPadding,
            mouseCursor: effectiveOnTap == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            onTap: effectiveOnTap,
          ),
        ),
        AppPlatform.android ||
        AppPlatform.web ||
        AppPlatform.fuchsia => material.ListTile(
          title: title,
          subtitle: subtitle,
          leading: leading,
          trailing: trailing,
          enabled: enabled,
          selected: selected,
          contentPadding: contentPadding,
          onTap: effectiveOnTap,
          onLongPress: effectiveOnLongPress,
        ),
      },
    );
  }
}

class _TitleWithTrailing extends StatelessWidget {
  const _TitleWithTrailing({required this.title, required this.trailing});

  final Widget title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    if (trailing == null) return title;
    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: 8),
        trailing!,
      ],
    );
  }
}

enum _PlatformListViewKind { children, builder, separated }

/// A [ListView] that defaults to platform-appropriate scroll physics.
class PlatformListView extends StatelessWidget {
  const PlatformListView({
    super.key,
    this.children = const [],
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.scrollCacheExtent,
    this.showScrollbar,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  }) : _kind = _PlatformListViewKind.children,
       itemBuilder = null,
       separatorBuilder = null,
       itemCount = null;

  const PlatformListView.builder({
    super.key,
    required this.itemBuilder,
    required this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.scrollCacheExtent,
    this.showScrollbar,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  }) : _kind = _PlatformListViewKind.builder,
       children = const [],
       separatorBuilder = null;

  const PlatformListView.separated({
    super.key,
    required this.itemBuilder,
    required this.separatorBuilder,
    required this.itemCount,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.controller,
    this.primary,
    this.physics,
    this.padding,
    this.shrinkWrap = false,
    this.scrollCacheExtent,
    this.showScrollbar,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.clipBehavior = Clip.hardEdge,
  }) : _kind = _PlatformListViewKind.separated,
       children = const [];

  final _PlatformListViewKind _kind;
  final List<Widget> children;
  final NullableIndexedWidgetBuilder? itemBuilder;
  final IndexedWidgetBuilder? separatorBuilder;
  final int? itemCount;
  final Axis scrollDirection;
  final bool reverse;
  final ScrollController? controller;
  final bool? primary;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool shrinkWrap;
  final ScrollCacheExtent? scrollCacheExtent;
  final bool? showScrollbar;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final effectivePhysics = physics ?? platformScrollPhysics(context);
    final list = switch (_kind) {
      _PlatformListViewKind.children => ListView(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: effectivePhysics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        scrollCacheExtent: scrollCacheExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        children: children,
      ),
      _PlatformListViewKind.builder => ListView.builder(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: effectivePhysics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        scrollCacheExtent: scrollCacheExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        itemBuilder: itemBuilder!,
        itemCount: itemCount,
      ),
      _PlatformListViewKind.separated => ListView.separated(
        scrollDirection: scrollDirection,
        reverse: reverse,
        controller: controller,
        primary: primary,
        physics: effectivePhysics,
        padding: padding,
        shrinkWrap: shrinkWrap,
        scrollCacheExtent: scrollCacheExtent,
        keyboardDismissBehavior: keyboardDismissBehavior,
        clipBehavior: clipBehavior,
        itemBuilder: itemBuilder!,
        separatorBuilder: separatorBuilder!,
        itemCount: itemCount!,
      ),
    };

    if (showScrollbar == false) return list;
    return PlatformScrollbar(controller: controller, child: list);
  }
}
