{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// A single radio option - use inside [AppRadioGroup].
class AppRadioOption<T> {
  const AppRadioOption({
    required this.value,
    required this.label,
    this.subtitle,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? subtitle;
  final bool enabled;
}

/// A grouped set of radio buttons for a typed value [T].
///
/// ```dart
/// AppRadioGroup<String>(
///   groupValue: _selected,
///   onChanged: (v) => setState(() => _selected = v),
///   options: const [
///     AppRadioOption(value: 'light', label: 'Light'),
///     AppRadioOption(value: 'dark',  label: 'Dark'),
///     AppRadioOption(value: 'system', label: 'System default'),
///   ],
/// )
/// ```
class AppRadioGroup<T> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.groupValue,
    required this.onChanged,
    required this.options,
    this.title,
    this.spacing = AppSpacing.xs,
  });

  final T groupValue;
  final ValueChanged<T?> onChanged;
  final List<AppRadioOption<T>> options;
  final String? title;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: theme.textTheme.titleSmall),
          SizedBox(height: spacing),
        ],
        ...options.map(
          (opt) => InkWell(
            onTap: opt.enabled ? () => onChanged(opt.value) : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Radio<T>(
                    value: opt.value,
                    groupValue: groupValue,
                    toggleable: false,
                    onChanged: opt.enabled ? onChanged : null,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt.label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: opt.enabled
                                  ? theme.colorScheme.onSurface
                                  : theme.colorScheme.onSurface.withAlpha(100),
                            ),
                          ),
                          if (opt.subtitle != null) ...[
                            const SizedBox(height: AppSpacing.xxs),
                            Text(
                              opt.subtitle!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
{{/design_system}}
