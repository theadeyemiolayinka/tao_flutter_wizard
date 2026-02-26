import 'dart:io';
import 'package:mason/mason.dart';
import 'anchor_patcher.dart';
import 'package:recase/recase.dart';

void run(HookContext context) {
  final vars = context.vars;
  final featureName = ReCase(vars['feature_name'] as String).snakeCase;
  final entityName = vars['entity_name'] as String;
  final entitySnake = ReCase(entityName).snakeCase;

  final cwd = Directory.current.path;
  final injectionPath = '$cwd/lib/features/$featureName/injection.dart';

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

  _addImportsIfMissing(
    filePath: injectionPath,
    imports: [
      "import '../../data/datasources/${entitySnake}_remote_datasource.dart';",
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
      content = content.replaceFirst(
        "import 'package:get_it/get_it.dart';",
        "import 'package:get_it/get_it.dart';\n$imp",
      );
    }
  }
  file.writeAsStringSync(content);
}
