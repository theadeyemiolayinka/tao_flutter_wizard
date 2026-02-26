import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Pre-generation hook for the [entity] brick.
///
/// Parses the `fields` list (each item a string like `"id:int"` or `"name:String?"`)
/// into structured maps with `name`, `type`, and `isnullable` keys before
/// the templates are rendered - because Mustache can't split strings itself.
/// Also injects `package_name` for use in package-style imports.
void run(HookContext context) {
  final rawFields = context.vars['fields'];

  // Accept both List (from Mason CLI) and String (if passed as single value)
  final List<String> items;
  if (rawFields is List) {
    items = rawFields.map((e) => e.toString().trim()).toList();
  } else if (rawFields is String && rawFields.isNotEmpty) {
    // Fallback: pipe-split if a single string with pipes slipped through
    items = rawFields
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else {
    items = [];
  }

  final parsedFields = items.map((item) {
    // Strip any stray brackets/spaces from individual items
    final clean = item.replaceAll('[', '').replaceAll(']', '').trim();
    final colonIdx = clean.indexOf(':');
    if (colonIdx == -1) {
      return {'name': clean, 'type': 'dynamic', 'isnullable': false};
    }
    final fieldName = clean.substring(0, colonIdx).trim();
    final fieldType = clean.substring(colonIdx + 1).trim();
    final isNullable = fieldType.endsWith('?');
    final cleanType = isNullable ? fieldType.substring(0, fieldType.length - 1) : fieldType;
    return {
      'name': fieldName,
      'type': cleanType,
      'isnullable': isNullable,
    };
  }).toList();

  final packageName = _readPackageName(Directory.current.path);

  context.vars = {
    ...context.vars,
    'fields': parsedFields,
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
