import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_input.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';

/// A compact platform-aware label with optional activation and deletion.
class PlatformChip extends ConsumerWidget {
  const PlatformChip({
    super.key,
    required this.label,
    this.avatar,
    this.onPressed,
    this.onDeleted,
    this.backgroundColor,
    this.semanticLabel,
    this.deleteSemanticLabel = 'Remove',
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
  });

  final Widget label;
  final Widget? avatar;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Color? backgroundColor;
  final String? semanticLabel;
  final String deleteSemanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final theme = context.platformTheme;
    final background = backgroundColor ?? theme.surfaceContainer;
    final foreground = theme.foregroundFor(background);
    final content = DefaultTextStyle.merge(
      style: TextStyle(color: foreground),
      child: IconTheme.merge(
        data: IconThemeData(color: foreground),
        child: _ChipContent(
          avatar: avatar,
          label: label,
          onDeleted: onDeleted,
          deleteIcon: _deleteIcon(platform),
          deleteSemanticLabel: deleteSemanticLabel,
        ),
      ),
    );

    return switch (platform) {
      AppPlatform.ios => Semantics(
        button: onPressed != null,
        label: semanticLabel,
        child: cupertino.CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: backgroundColor ?? theme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor,
          onPressed: onPressed,
          child: content,
        ),
      ),
      AppPlatform.macos => PlatformInputActivator(
        focusNode: focusNode,
        autofocus: autofocus,
        mouseCursor: mouseCursor,
        semanticLabel: semanticLabel,
        onActivate: onPressed,
        excludeChildSemantics: true,
        child: macos.PushButton(
          controlSize: macos.ControlSize.small,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: backgroundColor,
          secondary: backgroundColor == null,
          borderRadius: BorderRadius.circular(14),
          onPressed: onPressed,
          child: content,
        ),
      ),
      AppPlatform.windows => fluent.Button(
        focusNode: focusNode,
        autofocus: autofocus,
        onPressed: onPressed,
        child: Semantics(label: semanticLabel, child: content),
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.InputChip(
        avatar: avatar,
        label: label,
        backgroundColor: backgroundColor,
        focusNode: focusNode,
        autofocus: autofocus,
        onPressed: onPressed,
        onDeleted: onDeleted,
      ),
    };
  }
}

/// A platform-aware chip that toggles a filter on or off.
class PlatformFilterChip extends ConsumerWidget {
  const PlatformFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.avatar,
    this.semanticLabel,
    this.focusNode,
    this.autofocus = false,
    this.mouseCursor,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final Widget? avatar;
  final String? semanticLabel;
  final FocusNode? focusNode;
  final bool autofocus;
  final MouseCursor? mouseCursor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    final theme = context.platformTheme;
    final content = _ChipContent(avatar: avatar, label: label);

    return switch (platform) {
      AppPlatform.ios => Semantics(
        button: true,
        selected: selected,
        label: semanticLabel,
        child: cupertino.CupertinoButton(
          minimumSize: Size.zero,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          color: selected ? theme.primary : theme.surfaceContainer,
          disabledColor: theme.surfaceContainer,
          borderRadius: BorderRadius.circular(18),
          focusNode: focusNode,
          autofocus: autofocus,
          mouseCursor: mouseCursor,
          onPressed: onSelected == null ? null : () => onSelected!(!selected),
          child: DefaultTextStyle.merge(
            style: TextStyle(color: selected ? theme.onPrimary : null),
            child: content,
          ),
        ),
      ),
      AppPlatform.macos => PlatformInputActivator(
        focusNode: focusNode,
        autofocus: autofocus,
        mouseCursor: mouseCursor,
        semanticLabel: semanticLabel,
        toggled: selected,
        onActivate: onSelected == null ? null : () => onSelected!(!selected),
        excludeChildSemantics: true,
        child: macos.PushButton(
          controlSize: macos.ControlSize.small,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          color: selected ? theme.primary : null,
          secondary: !selected,
          borderRadius: BorderRadius.circular(14),
          onPressed: onSelected == null ? null : () => onSelected!(!selected),
          child: content,
        ),
      ),
      AppPlatform.windows => fluent.ToggleButton(
        checked: selected,
        semanticLabel: semanticLabel,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onSelected,
        child: content,
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.FilterChip(
        avatar: avatar,
        label: label,
        selected: selected,
        focusNode: focusNode,
        autofocus: autofocus,
        onSelected: onSelected,
      ),
    };
  }
}

class _ChipContent extends StatelessWidget {
  const _ChipContent({
    required this.label,
    this.avatar,
    this.onDeleted,
    this.deleteIcon,
    this.deleteSemanticLabel = 'Remove',
  });

  final Widget label;
  final Widget? avatar;
  final VoidCallback? onDeleted;
  final Widget? deleteIcon;
  final String deleteSemanticLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (avatar != null) ...[avatar!, const SizedBox(width: 6)],
        label,
        if (onDeleted != null) ...[
          const SizedBox(width: 6),
          PlatformInputActivator(
            semanticLabel: deleteSemanticLabel,
            onActivate: onDeleted,
            child: GestureDetector(
              onTap: onDeleted,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: deleteIcon,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

Widget _deleteIcon(AppPlatform platform) => Icon(switch (platform) {
  AppPlatform.ios || AppPlatform.macos => cupertino.CupertinoIcons.clear,
  AppPlatform.windows => fluent.FluentIcons.clear,
  AppPlatform.linux ||
  AppPlatform.android ||
  AppPlatform.web ||
  AppPlatform.fuchsia => material.Icons.close,
}, size: 14);
