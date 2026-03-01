{{#theme}}
import 'package:flutter/material.dart';

/// Border radius token system.
///
/// Use these tokens in place of raw [BorderRadius.circular] values so
/// that changing the app's corner style is a one-place change.
///
/// ```dart
/// Container(
///   decoration: BoxDecoration(
///     borderRadius: AppRadius.card,
///   ),
/// )
/// ```
abstract final class AppRadius {
  /// 0 px - no rounding (sharp corners)
  static const double none = 0;

  /// 4 px - slight softening (chips, tags)
  static const double xs = 4;

  /// 8 px - small elements (badges, tooltips)
  static const double sm = 8;

  /// 12 px - cards, text fields (default M3-like)
  static const double md = 12;

  /// 16 px - modals, bottom sheets
  static const double lg = 16;

  /// 24 px - large cards, feature blocks
  static const double xl = 24;

  /// 32 px - hero cards
  static const double xxl = 32;

  /// 999 px - stadium / pill shape (fully rounded)
  static const double full = 999;

  // ── Pre-built BorderRadius shortcuts ───────────────────────────────

  /// Default card radius (12 px)
  static BorderRadius get card => BorderRadius.circular(md);

  /// Default input field radius (12 px)
  static BorderRadius get input => BorderRadius.circular(md);

  /// Default button radius (12 px)
  static BorderRadius get button => BorderRadius.circular(md);

  /// Pill / fully-rounded button radius
  static BorderRadius get pill => BorderRadius.circular(full);

  /// Chip radius (8 px)
  static BorderRadius get chip => BorderRadius.circular(sm);

  /// Bottom sheet top corners (16 px)
  static BorderRadius get bottomSheet => const BorderRadius.only(
        topLeft: Radius.circular(lg),
        topRight: Radius.circular(lg),
      );

  /// Dialog radius (24 px)
  static BorderRadius get dialog => BorderRadius.circular(xl);
}
{{/theme}}
