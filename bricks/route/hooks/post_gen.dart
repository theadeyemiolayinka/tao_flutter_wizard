import 'dart:io';
import 'package:mason/mason.dart';
import 'anchor_patcher.dart';
import 'package:yaml/yaml.dart';

/// Post-generation hook for the [route] brick.
///
/// Automatically patches the feature's `routes.dart` to add the new route
/// to the `<featureName>Routes` list above the `// mason:routes` anchor.
/// Imports use package: style resolved from pubspec.yaml.
void run(HookContext context) {
  final vars = context.vars;
  final featureName = _toSnakeCase(vars['feature_name'] as String);
  final featureCamel = _toCamelCase(featureName);
  final pageName = vars['page_name'] as String;
  final pageSnake = _toSnakeCase(pageName);
  final pageCamel = _toCamelCase(pageSnake);

  final cwd = Directory.current.path;
  final routesPath = '$cwd/lib/features/$featureName/routes.dart';
  final packageName = _readPackageName(cwd);

  // Insert the route getter reference above // mason:routes
  final routeEntry = '  ${pageCamel}Route,';

  patchAnchor(
    context: context,
    filePath: routesPath,
    anchor: '// mason:routes',
    insertion: routeEntry,
  );

  // Add the import for the new route file using package: style
  _addImportIfMissing(
    filePath: routesPath,
    import:
        "import 'package:$packageName/features/$featureName/routes/${pageSnake}_route.dart';",
  );

  context.logger.success(
    'Route brick: routes.dart patched for $pageName in $featureName feature.',
  );
}

void _addImportIfMissing({
  required String filePath,
  required String import,
}) {
  final file = File(filePath);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  if (content.contains(import)) return;

  content = content.replaceFirst(
    "import 'package:go_router/go_router.dart';",
    "import 'package:go_router/go_router.dart';\n$import",
  );
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

String _toCamelCase(String snakeCase) {
  final parts = snakeCase.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
