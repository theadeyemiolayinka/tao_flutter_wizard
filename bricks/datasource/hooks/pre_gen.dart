import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Pre-generation hook for the [datasource] brick.
///
/// Reads the project's pubspec.yaml to inject the package name as a var.
/// Also parses the `methods` list into structured maps for template use
/// when `crud_datasource` is false.
void run(HookContext context) {
  final packageName = _readPackageName(Directory.current.path);
  final isCrud = context.vars['crud_datasource'] as bool? ?? false;

  final rawMethods = context.vars['methods'];

  List<Map<String, dynamic>> parsedMethods = [];

  if (!isCrud) {
    final List<String> methodStrings;
    if (rawMethods is List) {
      methodStrings = rawMethods
          .map((e) => e.toString().trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else if (rawMethods is String && rawMethods.isNotEmpty) {
      methodStrings = rawMethods
          .split('|')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    } else {
      methodStrings = [];
    }

    parsedMethods = methodStrings.map((methodStr) {
      // Format: methodName:ReturnType:param1Name/param1Type,param2Name/param2Type
      final parts = methodStr.split(':');
      final methodName = parts.isNotEmpty ? parts[0].trim() : 'unknown';
      final returnType = parts.length > 1 ? parts[1].trim() : 'void';
      final paramsRaw = parts.length > 2 ? parts[2].trim() : '';

      final params = paramsRaw.isEmpty
          ? <Map<String, String>>[]
          : paramsRaw.split(',').map((p) {
              final pParts = p.trim().split('/');
              return {
                'param_name': pParts.isNotEmpty ? pParts[0].trim() : 'arg',
                'param_type': pParts.length > 1 ? pParts[1].trim() : 'dynamic',
              };
            }).toList();

      final isVoid = returnType == 'void';

      return {
        'method_name': methodName,
        'return_type': isVoid ? 'void' : 'Future<$returnType>',
        'raw_return_type': returnType,
        'is_void': isVoid,
        'params': params,
        'has_params': params.isNotEmpty,
      };
    }).toList();
  }

  context.vars = {
    ...context.vars,
    'package_name': packageName,
    'methods': parsedMethods,
    'crud_datasource': isCrud,
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
