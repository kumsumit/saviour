import 'package:saviour/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:saviour/providers/app_platform_provider.dart';

class PlatformPhoneNumberInput extends ConsumerWidget {
  const PlatformPhoneNumberInput({
    super.key,
    required this.countries,
    required this.defaultCountry,
    required this.controller,
    required this.label,
    required this.onChanged,
    required this.onValidated,
    required this.onSubmitted,
    this.autofocus = false,
    this.textStyle,
    this.selectorTextStyle,
    this.useRoundedContainer = false,
    this.containerColor,
    this.shadowColor,
    this.hintColor,
    this.iconColor,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.dividerColor,
    this.showPhoneIcon = true,
  });

  final List<Country> countries;
  final Country defaultCountry;
  final TextEditingController controller;
  final String label;
  final ValueChanged<PhoneNumber> onChanged;
  final ValueChanged<bool> onValidated;
  final ValueChanged<String> onSubmitted;
  final bool autofocus;
  final TextStyle? textStyle;
  final TextStyle? selectorTextStyle;
  final bool useRoundedContainer;
  final Color? containerColor;
  final Color? shadowColor;
  final Color? hintColor;
  final Color? iconColor;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final Color? dividerColor;
  final bool showPhoneIcon;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final effectiveHintColor =
        hintColor ?? SaviourPalette.shade500.withValues(alpha: 0.7);
    final effectiveIconColor =
        iconColor ?? SaviourPalette.shade500.withValues(alpha: 0.7);
    final effectiveDividerColor =
        dividerColor ?? Theme.of(context).colorScheme.outlineVariant;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final effectiveBorderRadius = BorderRadius.circular(borderRadius ?? 16);
    final effectiveBorderWidth = borderWidth ?? 1.5;
    final enabledBorderSide = BorderSide(
      color:
          borderColor ??
          theme.inputDecorationTheme.enabledBorder?.borderSide.color ??
          colorScheme.outline,
      width: effectiveBorderWidth,
    );
    final focusedBorderSide = BorderSide(
      color:
          borderColor ??
          theme.inputDecorationTheme.focusedBorder?.borderSide.color ??
          colorScheme.primary,
      width: effectiveBorderWidth,
    );
    final errorBorderSide = BorderSide(
      color:
          theme.inputDecorationTheme.errorBorder?.borderSide.color ??
          colorScheme.error,
      width: effectiveBorderWidth,
    );
    final enabledOutlineBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: enabledBorderSide,
    );
    final focusedOutlineBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: focusedBorderSide,
    );
    final errorOutlineBorder = OutlineInputBorder(
      borderRadius: effectiveBorderRadius,
      borderSide: errorBorderSide,
    );
    final inputDecoration = useRoundedContainer
        ? InputDecoration(
            hintText: label,
            hintStyle: TextStyle(color: effectiveHintColor),
            filled: true,
            fillColor: containerColor ?? colorScheme.surface,
            border: enabledOutlineBorder,
            enabledBorder: enabledOutlineBorder,
            focusedBorder: focusedOutlineBorder,
            errorBorder: errorOutlineBorder,
            focusedErrorBorder: errorOutlineBorder,
            disabledBorder: enabledOutlineBorder.copyWith(
              borderSide: enabledBorderSide.copyWith(
                color: enabledBorderSide.color.withValues(alpha: 0.45),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 18),
            counterStyle: theme.inputDecorationTheme.counterStyle,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: 0,
            ),
            prefix: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 6),
                Container(width: 1, height: 28, color: effectiveDividerColor),
                if (showPhoneIcon) ...[
                  const SizedBox(width: 12),
                  Icon(
                    Icons.phone_outlined,
                    size: 20,
                    color: effectiveIconColor,
                  ),
                ],
                SizedBox(width: showPhoneIcon ? 10 : 4),
              ],
            ),
          )
        : InputDecoration(labelText: label, hintText: label);
    final selectorConfig = SelectorConfig(
      selectorType: PhoneInputSelectorType.BOTTOM_SHEET,
      setSelectorButtonAsPrefixIcon: true,
      leadingPadding: useRoundedContainer ? 6 : null,
      trailingPadding: useRoundedContainer ? 0 : null,
      trailingSpace: false,
      useBottomSheetSafeArea: true,
      selectorTitle: 'Select country or region',
      searchHintText: 'Search country or calling code',
      emptySearchMessage: 'No matching countries',
    );
    final shared = (
      countries: countries,
      defaultCountry: defaultCountry,
      textFieldController: controller,
      formatInput: true,
      autoFocus: autofocus,
      keyboardAction: TextInputAction.done,
      autoValidateMode: AutovalidateMode.onUserInteraction,
      onInputChanged: onChanged,
      onInputValidated: onValidated,
      onFieldSubmitted: onSubmitted,
      textStyle: textStyle,
      selectorTextStyle: selectorTextStyle,
    );

    final input = switch (ref.watch(appPlatformProvider)) {
      AppPlatform.ios => CupertinoInternationalPhoneNumber(
        countries: shared.countries,
        defaultCountry: shared.defaultCountry,
        textFieldController: shared.textFieldController,
        formatInput: shared.formatInput,
        autoFocus: shared.autoFocus,
        keyboardAction: shared.keyboardAction,
        autoValidateMode: shared.autoValidateMode,
        onInputChanged: shared.onInputChanged,
        onInputValidated: shared.onInputValidated,
        onFieldSubmitted: shared.onFieldSubmitted,
        textStyle: shared.textStyle,
        selectorTextStyle: shared.selectorTextStyle,
        selectorConfig: selectorConfig,
        placeholder: label,
      ),
      AppPlatform.macos => MacosInternationalPhoneNumber(
        countries: shared.countries,
        defaultCountry: shared.defaultCountry,
        textFieldController: shared.textFieldController,
        formatInput: shared.formatInput,
        autoFocus: shared.autoFocus,
        keyboardAction: shared.keyboardAction,
        autoValidateMode: shared.autoValidateMode,
        onInputChanged: shared.onInputChanged,
        onInputValidated: shared.onInputValidated,
        onFieldSubmitted: shared.onFieldSubmitted,
        textStyle: shared.textStyle,
        selectorTextStyle: shared.selectorTextStyle,
        selectorConfig: selectorConfig,
        placeholder: label,
      ),
      AppPlatform.windows => FluentInternationalPhoneNumber(
        countries: shared.countries,
        defaultCountry: shared.defaultCountry,
        textFieldController: shared.textFieldController,
        formatInput: shared.formatInput,
        autoFocus: shared.autoFocus,
        keyboardAction: shared.keyboardAction,
        autoValidateMode: shared.autoValidateMode,
        onInputChanged: shared.onInputChanged,
        onInputValidated: shared.onInputValidated,
        onFieldSubmitted: shared.onFieldSubmitted,
        textStyle: shared.textStyle,
        selectorTextStyle: shared.selectorTextStyle,
        selectorConfig: selectorConfig,
        placeholder: label,
      ),
      AppPlatform.linux => YaruInternationalPhoneNumber(
        countries: shared.countries,
        defaultCountry: shared.defaultCountry,
        textFieldController: shared.textFieldController,
        formatInput: shared.formatInput,
        autoFocus: shared.autoFocus,
        keyboardAction: shared.keyboardAction,
        autoValidateMode: shared.autoValidateMode,
        onInputChanged: shared.onInputChanged,
        onInputValidated: shared.onInputValidated,
        onFieldSubmitted: shared.onFieldSubmitted,
        textStyle: shared.textStyle,
        selectorTextStyle: shared.selectorTextStyle,
        selectorConfig: selectorConfig,
        inputDecoration: inputDecoration,
        placeholder: label,
      ),
      AppPlatform.android ||
      AppPlatform.web ||
      AppPlatform.fuchsia => MaterialInternationalPhoneNumber(
        countries: shared.countries,
        defaultCountry: shared.defaultCountry,
        textFieldController: shared.textFieldController,
        formatInput: shared.formatInput,
        autoFocus: shared.autoFocus,
        keyboardAction: shared.keyboardAction,
        autoValidateMode: shared.autoValidateMode,
        onInputChanged: shared.onInputChanged,
        onInputValidated: shared.onInputValidated,
        onFieldSubmitted: shared.onFieldSubmitted,
        textStyle: shared.textStyle,
        selectorTextStyle: shared.selectorTextStyle,
        selectorConfig: selectorConfig,
        inputDecoration: inputDecoration,
      ),
    };

    if (!useRoundedContainer) {
      return input;
    }

    return Container(
      constraints: const BoxConstraints(minHeight: 66),
      decoration: BoxDecoration(
        borderRadius: effectiveBorderRadius,
        boxShadow: [
          BoxShadow(
            color:
                shadowColor ?? SaviourPalette.shade950.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: input,
    );
  }
}
