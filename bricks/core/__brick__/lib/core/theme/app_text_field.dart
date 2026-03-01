{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/input_theme.dart';

/// Field mode / variant.
enum AppTextFieldMode {
  normal,
  password,
  email,
  phone,
  textarea,
}

/// Opinionated, theme-aware text field widget.
///
/// Handles visibility toggling for password fields automatically.
/// All modes feed through [InputThemeHelper] so colours and shapes
/// stay in sync with [AppTheme].
///
/// ```dart
/// AppTextField(
///   label: 'Email',
///   hint: 'you@example.com',
///   mode: AppTextFieldMode.email,
///   controller: _emailController,
/// )
///
/// AppTextField.password(
///   label: 'Password',
///   controller: _passwordController,
/// )
/// ```
class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.mode = AppTextFieldMode.normal,
    this.maxLines = 1,
    this.minLines,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
  });

  /// Named constructor for password fields (hides/shows text).
  const AppTextField.password({
    super.key,
    this.controller,
    this.label = 'Password',
    this.hint = '••••••••',
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
  })  : mode = AppTextFieldMode.password,
        prefixIcon = null,
        suffixIcon = null,
        maxLines = 1,
        minLines = null;

  /// Named constructor for textarea (multi-line, scrollable).
  const AppTextField.textarea({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 5,
    this.minLines = 3,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.focusNode,
  })  : mode = AppTextFieldMode.textarea,
        prefixIcon = null,
        suffixIcon = null;

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final AppTextFieldMode mode;
  final int? maxLines;
  final int? minLines;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.mode == AppTextFieldMode.password;
    final isTextarea = widget.mode == AppTextFieldMode.textarea;

    final decoration = _buildDecoration(isPassword, isTextarea);

    return TextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: isPassword && _obscureText,
      maxLines: isTextarea ? widget.maxLines : (isPassword ? 1 : widget.maxLines),
      minLines: isTextarea ? widget.minLines : null,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      keyboardType: _keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      decoration: decoration.copyWith(errorText: widget.errorText),
    );
  }

  InputDecoration _buildDecoration(bool isPassword, bool isTextarea) {
    if (isPassword) {
      return InputThemeHelper.password(
        labelText: widget.label,
        hintText: widget.hint,
        suffixIcon: IconButton(
          icon: Icon(
            _obscureText ? Icons.visibility_outlined : Icons.visibility_off_outlined,
          ),
          onPressed: () => setState(() => _obscureText = !_obscureText),
        ),
      );
    }

    if (isTextarea) {
      return InputThemeHelper.textarea(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
      );
    }

    if (widget.errorText != null) {
      return InputThemeHelper.error(
        labelText: widget.label,
        hintText: widget.hint,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
      );
    }

    return InputThemeHelper.normal(
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon,
      suffixIcon: widget.suffixIcon,
    );
  }

  TextInputType get _keyboardType => switch (widget.mode) {
        AppTextFieldMode.email => TextInputType.emailAddress,
        AppTextFieldMode.phone => TextInputType.phone,
        AppTextFieldMode.password => TextInputType.visiblePassword,
        AppTextFieldMode.textarea => TextInputType.multiline,
        AppTextFieldMode.normal => TextInputType.text,
      };
}
{{/design_system}}
