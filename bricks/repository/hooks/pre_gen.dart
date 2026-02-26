import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Pre-generation hook for the [repository] brick.
///
/// Parses the `methods` list (each item like `"getUser(String id):User"`)
/// into structured maps so Mustache templates can access:
///   {{methodName}}, {{signature}}, {{params}}, {{returnType}}, {{isEntity}}
/// Also injects `package_name` for package: style imports in templates.
void run(HookContext context) {
  final rawMethods = context.vars['methods'];
  final entityName = context.vars['entity_name'] as String;
  final packageName = _readPackageName(Directory.current.path);

  final List<String> items;
  if (rawMethods is List) {
    items = rawMethods.map((e) => e.toString().trim()).toList();
  } else if (rawMethods is String && rawMethods.isNotEmpty) {
    items = rawMethods
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else {
    items = [];
  }

  final parsedMethods = items.map((item) {
    final clean = item.replaceAll('[', '').replaceAll(']', '').trim();
    // Format: methodName(params):ReturnType
    final colonIdx = clean.lastIndexOf(':');
    if (colonIdx == -1) {
      return {
        'methodName': clean,
        'signature': clean,
        'params': '',
        'returnType': 'void',
        'isEntity': false,
      };
    }
    final signaturePart = clean.substring(0, colonIdx).trim();
    final returnType = clean.substring(colonIdx + 1).trim();

    final parenIdx = signaturePart.indexOf('(');
    final methodName = parenIdx == -1
        ? signaturePart
        : signaturePart.substring(0, parenIdx).trim();

    final isEntity = returnType == entityName ||
        returnType == 'List<$entityName>';

    return {
      'methodName': methodName,
      'signature': signaturePart,
      'params': parenIdx == -1 ? '' : signaturePart.substring(parenIdx + 1, signaturePart.lastIndexOf(')')).trim(),
      'returnType': returnType,
      'isEntity': isEntity,
    };
  }).toList();

  context.vars = {
    ...context.vars,
    'methods': parsedMethods,
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
