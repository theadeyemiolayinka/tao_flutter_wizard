{{#theme}}
/// Spacing scale - all values are multiples of 4.
///
/// Reference anywhere in the app without context:
/// ```dart
/// SizedBox(height: AppSpacing.md)
/// Padding(padding: EdgeInsets.all(AppSpacing.lg))
/// ```
abstract final class AppSpacing {
  /// 2 px - hairline gaps, thin dividers
  static const double xxs = 2;

  /// 4 px - tightest intentional spacing
  static const double xs = 4;

  /// 8 px - compact spacing (icon padding, small gaps)
  static const double sm = 8;

  /// 12 px - between related elements
  static const double smMd = 12;

  /// 16 px - default content padding
  static const double md = 16;

  /// 20 px - between sections inside a card
  static const double mdLg = 20;

  /// 24 px - between distinct blocks
  static const double lg = 24;

  /// 32 px - section margins
  static const double xl = 32;

  /// 48 px - large section separators
  static const double xxl = 48;

  /// 64 px - page-level vertical breathing room
  static const double xxxl = 64;

  /// Horizontal screen edge insets (16 px each side)
  static const double screenHorizontal = md;

  /// Vertical screen top/bottom insets (24 px)
  static const double screenVertical = lg;
}
{{/theme}}
