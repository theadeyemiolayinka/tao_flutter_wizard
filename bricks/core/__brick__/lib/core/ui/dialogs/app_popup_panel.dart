{{#design_system}}
import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_radius.dart';
import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// A styled popup panel that can be shown inside a [Stack] or via
/// an [OverlayEntry], e.g. for custom tooltips, context menus, or
/// feature-specific popups that don't need a full dialog dimming.
///
/// For blocking modal dialogs (with scrim), use [AppDialogs] instead.
///
/// ```dart
/// AppPopupPanel(
///   title: 'Sort by',
///   child: Column(
///     children: [
///       AppRadioGroup<SortOrder>(...),
///     ],
///   ),
/// )
/// ```
class AppPopupPanel extends StatelessWidget {
  const AppPopupPanel({
    super.key,
    this.title,
    required this.child,
    this.padding,
    this.width,
    this.onDismiss,
  });

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surfaceContainerHigh,
      elevation: 4,
      shadowColor: theme.colorScheme.shadow,
      borderRadius: AppRadius.card,
      child: SizedBox(
        width: width,
        child: Padding(
          padding: padding ??
              const EdgeInsets.all(AppSpacing.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (title != null || onDismiss != null) ...[
                Row(
                  children: [
                    if (title != null)
                      Expanded(
                        child: Text(
                          title!,
                          style: theme.textTheme.titleSmall,
                        ),
                      ),
                    if (onDismiss != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: onDismiss,
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}

/// A scrimmed full-screen overlay wrapper.
///
/// Use when you need a dismissable backdrop without using the
/// Navigator dialog stack (e.g. inline overlay inside a page).
///
/// ```dart
/// Stack(
///   children: [
///     MyPageContent(),
///     if (_showOverlay)
///       AppBackdrop(
///         onDismiss: () => setState(() => _showOverlay = false),
///         child: Center(child: AppPopupPanel(...)),
///       ),
///   ],
/// )
/// ```
class AppBackdrop extends StatelessWidget {
  const AppBackdrop({
    super.key,
    required this.child,
    this.onDismiss,
    this.color,
  });

  final Widget child;
  final VoidCallback? onDismiss;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onDismiss,
      child: ColoredBox(
        color: color ?? theme.colorScheme.scrim.withAlpha(102),
        child: GestureDetector(
          // Absorb taps on the child so they don't dismiss
          onTap: () {},
          child: child,
        ),
      ),
    );
  }
}
{{/design_system}}
