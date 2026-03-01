import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Pre-generation hook for the [dto] brick.
///
/// Reads the project's pubspec.yaml to inject the package name.
/// Parses the [fields] list (each item "name:type" or "name:type?")
/// into structured maps: { name, type, isNullable }.
/// Sets [has_fields] boolean.
void run(HookContext context) {
  final packageName = _readPackageName(Directory.current.path);

  final rawFields = context.vars['fields'];

  final List<String> fieldStrings;
  if (rawFields is List) {
    fieldStrings = rawFields
        .map((e) => e.toString().trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else if (rawFields is String && rawFields.isNotEmpty) {
    fieldStrings = rawFields
        .replaceAll('[', '')
        .replaceAll(']', '')
        .split('|')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  } else {
    fieldStrings = [];
  }

  final parsedFields = fieldStrings.map((item) {
    final clean = item.replaceAll('[', '').replaceAll(']', '').trim();
    final colonIdx = clean.indexOf(':');
    if (colonIdx == -1) {
      return {'name': clean, 'type': 'dynamic', 'isnullable': false};
    }
    final fieldName = clean.substring(0, colonIdx).trim();
    final fieldType = clean.substring(colonIdx + 1).trim();
    final isNullable = fieldType.endsWith('?');
    final cleanType =
        isNullable ? fieldType.substring(0, fieldType.length - 1) : fieldType;
    return {
      'name': fieldName,
      'type': cleanType,
      'isnullable': isNullable,
    };
  }).toList();

  context.vars = {
    ...context.vars,
    'package_name': packageName,
    'fields': parsedFields,
    'has_fields': parsedFields.isNotEmpty,
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
