import 'dart:io';
import 'package:mason/mason.dart';
import 'anchor_patcher.dart';
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

void run(HookContext context) {
  final vars = context.vars;
  final featureName = ReCase(vars['feature_name'] as String).snakeCase;
  final entityName = vars['entity_name'] as String;
  final entitySnake = ReCase(entityName).snakeCase;

  final cwd = Directory.current.path;
  final injectionPath = '$cwd/lib/features/$featureName/injection.dart';
  final packageName = _readPackageName(cwd);

  // Register the datasource using I{Name}RemoteDataSource interface
  final datasourceRegistration = '''
  getIt.registerLazySingleton<I${entityName}RemoteDataSource>(
    () => ${entityName}RemoteDataSource(dio: getIt()),
  );''';

  patchAnchor(
    context: context,
    filePath: injectionPath,
    anchor: '// mason:datasources',
    insertion: datasourceRegistration,
  );

  _addImportsIfMissing(
    filePath: injectionPath,
    imports: [
      "import 'package:$packageName/features/$featureName/data/datasources/${entitySnake}_remote_datasource.dart';",
    ],
  );

  context.logger.success(
    'Datasource brick: injection.dart patched for $entityName in $featureName feature.',
  );
}

void _addImportsIfMissing({
  required String filePath,
  required List<String> imports,
}) {
  final file = File(filePath);
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  for (final imp in imports) {
    if (!content.contains(imp)) {
      // Insert after the get_it import
      content = content.replaceFirst(
        "import 'package:get_it/get_it.dart';",
        "import 'package:get_it/get_it.dart';\n$imp",
      );
    }
  }
  file.writeAsStringSync(content);
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
