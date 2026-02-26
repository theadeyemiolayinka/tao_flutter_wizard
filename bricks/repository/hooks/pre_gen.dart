import 'package:mason/mason.dart';

/// Pre-generation hook for the [repository] brick.
///
/// Parses the `methods` list (each item like `"getUser(String id):User"`)
/// into structured maps so Mustache templates can access:
///   {{methodName}}, {{signature}}, {{params}}, {{returnType}}, {{isEntity}}
void run(HookContext context) {
  final rawMethods = context.vars['methods'];
  final entityName = context.vars['entity_name'] as String;

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
    final signaturePart = clean.substring(0, colonIdx).trim(); // e.g. "getUser(String id)"
    final returnType = clean.substring(colonIdx + 1).trim();   // e.g. "User"

    // Extract method name (before first '(')
    final parenIdx = signaturePart.indexOf('(');
    final methodName = parenIdx == -1
        ? signaturePart
        : signaturePart.substring(0, parenIdx).trim();

    // Check if the return type matches the entity (for model suffix in datasource)
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
  };
}
