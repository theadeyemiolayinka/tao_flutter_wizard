/// Central route name registry.
/// Auto-patched by Mason [route] and [feature] bricks via hook.
///
/// Naming convention for enum entries drives path resolution:
///   FEATURE__PAGE              => /feature/page
///   FEATURE__ITEMS___ITEM_ID   => /feature/items/:item_id
///   A__B___ID__C___OTHER_ID    => /a/b/:id/c/:other_id
///
/// Rules:
///   __   = path segment separator
///   ___  = path parameter prefix (the rest of that segment is the param name)
enum AppRoutes {
  // mason:app_routes
}

extension AppRoutesX on AppRoutes {
  /// Resolves this enum entry to its GoRouter path string.
  String get path {
    // Replace triple-underscore with a null-byte placeholder FIRST so it
    // isn't accidentally split when we split on double-underscore.
    final raw = name.replaceAll('___', '\x00');
    final segments = raw.split('__').where((s) => s.isNotEmpty);
    final parts = segments.map((s) {
      if (s.startsWith('\x00')) {
        // Path parameter — strip placeholder, convert to lowercase.
        return ':${s.substring(1).toLowerCase()}';
      }
      // Regular segment — lowercase.
      return s.toLowerCase();
    });
    return '/${parts.join('/')}';
  }

  /// The route name used by GoRouter (lowercase enum name).
  String get routeName => name.toLowerCase();
}
