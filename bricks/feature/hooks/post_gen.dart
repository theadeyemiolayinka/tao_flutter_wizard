import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Post-generation hook for the [feature] brick.
///
/// 1. Ensures lib/core/routes/app_routes.dart exists and patches it with the
///    default INDEX route entry for this feature.
/// 2. Logs next steps for the developer.
void run(HookContext context) {
  final featureNameRaw = context.vars['feature_name'] as String;
  final featureSnake = _toSnakeCase(featureNameRaw);
  final featurePascal = _toPascalCase(featureSnake);
  final featureCamel = _toCamelCase(featureSnake);

  final cwd = Directory.current.path;
  final packageName = _readPackageName(cwd);
  final appRoutesPath = '$cwd/lib/core/routes/app_routes.dart';

  // 1. Ensure the core AppRoutes file exists
  _ensureAppRoutesFile(appRoutesPath, context);

  // 2. Patch in the feature's INDEX enum entry
  final enumEntry = '${featureSnake.toUpperCase()}__INDEX';
  _patchAnchor(
    filePath: appRoutesPath,
    anchor: '// mason:app_routes',
    insertion: '  $enumEntry,',
    context: context,
  );

  // 3. Inject package_name into the feature routes.dart (it uses {{package_name}})
  // Note: Mason renders {{package_name}} at generation time from vars; we ensure
  // the var is available via the hook below.
  context.vars = {
    ...context.vars,
    'package_name': packageName,
  };

  context.logger
    ..success('Feature "$featureNameRaw" scaffold generated!')
    ..info('')
    ..info('Next steps:')
    ..info(
      '  1. In your app DI setup, call:\n'
      '       register${featurePascal}Dependencies(getIt);',
    )
    ..info(
      '  2. In your app router, merge the routes:\n'
      '       ...${featureCamel}Routes,',
    )
    ..info(
      '  3. Add to l10n.yaml:\n'
      '       - lib/features/$featureSnake/l10n/${featureSnake}_en.arb',
    )
    ..info(
      '  4. Run:\n'
      '       dart run build_runner build --delete-conflicting-outputs',
    );
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

bool _patchAnchor({
  required String filePath,
  required String anchor,
  required String insertion,
  required HookContext context,
}) {
  final file = File(filePath);
  if (!file.existsSync()) return false;

  final original = file.readAsStringSync();
  if (!original.contains(anchor)) return false;
  if (original.contains(insertion.trim())) return true; // already present

  final patched = original.replaceFirst(
    anchor,
    '${insertion.trimRight()}\n  $anchor',
  );
  file.writeAsStringSync(patched);
  context.logger.success('Patched $filePath with $insertion');
  return true;
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

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
