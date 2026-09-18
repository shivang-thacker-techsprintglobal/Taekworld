import 'package:flutter/material.dart';

import '../../config/app_colors.dart';

/// Shared text field with consistent Material theming & high performance rendering.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.autofillHints,
    this.useUnderlineBorder = true,
    this.autocorrect = true,
    this.enableSuggestions = true,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final bool useUnderlineBorder;
  final bool autocorrect;
  final bool enableSuggestions;

  // Cached static styles for 60/120fps smooth typing
  static const _textStyle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const _hintStyle = TextStyle(
    color: Color(0xFF757575),
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static const _borderStyle = UnderlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF9E9E9E), width: 1.0),
  );

  static const _focusedBorderStyle = UnderlineInputBorder(
    borderSide: BorderSide(color: AppColors.brandNavy, width: 1.5),
  );

  static const _errorBorderStyle = UnderlineInputBorder(
    borderSide: BorderSide(color: AppColors.error, width: 1.5),
  );

  @override
  Widget build(BuildContext context) {
    if (!useUnderlineBorder) {
      return TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        validator: validator,
        onChanged: onChanged,
        onFieldSubmitted: onSubmitted,
        enabled: enabled,
        autofillHints: autofillHints,
        autocorrect: autocorrect,
        enableSuggestions: enableSuggestions,
        style: _textStyle,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      enabled: enabled,
      autofillHints: autofillHints,
      autocorrect: autocorrect,
      enableSuggestions: enableSuggestions,
      style: _textStyle,
      cursorColor: AppColors.brandNavy,
      decoration: InputDecoration(
        hintText: hint ?? label,
        hintStyle: _hintStyle,
        isDense: true,
        filled: false,
        fillColor: Colors.transparent,
        prefixIcon: prefixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(right: 12.0, bottom: 2.0),
                child: prefixIcon,
              )
            : null,
        prefixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        suffixIcon: suffixIcon != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 2.0),
                child: suffixIcon,
              )
            : null,
        suffixIconConstraints: const BoxConstraints(
          minWidth: 24,
          minHeight: 24,
        ),
        border: _borderStyle,
        enabledBorder: _borderStyle,
        focusedBorder: _focusedBorderStyle,
        errorBorder: _errorBorderStyle,
        focusedErrorBorder: _errorBorderStyle,
        contentPadding: const EdgeInsets.symmetric(vertical: 14.0),
      ),
    );
  }
}
