import 'dart:io';
import 'package:mason/mason.dart';
import 'anchor_patcher.dart';
import 'package:yaml/yaml.dart';

/// Post-generation hook for the [route] brick.
///
/// 1. Ensures lib/core/routes/app_routes.dart exists (creates it if missing).
/// 2. Patches the AppRoutes enum with a new entry (// mason:app_routes anchor).
/// 3. Inlines a GoRoute(...) entry into lib/features/{feature}/routes.dart.
/// 4. Adds necessary imports to routes.dart (page + AppRoutes).
void run(HookContext context) {
  final vars = context.vars;
  final featureNameRaw = vars['feature_name'] as String;
  final pageNameRaw = vars['page_name'] as String;

  // path_params is a list of extraction strings, e.g.:
  //   ['final id = state.pathParameters["id"]!;', ...]
  final rawPathParams = vars['path_params'];
  final List<String> pathParams;
  if (rawPathParams is List) {
    pathParams = rawPathParams
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else if (rawPathParams is String && rawPathParams.isNotEmpty) {
    pathParams = rawPathParams
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else {
    pathParams = [];
  }

  final featureName = _toSnakeCase(featureNameRaw);
  final pageNameSnake = _toSnakeCase(pageNameRaw);
  final pageNamePascal = _toPascalCase(pageNameSnake);

  // Build the AppRoutes enum entry from feature + page name.
  // The page_name itself may contain ___ for path params (e.g. UserDetail___Id).
  final routeEnumEntry = _buildEnumEntry(featureName, pageNameSnake);

  final cwd = Directory.current.path;
  final packageName = _readPackageName(cwd);

  final appRoutesPath = '$cwd/lib/core/routes/app_routes.dart';
  final routesDartPath = '$cwd/lib/features/$featureName/routes.dart';

  // 1. Ensure core/routes/app_routes.dart exists.
  _ensureAppRoutesFile(appRoutesPath, context);

  // 2. Patch AppRoutes enum with the new entry.
  patchAnchor(
    context: context,
    filePath: appRoutesPath,
    anchor: '// mason:app_routes',
    insertion: '  $routeEnumEntry,',
  );

  // 3. Build the inline GoRoute entry.
  final hasParams = pathParams.isNotEmpty;

  // Build param extraction block (indented inside builder).
  final paramsBlock = hasParams
      ? pathParams.map((p) => '      $p').join('\n') + '\n'
      : '';

  // Page constructor: const if no params, otherwise requires params.
  final pageConstructor = hasParams
      ? '${pageNamePascal}Page(/* TODO: pass extracted params */)'
      : 'const ${pageNamePascal}Page()';

  final goRouteEntry = '''
  GoRoute(
    path: AppRoutes.$routeEnumEntry.path,
    name: AppRoutes.$routeEnumEntry.routeName,
    builder: (context, state) {
${paramsBlock}      return $pageConstructor;
    },
  ),''';

  patchAnchor(
    context: context,
    filePath: routesDartPath,
    anchor: '// mason:routes',
    insertion: goRouteEntry,
  );

  // 4. Add imports to routes.dart.
  _addImportsIfMissing(
    filePath: routesDartPath,
    imports: [
      "import 'package:$packageName/core/routes/app_routes.dart';",
      "import 'package:$packageName/features/$featureName/presentation/pages/${pageNameSnake}_page.dart';",
    ],
    afterImport: "import 'package:go_router/go_router.dart';",
  );

  context.logger.success(
    'Route brick: AppRoutes.$routeEnumEntry added; '
    'GoRoute inlined into features/$featureName/routes.dart.',
  );
}

/// Builds the AppRoutes enum constant name.
/// Converts feature_name + page_name to FEATURE__PAGE format.
/// Page name may already contain ___ for path params.
String _buildEnumEntry(String featureSnake, String pageSnake) {
  final feature = featureSnake.toUpperCase();
  final page = pageSnake.toUpperCase();
  return '${feature}__$page';
}

/// Creates lib/core/routes/app_routes.dart if it doesn't exist yet.
void _ensureAppRoutesFile(String filePath, HookContext context) {
  final file = File(filePath);
  if (file.existsSync()) return;

  file.parent.createSync(recursive: true);
  file.writeAsStringSync(r"""// ignore_for_file: constant_identifier_names

/// Central route name registry.
/// Auto-patched by Mason [route] and [feature] bricks via hook.
///
/// Naming convention drives GoRouter path resolution:
///   FEATURE__PAGE              => /feature/page
///   FEATURE__ITEMS___ITEM_ID   => /feature/items/:item_id
///   A__B___ID__C___OTHER_ID    => /a/b/:id/c/:other_id
///
/// Rules:
///   __   = path segment separator
///   ___  = path parameter prefix (segment becomes :param_name)
enum AppRoutes {
  // mason:app_routes
}

extension AppRoutesX on AppRoutes {
  /// Resolves this enum entry to its GoRouter path string.
  String get path {
    final raw = name.replaceAll('___', '\x00');
    final segments = raw.split('__').where((s) => s.isNotEmpty);
    final parts = segments.map((s) {
      if (s.startsWith('\x00')) {
        return ':${s.substring(1).toLowerCase()}';
      }
      return s.toLowerCase();
    });
    return '/${parts.join('/')}';
  }

  /// The route name used by GoRouter (lowercase enum name).
  String get routeName => name.toLowerCase();
}
""");
  context.logger.success('Created lib/core/routes/app_routes.dart');
}

void _addImportsIfMissing({
  required String filePath,
  required List<String> imports,
  required String afterImport,
}) {
  final file = File(filePath);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  for (final imp in imports) {
    if (!content.contains(imp)) {
      if (content.contains(afterImport)) {
        content = content.replaceFirst(afterImport, '$afterImport\n$imp');
      } else {
        content = '$imp\n$content';
      }
    }
  }
  file.writeAsStringSync(content);
}

String _readPackageName(String projectRoot) {
  try {
    final pubspecFile = File('$projectRoot/pubspec.yaml');
    if (!pubspecFile.existsSync()) return 'app';
    final content = pubspecFile.readAsStringSync();
    final yaml = loadYaml(content) as Map;
    return (yaml['name'] as String?) ?? 'app';
  } catch (_) {
    return 'app';
  }
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )
      .toLowerCase();
}

String _toPascalCase(String snake) {
  return snake.split('_').map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
