import 'package:fluent_ui/fluent_ui.dart' as fluent;
import 'package:flutter/cupertino.dart' as cupertino;
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:macos_ui/macos_ui.dart' as macos;
import 'package:saviour/providers/app_platform_provider.dart';
import 'package:yaru/yaru.dart' as yaru;

/// A platform-aware search field with the native search treatment where the
/// platform toolkit provides one.
class PlatformSearchField extends ConsumerWidget {
  const PlatformSearchField({
    super.key,
    this.controller,
    this.focusNode,
    this.placeholder = 'Search',
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.onClear,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String placeholder;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onClear;

  void _clear() {
    controller?.clear();
    onClear?.call();
    onChanged?.call('');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => cupertino.CupertinoSearchTextField(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        autofocus: autofocus,
        onChanged: onChanged,
        onSubmitted: onSubmitted,
        onSuffixTap: _clear,
      ),
      AppPlatform.macos => macos.MacosSearchField<void>(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        autofocus: autofocus,
        onChanged: onChanged,
      ),
      AppPlatform.windows => fluent.TextBox(
        controller: controller,
        focusNode: focusNode,
        placeholder: placeholder,
        autofocus: autofocus,
        prefix: const Padding(
          padding: EdgeInsetsDirectional.only(start: 8),
          child: Icon(fluent.FluentIcons.search, size: 16),
        ),
        suffix: controller == null || controller!.text.isEmpty
            ? null
            : fluent.IconButton(
                icon: const Icon(fluent.FluentIcons.clear, size: 12),
                onPressed: _clear,
              ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
      AppPlatform.linux => yaru.YaruSearchField(
        controller: controller,
        focusNode: focusNode,
        hintText: placeholder,
        autofocus: autofocus,
        onClear: _clear,
        onChanged: onChanged,
        onSubmitted: onSubmitted == null
            ? null
            : (value) {
                if (value != null) onSubmitted!(value);
              },
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        decoration: material.InputDecoration(
          hintText: placeholder,
          prefixIcon: const Icon(material.Icons.search),
          suffixIcon: controller == null || controller!.text.isEmpty
              ? null
              : material.IconButton(
                  icon: const Icon(material.Icons.clear),
                  onPressed: _clear,
                ),
        ),
        onChanged: onChanged,
        onSubmitted: onSubmitted,
      ),
    };
  }
}

/// A single choice in a [PlatformSegmentedControl].
class PlatformSegment<T> {
  const PlatformSegment({required this.value, required this.label});

  final T value;
  final String label;
}

/// A compact platform-aware control for selecting one of a few related values.
class PlatformSegmentedControl<T extends Object> extends ConsumerWidget {
  const PlatformSegmentedControl({
    super.key,
    required this.segments,
    required this.value,
    required this.onChanged,
  }) : assert(segments.length > 0);

  final List<PlatformSegment<T>> segments;
  final T value;
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = segments.indexWhere((item) => item.value == value);
    assert(selectedIndex >= 0, 'value must match one of the segments');

    return switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => IgnorePointer(
        ignoring: onChanged == null,
        child: Opacity(
          opacity: onChanged == null ? 0.5 : 1,
          child: cupertino.CupertinoSlidingSegmentedControl<T>(
            groupValue: value,
            children: {
              for (final segment in segments)
                segment.value: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text(segment.label),
                ),
            },
            onValueChanged: (value) {
              if (value != null) onChanged?.call(value);
            },
          ),
        ),
      ),
      AppPlatform.macos => _MacosSegmentedControl<T>(
        segments: segments,
        selectedIndex: selectedIndex,
        onChanged: onChanged,
      ),
      AppPlatform.windows => Wrap(
        spacing: 4,
        children: [
          for (final segment in segments)
            fluent.ToggleButton(
              checked: segment.value == value,
              onChanged: onChanged == null
                  ? null
                  : (_) => onChanged!(segment.value),
              child: Text(segment.label),
            ),
        ],
      ),
      AppPlatform.linux => yaru.YaruChoiceChipBar(
        labels: [for (final segment in segments) Text(segment.label)],
        isSelected: [for (final segment in segments) segment.value == value],
        onSelected: onChanged == null
            ? null
            : (index) => onChanged!(segments[index].value),
        showCheckMarks: false,
        selectedFirst: false,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => material.SegmentedButton<T>(
        segments: [
          for (final segment in segments)
            material.ButtonSegment<T>(
              value: segment.value,
              label: Text(segment.label),
            ),
        ],
        selected: {value},
        onSelectionChanged: onChanged == null
            ? null
            : (selection) => onChanged!(selection.first),
      ),
    };
  }
}

class _MacosSegmentedControl<T extends Object> extends StatefulWidget {
  const _MacosSegmentedControl({
    required this.segments,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<PlatformSegment<T>> segments;
  final int selectedIndex;
  final ValueChanged<T>? onChanged;

  @override
  State<_MacosSegmentedControl<T>> createState() =>
      _MacosSegmentedControlState<T>();
}

class _MacosSegmentedControlState<T extends Object>
    extends State<_MacosSegmentedControl<T>> {
  late macos.MacosTabController _controller;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  @override
  void didUpdateWidget(_MacosSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.segments.length != widget.segments.length) {
      _controller.removeListener(_handleChanged);
      _controller.dispose();
      _createController();
    } else if (_controller.index != widget.selectedIndex) {
      _syncing = true;
      _controller.index = widget.selectedIndex;
      _syncing = false;
    }
  }

  void _createController() {
    _controller = macos.MacosTabController(
      initialIndex: widget.selectedIndex,
      length: widget.segments.length,
    )..addListener(_handleChanged);
  }

  void _handleChanged() {
    if (!_syncing) {
      widget.onChanged?.call(widget.segments[_controller.index].value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_handleChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return macos.MacosSegmentedControl(
      controller: _controller,
      tabs: [
        for (final segment in widget.segments)
          macos.MacosTab(label: segment.label),
      ],
    );
  }
}
