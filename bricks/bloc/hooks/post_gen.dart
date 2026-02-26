import 'dart:io';
import 'package:mason/mason.dart';
import 'package:path/path.dart' as p;
import 'package:recase/recase.dart';

Future<void> run(HookContext context) async {
  final logger = context.logger;
  final featureNameRaw = context.vars['feature_name'] as String;
  final blocNameRaw = context.vars['bloc_name'] as String;

  final featureName = ReCase(featureNameRaw);
  final blocName = ReCase(blocNameRaw);

  // Path to the feature's injection.dart
  final injectionPath = p.join(
    Directory.current.path,
    'lib',
    'features',
    featureName.snakeCase,
    'injection.dart',
  );

  final file = File(injectionPath);

  if (!file.existsSync()) {
    logger.warn('Could not find injection.dart at $injectionPath. Skipping auto-injection.');
    return;
  }

  var content = await file.readAsString();

  // 1. Inject the import statement at the top of the file
  final importStatement = "import 'presentation/bloc/${blocName.snakeCase}_bloc/${blocName.snakeCase}_bloc.dart';\n";
  if (!content.contains(importStatement.trim())) {
    // Find the last import statement
    final importRegex = RegExp(r"import '.*?';\n");
    final matches = importRegex.allMatches(content);
    if (matches.isNotEmpty) {
      final lastImportEnd = matches.last.end;
      content = content.substring(0, lastImportEnd) + importStatement + content.substring(lastImportEnd);
    } else {
      content = importStatement + content;
    }
  }

  // 2. Inject the DI registration under // mason:blocs
  final registrationCode = "  getIt.registerFactory(() => ${blocName.pascalCase}Bloc());\n";
  final anchor = '// mason:blocs';

  if (content.contains(anchor) && !content.contains("${blocName.pascalCase}Bloc()")) {
    content = content.replaceFirst(anchor, '$anchor\n$registrationCode');
  } else if (!content.contains(anchor)) {
    logger.warn('Could not find anchor "$anchor" in injection.dart. Skipping DI registration.');
  }

  await file.writeAsString(content);
  logger.success('Auto-injected ${blocName.pascalCase}Bloc into injection.dart');
}
