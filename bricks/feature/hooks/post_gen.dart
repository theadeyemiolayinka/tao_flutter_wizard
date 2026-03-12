import 'dart:convert';
import 'dart:io';
import 'package:mason/mason.dart';
import 'package:yaml/yaml.dart';

/// Post-generation hook for the [feature] brick.
///
/// 1. Ensures lib/core/routes/app_routes.dart exists and patches it with the
///    default INDEX route entry for this feature.
/// 2. Merges the feature's l10n key into lib/l10n/app_en.arb (if present).
/// 3. Patches lib/main.dart with the feature's DI registration call
///    (if the // mason:core-feature-regis anchor is present).
/// 4. Logs next steps for the developer.
void run(HookContext context) {
  final featureNameRaw = context.vars['feature_name'] as String;
  final featureSnake = _toSnakeCase(featureNameRaw);
  final featurePascal = _toPascalCase(featureSnake);
  final featureCamel = _toCamelCase(featureSnake);

  final cwd = Directory.current.path;
  final packageName = _readPackageName(cwd);
  final appRoutesPath = '$cwd/lib/core/routes/app_routes.dart';

  context.vars = {
    ...context.vars,
    'package_name': packageName,
  };

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

  // 3. Merge l10n key into lib/l10n/app_en.arb
  _mergeL10nKey(
    cwd: cwd,
    featureSnake: featureSnake,
    featureCamel: featureCamel,
    context: context,
  );

  // 4. Patch main.dart with the feature DI registration
  _patchMainDart(
    cwd: cwd,
    featurePascal: featurePascal,
    packageName: packageName,
    context: context,
  );

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
      '  3. Run flutter gen-l10n to regenerate localizations:\n'
      '       flutter gen-l10n',
    )
    ..info(
      '  4. Run:\n'
      '       dart run build_runner build --delete-conflicting-outputs',
    );
}

// ─── L10n merger ──────────────────────────────────────────────────────────────

/// Merges the feature's single title key into lib/l10n/app_en.arb using the
/// "@@x-mason-anchor" sentinel key as insert point.
///
/// If the base ARB does not exist yet (core brick was run without generating
/// it), the function is a no-op and the developer is reminded to run the core
/// brick first.
void _mergeL10nKey({
  required String cwd,
  required String featureSnake,
  required String featureCamel,
  required HookContext context,
}) {
  final baseArbFile = File('$cwd/lib/l10n/app_en.arb');
  if (!baseArbFile.existsSync()) {
    context.logger.warn(
      'lib/l10n/app_en.arb not found – run the core brick first to generate '
      'the l10n base files, then re-run this feature brick or add the key manually.',
    );
    return;
  }

  final featureArbFile = File(
    '$cwd/lib/features/$featureSnake/l10n/${featureSnake}_en.arb',
  );

  Map<String, dynamic> featureArb = {};
  if (featureArbFile.existsSync()) {
    try {
      featureArb =
          json.decode(featureArbFile.readAsStringSync()) as Map<String, dynamic>;
    } catch (_) {
      context.logger.warn('Could not parse ${featureArbFile.path} – skipping l10n merge.');
      return;
    }
  }

  try {
    final baseContent = baseArbFile.readAsStringSync();
    final baseArb = json.decode(baseContent) as Map<String, dynamic>;

    const anchorKey = '@@x-mason-anchor';
    if (!baseArb.containsKey(anchorKey)) {
      context.logger.warn(
        'lib/l10n/app_en.arb does not contain the "$anchorKey" anchor – cannot auto-merge.',
      );
      return;
    }

    // Build the merged map: insert feature keys before the anchor
    final merged = <String, dynamic>{};
    for (final entry in baseArb.entries) {
      if (entry.key == anchorKey) {
        // Insert feature keys (skip @@ metadata keys already in base)
        for (final fe in featureArb.entries) {
          if (!fe.key.startsWith('@@') && !merged.containsKey(fe.key)) {
            merged[fe.key] = fe.value;
          }
        }
      }
      merged[entry.key] = entry.value;
    }

    const encoder = JsonEncoder.withIndent('  ');
    baseArbFile.writeAsStringSync('${encoder.convert(merged)}\n');
    context.logger.success(
      'Merged $featureSnake l10n keys into lib/l10n/app_en.arb',
    );
  } catch (e) {
    context.logger.warn('Failed to merge l10n keys: $e');
  }
}

// ─── main.dart patcher ────────────────────────────────────────────────────────

/// Inserts `setup<Feature>Feature(GetIt.instance);` before the
/// `// mason:core-feature-regis` anchor in lib/main.dart (if it exists).
void _patchMainDart({
  required String cwd,
  required String featurePascal,
  required String packageName,
  required HookContext context,
}) {
  final mainFile = File('$cwd/lib/main.dart');
  if (!mainFile.existsSync()) return;

  const anchor = '// mason:core-feature-regis';
  var content = mainFile.readAsStringSync();

  if (!content.contains(anchor)) return;

  final registration = '  setup${featurePascal}Feature(GetIt.instance);';
  if (content.contains(registration.trim())) return; // already present

  final featureSnake = _toSnakeCase(featurePascal);
  final injectionImport =
      "import 'package:$packageName/features/$featureSnake/$featureSnake.dart';";
  if (!content.contains(injectionImport)) {
    final lines = content.split('\n');
    final lastImportIdx = lines.lastIndexWhere(
      (l) => l.trimLeft().startsWith('import '),
    );
    if (lastImportIdx >= 0) {
      lines.insert(lastImportIdx + 1, injectionImport);
      content = lines.join('\n');
    }
  }

  content = content.replaceFirst(
    anchor,
    '$registration\n  $anchor',
  );

  mainFile.writeAsStringSync(content);
  context.logger.success(
    'Patched lib/main.dart with setup${featurePascal}Feature(GetIt.instance)',
  );
}

// ─── AppRoutes helpers ────────────────────────────────────────────────────────

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

// ─── Utilities ────────────────────────────────────────────────────────────────

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
