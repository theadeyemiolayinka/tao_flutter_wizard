import 'package:mason/mason.dart';

/// Pre-generation hook for the [entity] brick.
///
/// Parses the `fields` list (each item a string like `"id:int"` or `"name:String?"`)
/// into structured maps with `name`, `type`, and `isnullable` keys before
/// the templates are rendered - because Mustache can't split strings itself.
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
    // Strip any stray brackets/spaces from individual items (e.g. "[id:int" or "age:double]")
    final clean = item.replaceAll('[', '').replaceAll(']', '').trim();
    final colonIdx = clean.indexOf(':');
    if (colonIdx == -1) {
      // Malformed - skip with a placeholder
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

  context.vars = {
    ...context.vars,
    'fields': parsedFields,
  };
}
