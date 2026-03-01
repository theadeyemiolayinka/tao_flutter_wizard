{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_radius.dart';
import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// Button style variant.
enum AppButtonVariant {
  filled,
  outlined,
  text,
  tonal,
  destructive,
}

/// Opinionated, theme-aware button widget.
///
/// ```dart
/// AppButton(
///   label: 'Continue',
///   onPressed: _submit,
/// )
///
/// AppButton.outlined(
///   label: 'Cancel',
///   onPressed: Navigator.of(context).pop,
/// )
///
/// AppButton.destructive(
///   label: 'Delete account',
///   onPressed: _deleteAccount,
///   loading: _isDeleting,
/// )
/// ```
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.filled,
    this.width,
    this.borderRadius,
  });

  const AppButton.outlined({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.width,
    this.borderRadius,
  }) : variant = AppButtonVariant.outlined;

  const AppButton.text({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.width,
    this.borderRadius,
  }) : variant = AppButtonVariant.text;

  const AppButton.tonal({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.width,
    this.borderRadius,
  }) : variant = AppButtonVariant.tonal;

  const AppButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.width,
    this.borderRadius,
  }) : variant = AppButtonVariant.destructive;

  const AppButton.pill({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = AppButtonVariant.filled,
    this.width,
  }) : borderRadius = AppRadius.full;

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final bool loading;
  final AppButtonVariant variant;
  final double? width;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final effectiveRadius = borderRadius ?? AppRadius.md;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(effectiveRadius),
    );
    const padding = EdgeInsets.symmetric(
      horizontal: AppSpacing.lg,
      vertical: AppSpacing.smMd,
    );

    final child = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : (icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon!,
                  const SizedBox(width: AppSpacing.sm),
                  Text(label),
                ],
              )
            : Text(label));

    Widget button = switch (variant) {
      AppButtonVariant.filled => FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(shape: shape, padding: padding),
          child: child,
        ),
      AppButtonVariant.outlined => OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(shape: shape, padding: padding),
          child: child,
        ),
      AppButtonVariant.text => TextButton(
          onPressed: loading ? null : onPressed,
          style: TextButton.styleFrom(shape: shape, padding: padding),
          child: child,
        ),
      AppButtonVariant.tonal => FilledButton.tonal(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(shape: shape, padding: padding),
          child: child,
        ),
      AppButtonVariant.destructive => FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
            foregroundColor: Theme.of(context).colorScheme.onError,
            shape: shape,
            padding: padding,
          ),
          child: child,
        ),
    };

    if (width != null) {
      button = SizedBox(width: width, child: button);
    }

    return button;
  }
}
{{/design_system}}
