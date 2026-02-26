import 'dart:io';
import 'package:mason/mason.dart';
import 'anchor_patcher.dart';

/// Post-generation hook for the [repository] brick.
///
/// Automatically patches the feature's `injection.dart` with:
/// - DataSource registration (above `// mason:datasources`)
/// - Repository registration (above `// mason:repositories`)
void run(HookContext context) {
  final vars = context.vars;
  final featureName = _toSnakeCase(vars['feature_name'] as String);
  final entityName = vars['entity_name'] as String;
  final entitySnake = _toSnakeCase(entityName);

  // Resolve paths relative to where `mason make` was run (project root).
  final cwd = Directory.current.path;
  final injectionPath =
      '$cwd/lib/features/$featureName/injection.dart';

  // 1. Register remote datasource (above // mason:datasources)
  final datasourceRegistration = '''
  getIt.registerLazySingleton<${entityName}RemoteDataSource>(
    () => ${entityName}RemoteDataSourceImpl(dio: getIt()),
  );''';

  patchAnchor(
    context: context,
    filePath: injectionPath,
    anchor: '// mason:datasources',
    insertion: datasourceRegistration,
  );

  // 2. Register repository (above // mason:repositories)
  final repositoryRegistration = '''
  getIt.registerLazySingleton<I${entityName}Repository>(
    () => ${entityName}Repository(
      remoteDataSource: getIt(),
    ),
  );''';

  patchAnchor(
    context: context,
    filePath: injectionPath,
    anchor: '// mason:repositories',
    insertion: repositoryRegistration,
  );

  // 3. Add import lines to injection.dart if not already there
  _addImportsIfMissing(
    filePath: injectionPath,
    imports: [
      "import '../../data/datasources/${entitySnake}_remote_datasource.dart';",
      "import '../../data/repositories/${entitySnake}_repository.dart';",
      "import '../../domain/repositories/i_${entitySnake}_repository.dart';",
    ],
  );

  context.logger.success(
    'Repository brick: injection.dart patched for $entityName in $featureName feature.',
  );
}

/// Adds missing import statements immediately after the `package:get_it` import.
void _addImportsIfMissing({
  required String filePath,
  required List<String> imports,
}) {
  final file = File(filePath);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  for (final imp in imports) {
    if (!content.contains(imp)) {
      content = content.replaceFirst(
        "import 'package:get_it/get_it.dart';",
        "import 'package:get_it/get_it.dart';\n$imp",
      );
    }
  }
  file.writeAsStringSync(content);
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )
      .toLowerCase();
}
