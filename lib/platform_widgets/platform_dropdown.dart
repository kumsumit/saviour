import 'package:flutter/widgets.dart';
import 'package:saviour/platform_widgets/platform_form.dart';

/// A single selectable item in a [PlatformDropdown].
class PlatformDropdownItem<T> extends PlatformPickerItem<T> {
  const PlatformDropdownItem({required super.value, required super.child});
}

/// A discoverable platform-aware dropdown for selecting one value.
///
/// Resolves to a Cupertino action sheet on iOS, a macOS popup button, a Fluent
/// combo box on Windows, and the themed Material dropdown on Linux,
/// Android, web, and Fuchsia.
class PlatformDropdown<T> extends StatelessWidget {
  const PlatformDropdown({
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

  final List<PlatformDropdownItem<T>> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final Widget? placeholder;
  final bool isExpanded;
  final FocusNode? focusNode;
  final bool autofocus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return PlatformPicker<T>(
      items: items,
      value: value,
      onChanged: onChanged,
      placeholder: placeholder,
      isExpanded: isExpanded,
      focusNode: focusNode,
      autofocus: autofocus,
      onTap: onTap,
    );
  }
}
