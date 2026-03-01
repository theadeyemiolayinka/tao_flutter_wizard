{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// A styled checkbox with optional label and subtitle.
///
/// ```dart
/// AppCheckbox(
///   label: 'Accept terms & conditions',
///   value: _accepted,
///   onChanged: (v) => setState(() => _accepted = v ?? false),
/// )
/// ```
class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.enabled = true,
    this.tristate = false,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? label;
  final String? subtitle;
  final bool enabled;
  final bool tristate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled
          ? () {
              if (tristate) {
                onChanged?.call(value == null ? true : (value! ? false : null));
              } else {
                onChanged?.call(!(value ?? false));
              }
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Checkbox(
              value: value,
              tristate: tristate,
              onChanged: enabled ? onChanged : null,
            ),
            const SizedBox(width: AppSpacing.xs),
            if (label != null)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: enabled
                              ? theme.colorScheme.onSurface
                              : theme.colorScheme.onSurface.withAlpha(100),
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          subtitle!,
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
    );
  }
}
{{/design_system}}
