import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:saviour/platform_widgets/platform_theme.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A platform-aware single or multiline text field.
class PlatformTextField extends ConsumerWidget {
  const PlatformTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder,
    this.prefix,
    this.suffix,
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
  final String? placeholder;
  final Widget? prefix;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
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
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.platformTheme;
    final resolvedStyle =
        style ?? theme.text.bodyMedium?.copyWith(color: theme.onSurface);
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        prefix: prefix,
        suffix: suffix,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: resolvedStyle,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      AppPlatform.macos => macos.MacosTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        prefix: prefix,
        suffix: suffix,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: resolvedStyle,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      AppPlatform.windows => fluent.TextBox(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        prefix: prefix,
        suffix: suffix,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: resolvedStyle,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.TextField(
        controller: controller,
        focusNode: focusNode,
        decoration: material.InputDecoration(
          hintText: placeholder,
          prefixIcon: prefix,
          suffixIcon: suffix,
        ),
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        style: resolvedStyle,
        autofocus: autofocus,
        readOnly: readOnly,
        obscureText: obscureText,
        enabled: enabled,
        maxLines: maxLines,
        minLines: minLines,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    };
  }
}

/// A platform-aware checkbox with optional tri-state support.
class PlatformCheckbox extends ConsumerWidget {
  const PlatformCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.activeColor,
    this.semanticLabel,
  }) : assert(tristate || value != null);

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final Color? activeColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = activeColor ?? context.platformTheme.primary;
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoCheckbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
        activeColor: active,
        semanticLabel: semanticLabel,
      ),
      AppPlatform.macos => macos.MacosCheckbox(
        value: value,
        activeColor: active,
        semanticLabel: semanticLabel,
        onChanged: onChanged == null ? null : (value) => onChanged!(value),
      ),
      AppPlatform.windows => fluent.Checkbox(
        checked: value,
        onChanged: onChanged,
        semanticLabel: semanticLabel,
      ),
      AppPlatform.linux => yaru.YaruCheckbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
        selectedColor: active,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.Checkbox(
        value: value,
        tristate: tristate,
        onChanged: onChanged,
        activeColor: active,
        semanticLabel: semanticLabel,
      ),
    };
  }
}

/// A platform-aware slider.
class PlatformSlider extends ConsumerWidget {
  const PlatformSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.activeColor,
    this.label,
    this.semanticLabel,
  }) : assert(min < max),
       assert(divisions == null || divisions > 0);

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final Color? activeColor;
  final String? label;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = activeColor ?? context.platformTheme.primary;
    final normalizedValue = value.clamp(min, max);
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoSlider(
        value: normalizedValue,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: active,
        onChanged: onChanged,
      ),
      AppPlatform.macos => Opacity(
        opacity: onChanged == null ? 0.5 : 1,
        child: IgnorePointer(
          ignoring: onChanged == null,
          child: macos.MacosSlider(
            value: normalizedValue,
            min: min,
            max: max,
            discrete: divisions != null,
            splits: (divisions ?? 1) + 1,
            color: active,
            semanticLabel: semanticLabel,
            onChanged: onChanged ?? (_) {},
          ),
        ),
      ),
      AppPlatform.windows => fluent.Slider(
        value: normalizedValue,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.Slider(
        value: normalizedValue,
        min: min,
        max: max,
        divisions: divisions,
        activeColor: active,
        label: label,
        semanticFormatterCallback: semanticLabel == null
            ? null
            : (_) => semanticLabel!,
        onChanged: onChanged,
      ),
    };
  }
}

/// A single selectable item in a [PlatformPicker].
class PlatformPickerItem<T> {
  const PlatformPickerItem({
    required this.value,
    required this.child,
    this.label,
  });

  final T value;
  final Widget child;

  /// Plain-text representation used by Material 3's editable dropdown field.
  /// When omitted, text children and then [value] are used as fallbacks.
  final String? label;

  String get effectiveLabel {
    final child = this.child;
    if (label != null) return label!;
    if (child is Text && child.data != null) return child.data!;
    return value.toString();
  }
}

/// A compact platform-aware picker for choosing one value.
class PlatformPicker<T> extends ConsumerWidget {
  const PlatformPicker({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.placeholder,
    this.isExpanded = false,
    this.focusNode,
    this.autofocus = false,
    this.onTap,
  });

  final List<PlatformPickerItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;
  final bool isExpanded;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => _CupertinoPickerButton<T>(
        items: items,
        value: value,
        onChanged: onChanged,
        placeholder: placeholder,
        focusNode: focusNode,
        autofocus: autofocus,
        onTap: onTap,
      ),
      AppPlatform.macos => macos.MacosPopupButton<T>(
        items: [
          for (final item in items)
            macos.MacosPopupMenuItem<T>(value: item.value, child: item.child),
        ],
        value: value,
        hint: placeholder,
        focusNode: focusNode,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
        // Keep this non-null: macos_ui otherwise lays selected items out in an
        // intrinsic-height Column that can overflow the native 20px control.
        itemHeight: 24,
      ),
      AppPlatform.windows => fluent.ComboBox<T>(
        items: [
          for (final item in items)
            fluent.ComboBoxItem<T>(value: item.value, child: item.child),
        ],
        value: value,
        placeholder: placeholder,
        isExpanded: isExpanded,
        focusNode: focusNode,
        autofocus: autofocus,
        onTap: onTap,
        onChanged: onChanged,
      ),
      AppPlatform.linux ||
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => _MaterialPicker<T>(
        items: items,
        value: value,
        onChanged: onChanged,
        placeholder: placeholder,
        isExpanded: isExpanded,
        focusNode: focusNode,
        autofocus: autofocus,
        onTap: onTap,
      ),
    };
  }
}

class _MaterialPicker<T> extends StatefulWidget {
  const _MaterialPicker({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.placeholder,
    required this.isExpanded,
    required this.focusNode,
    required this.autofocus,
    required this.onTap,
  });

  final List<PlatformPickerItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;
  final bool isExpanded;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  State<_MaterialPicker<T>> createState() => _MaterialPickerState<T>();
}

class _MaterialPickerState<T> extends State<_MaterialPicker<T>> {
  late FocusNode _focusNode;
  late bool _ownsFocusNode;

  @override
  void initState() {
    super.initState();
    _setFocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(_MaterialPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (_ownsFocusNode) _focusNode.dispose();
      _setFocusNode();
    }
  }

  void _setFocusNode() {
    _ownsFocusNode = widget.focusNode == null;
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void dispose() {
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder;
    return Listener(
      onPointerDown: widget.onTap == null ? null : (_) => widget.onTap!(),
      child: material.DropdownMenu<T>(
        key: ValueKey(widget.value),
        initialSelection: widget.value,
        dropdownMenuEntries: [
          for (final item in widget.items)
            material.DropdownMenuEntry<T>(
              value: item.value,
              label: item.effectiveLabel,
              labelWidget: item.child,
            ),
        ],
        hintText: placeholder is Text ? placeholder.data : null,
        expandedInsets: widget.isExpanded ? EdgeInsets.zero : null,
        focusNode: _focusNode,
        onSelected: widget.onChanged,
      ),
    );
  }
}

class _CupertinoPickerButton<T> extends StatelessWidget {
  const _CupertinoPickerButton({
    required this.items,
    required this.value,
    required this.onChanged,
    required this.placeholder,
    required this.focusNode,
    required this.autofocus,
    required this.onTap,
  });

  final List<PlatformPickerItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final selected = items.where((item) => item.value == value).firstOrNull;
    return cupertino.CupertinoButton(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      focusNode: focusNode,
      autofocus: autofocus,
      onPressed: onChanged == null
          ? null
          : () {
              onTap?.call();
              cupertino.showCupertinoModalPopup<void>(
                context: context,
                builder: (context) => cupertino.CupertinoActionSheet(
                  actions: [
                    for (final item in items)
                      cupertino.CupertinoActionSheetAction(
                        isDefaultAction: item.value == value,
                        onPressed: () {
                          Navigator.of(context).pop();
                          onChanged!(item.value);
                        },
                        child: item.child,
                      ),
                  ],
                ),
              );
            },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          selected?.child ?? placeholder ?? const SizedBox.shrink(),
          const SizedBox(width: 8),
          const Icon(cupertino.CupertinoIcons.chevron_down, size: 14),
        ],
      ),
    );
  }
}
