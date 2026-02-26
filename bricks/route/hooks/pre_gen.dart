import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Pre-generation hook for the [route] brick.
///
/// Injects `package_name` into vars so the core/routes/app_routes.dart
/// template (in __brick__) renders with correct package: style imports.
void run(HookContext context) {
  final packageName = _readPackageName(Directory.current.path);
  context.vars = {
    ...context.vars,
    'package_name': packageName,
  };
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
