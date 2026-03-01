{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// A styled toggle switch with optional label and subtitle.
///
/// ```dart
/// AppToggle(
///   label: 'Enable notifications',
///   value: _notificationsEnabled,
///   onChanged: (v) => setState(() => _notificationsEnabled = v),
/// )
/// ```
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.subtitle,
    this.enabled = true,
    this.activeColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? label;
  final String? subtitle;
  final bool enabled;
  final Color? activeColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled ? () => onChanged?.call(!value) : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
        child: Row(
          children: [
            if (label != null)
              Expanded(
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
            Switch(
              value: value,
              onChanged: enabled ? onChanged : null,
              activeColor: activeColor,
              inactiveThumbColor: inactiveThumbColor,
              inactiveTrackColor: inactiveTrackColor,
            ),
          ],
        ),
      ),
    );
  }
}
{{/design_system}}
