{{#design_system}}
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

/// App-wide toast / snackbar service.
///
/// Wraps [toastification] for rich, themed toasts. All toast variants
/// run through this class so that appearance, position, duration, and
/// dismiss behaviour are consistent app-wide.
///
/// **Setup** — wrap your [MaterialApp] / [MaterialApp.router] with
/// [Toastification] widget:
/// ```dart
/// Toastification(
///   child: MaterialApp.router(...)
/// )
/// ```
///
/// **Usage:**
/// ```dart
/// AppToast.success(context, message: 'Profile saved!');
/// AppToast.error(context, message: 'Failed to load data.');
/// AppToast.info(context, message: 'Syncing in the background...');
/// AppToast.warning(context, message: 'Low storage space.');
/// ```
abstract final class AppToast {
  static const _defaultDuration = Duration(seconds: 3);
  static const _defaultAlignment = Alignment.bottomCenter;

  // ── Convenience factories ─────────────────────────────────────

  static ToastificationItem success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = _defaultDuration,
    Alignment alignment = _defaultAlignment,
    bool autoCloseSec = true,
  }) =>
      _show(
        context,
        title: title ?? 'Success',
        message: message,
        type: ToastificationType.success,
        style: ToastificationStyle.flatColored,
        duration: duration,
        alignment: alignment,
        autoCloseSec: autoCloseSec,
      );

  static ToastificationItem error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = _defaultDuration,
    Alignment alignment = _defaultAlignment,
  }) =>
      _show(
        context,
        title: title ?? 'Error',
        message: message,
        type: ToastificationType.error,
        style: ToastificationStyle.flatColored,
        duration: duration,
        alignment: alignment,
        autoCloseSec: true,
      );

  static ToastificationItem info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = _defaultDuration,
    Alignment alignment = _defaultAlignment,
  }) =>
      _show(
        context,
        title: title,
        message: message,
        type: ToastificationType.info,
        style: ToastificationStyle.flat,
        duration: duration,
        alignment: alignment,
        autoCloseSec: true,
      );

  static ToastificationItem warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = _defaultDuration,
    Alignment alignment = _defaultAlignment,
  }) =>
      _show(
        context,
        title: title ?? 'Warning',
        message: message,
        type: ToastificationType.warning,
        style: ToastificationStyle.flatColored,
        duration: duration,
        alignment: alignment,
        autoCloseSec: true,
      );

  /// Dismiss a specific toast by its [ToastificationItem].
  static void dismiss(ToastificationItem item) {
    toastification.dismiss(item);
  }

  /// Dismiss all currently visible toasts.
  static void dismissAll() {
    toastification.dismissAll();
  }

  // ── Internal ──────────────────────────────────────────────────

  static ToastificationItem _show(
    BuildContext context, {
    String? title,
    required String message,
    required ToastificationType type,
    required ToastificationStyle style,
    required Duration duration,
    required Alignment alignment,
    required bool autoCloseSec,
  }) {
    return toastification.show(
      context: context,
      title: title != null ? Text(title) : null,
      description: Text(message),
      type: type,
      style: style,
      alignment: alignment,
      autoCloseDuration: autoCloseSec ? duration : null,
      animationDuration: const Duration(milliseconds: 250),
      closeOnClick: true,
      pauseOnHover: true,
      dragToClose: true,
      showProgressBar: autoCloseSec,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
    );
  }
}
{{/design_system}}
