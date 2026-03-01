{{#theme}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_colors.dart';
import 'package:{{package_name}}/core/theme/app_radius.dart';
import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// Factory helpers for [InputDecoration] presets.
///
/// Used by [AppTheme] and [AppTextField] to ensure all inputs share the
/// same baseline decoration, customisable per mode.
abstract final class InputThemeHelper {
  /// Base decoration shared across all modes.
  static InputDecoration base({
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool filled = true,
    Color? fillColor,
    BorderRadius? borderRadius,
  }) {
    final radius = borderRadius ?? AppRadius.input;
    final fill = fillColor ?? AppColors.surfaceVariant.withAlpha(80);

    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      filled: filled,
      fillColor: fill,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.smMd,
      ),
      border: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.outlineVariant),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: radius,
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
    );
  }

  /// Normal (default) field.
  static InputDecoration normal({
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      base(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      );

  /// Error state - red borders, optional error message shown below via [errorText].
  static InputDecoration error({
    String? labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) =>
      base(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        fillColor: AppColors.errorContainer.withAlpha(40),
      );

  /// Informational / auxiliary field (blue tint).
  static InputDecoration info({
    String? labelText,
    String? hintText,
    String? helperText,
  }) =>
      base(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        fillColor: AppColors.secondaryContainer.withAlpha(60),
      );

  /// Password field (no adornment - suffix icon added by the widget).
  static InputDecoration password({
    String? labelText,
    String? hintText,
    Widget? suffixIcon,
  }) =>
      base(
        labelText: labelText ?? 'Password',
        hintText: hintText ?? '••••••••',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: suffixIcon,
      );

  /// Multi-line textarea.
  static InputDecoration textarea({
    String? labelText,
    String? hintText,
    String? helperText,
  }) =>
      base(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ).copyWith(
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        alignLabelWithHint: true,
      );

  /// Returns the [InputDecorationTheme] used by [AppTheme].
  static InputDecorationTheme get themeData => InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceVariant.withAlpha(80),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.smMd,
        ),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.input,
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      );
}
{{/theme}}
