import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';
import 'package:yaml/yaml.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final featureNameRaw = context.vars['feature_name'] as String;
  final blocNameRaw = context.vars['bloc_name'] as String;

  final featureName = ReCase(featureNameRaw);
  final blocName = ReCase(blocNameRaw);

  final cwd = Directory.current.path;
  final packageName = _readPackageName(cwd);

  // Path to the feature's injection.dart
  final injectionPath = p.join(
    cwd,
    'lib',
    'features',
    featureName.snakeCase,
    'injection.dart',
  );

  final file = File(injectionPath);

  if (!file.existsSync()) {
    logger.warn(
      'Could not find injection.dart at $injectionPath. Skipping auto-injection.',
    );
    return;
  }

  var content = await file.readAsString();

  // 1. Inject the import statement (package: style, correct path - no subdir)
  final importStatement =
      "import 'package:$packageName/features/${featureName.snakeCase}/presentation/bloc/${blocName.snakeCase}_bloc.dart';\n";
  if (!content.contains(importStatement.trim())) {
    final importRegex = RegExp(r"import '.*?';\n");
    final matches = importRegex.allMatches(content);
    if (matches.isNotEmpty) {
      final lastImportEnd = matches.last.end;
      content = content.substring(0, lastImportEnd) +
          importStatement +
          content.substring(lastImportEnd);
    } else {
      content = importStatement + content;
    }
  }

  // 2. Inject the DI registration under // mason:blocs
  final registrationCode =
      '  getIt.registerFactory(() => ${blocName.pascalCase}Bloc());\n';
  const anchor = '// mason:blocs';

  if (content.contains(anchor) &&
      !content.contains('${blocName.pascalCase}Bloc()')) {
    content = content.replaceFirst(anchor, '$anchor\n$registrationCode');
  } else if (!content.contains(anchor)) {
    logger.warn(
      'Could not find anchor "$anchor" in injection.dart. Skipping DI registration.',
    );
  }

  await file.writeAsString(content);
  logger.success('Auto-injected ${blocName.pascalCase}Bloc into injection.dart');
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

