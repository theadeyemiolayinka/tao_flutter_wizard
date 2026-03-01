import 'package:flutter/material.dart';

import 'package:{{package_name}}/core/theme/app_radius.dart';
import 'package:{{package_name}}/core/theme/app_spacing.dart';

/// Result of an [AppDialog] confirmation.
enum AppDialogResult { confirmed, cancelled }

/// Centralised dialog & bottom-sheet service.
///
/// All dialogs route through these methods so that:
/// 1. Backdrop, animation, and barrier colour are consistent app-wide.
/// 2. Switching a dialog style (e.g. modal bottom sheet → dialog) is a
///    one-place change.
/// 3. Features can call dialogs without importing Material internals.
///
/// Usage:
/// ```dart
/// // From anywhere with a BuildContext:
/// final confirm = await AppDialogs.confirm(
///   context,
///   title: 'Delete item?',
///   body: 'This cannot be undone.',
///   confirmLabel: 'Delete',
///   isDestructive: true,
/// );
/// if (confirm == AppDialogResult.confirmed) ...
///
/// // Custom content:
/// await AppDialogs.show(context, builder: (_) => MyCustomDialog());
///
/// // Bottom sheet:
/// await AppDialogs.showBottomSheet(context, child: MySheetContent());
/// ```
abstract final class AppDialogs {
  // ── Modal dialog ───────────────────────────────────────────────

  /// Shows a fully custom dialog with the app's default appearance.
  static Future<T?> show<T>(
    BuildContext context, {
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ??
          Theme.of(context).colorScheme.scrim.withAlpha(102),
      builder: builder,
    );
  }

  /// Shows a standard confirmation dialog.
  ///
  /// Returns [AppDialogResult.confirmed] if the user tapped [confirmLabel],
  /// or [AppDialogResult.cancelled] if dismissed or tapped [cancelLabel].
  static Future<AppDialogResult> confirm(
    BuildContext context, {
    required String title,
    required String body,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
    Widget? icon,
  }) async {
    final result = await show<AppDialogResult>(
      context,
      builder: (ctx) => _AppConfirmDialog(
        title: title,
        body: body,
        confirmLabel: confirmLabel,
        cancelLabel: cancelLabel,
        isDestructive: isDestructive,
        icon: icon,
      ),
    );
    return result ?? AppDialogResult.cancelled;
  }

  /// Shows an informational dialog with a single dismiss button.
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String body,
    String dismissLabel = 'OK',
    Widget? icon,
  }) {
    return show<void>(
      context,
      builder: (ctx) => _AppAlertDialog(
        title: title,
        body: body,
        dismissLabel: dismissLabel,
        icon: icon,
      ),
    );
  }

  // ── Modal bottom sheet ─────────────────────────────────────────

  /// Shows a draggable modal bottom sheet with the app's default style.
  static Future<T?> showBottomSheet<T>(
    BuildContext context, {
    required Widget child,
    bool isDismissible = true,
    bool enableDrag = true,
    bool isScrollControlled = true,
    double? maxHeightFraction,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: isScrollControlled,
      barrierColor: barrierColor ??
          Theme.of(context).colorScheme.scrim.withAlpha(102),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => maxHeightFraction != null
          ? ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * maxHeightFraction,
              ),
              child: child,
            )
          : child,
    );
  }

  /// Shows a bottom sheet wrapped in a [DraggableScrollableSheet].
  ///
  /// Use this for content that should expand on drag and still be scrollable.
  static Future<T?> showScrollableBottomSheet<T>(
    BuildContext context, {
    required Widget Function(BuildContext, ScrollController) builder,
    double initialSize = 0.5,
    double minSize = 0.25,
    double maxSize = 0.92,
    bool isDismissible = true,
    bool enableDrag = true,
    Color? barrierColor,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      isScrollControlled: true,
      barrierColor: barrierColor ??
          Theme.of(context).colorScheme.scrim.withAlpha(102),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.bottomSheet),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: initialSize,
        minChildSize: minSize,
        maxChildSize: maxSize,
        expand: false,
        builder: (innerCtx, controller) => builder(innerCtx, controller),
      ),
    );
  }
}

// ── Private dialog implementations ──────────────────────────────────

class _AppConfirmDialog extends StatelessWidget {
  const _AppConfirmDialog({
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.isDestructive,
    this.icon,
  });

  final String title;
  final String body;
  final String confirmLabel;
  final String cancelLabel;
  final bool isDestructive;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Text(body, style: theme.textTheme.bodyMedium),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        TextButton(
          onPressed: () =>
              Navigator.of(context).pop(AppDialogResult.cancelled),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () =>
              Navigator.of(context).pop(AppDialogResult.confirmed),
          style: isDestructive
              ? FilledButton.styleFrom(
                  backgroundColor: cs.error,
                  foregroundColor: cs.onError,
                )
              : null,
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

class _AppAlertDialog extends StatelessWidget {
  const _AppAlertDialog({
    required this.title,
    required this.body,
    required this.dismissLabel,
    this.icon,
  });

  final String title;
  final String body;
  final String dismissLabel;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      icon: icon,
      title: Text(title),
      content: Text(body, style: theme.textTheme.bodyMedium),
      contentPadding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      actionsPadding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      actions: [
        FilledButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(dismissLabel),
        ),
      ],
    );
  }
}
