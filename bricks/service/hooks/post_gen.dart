import 'dart:io';
import 'package:mason/mason.dart';

/// Post-generation hook for the [service] brick.
///
/// After the Service files are generated, this hook patches the feature's
/// `injection.dart` by inserting a lazy-singleton registration under
/// the `// mason::services` marker.
///
/// Requires that `mason make feature` was run first (so the marker exists).
void run(HookContext context) {
  final featureName = context.vars['feature_name'] as String;
  final serviceName = context.vars['service_name'] as String;

  final snakeFeature = _toSnakeCase(featureName);
  final pascalService = _toPascalCase(serviceName);

  final injectionPath = 'lib/features/$snakeFeature/injection.dart';
  final injectionFile = File(injectionPath);

  if (!injectionFile.existsSync()) {
    context.logger.warn(
      'Could not find $injectionPath - skipping auto-registration.\n'
      'Run `mason make feature --feature-name $snakeFeature` first, then add:\n'
      '  getIt.registerLazySingleton<${pascalService}Service>(\n'
      '    () => ${pascalService}ServiceImpl(),\n'
      '  );',
    );
    return;
  }

  final content = injectionFile.readAsStringSync();
  const marker = '// mason::services';

  if (!content.contains(marker)) {
    context.logger.warn(
      '$injectionPath does not contain "$marker". Add it manually or insert:\n'
      '  getIt.registerLazySingleton<${pascalService}Service>(\n'
      '    () => ${pascalService}ServiceImpl(),\n'
      '  );',
    );
    return;
  }

  if (content.contains('${pascalService}Service')) {
    context.logger.info(
      '${pascalService}Service is already registered in $injectionPath - skipping.',
    );
    return;
  }

  final registration = '''
  getIt.registerLazySingleton<${pascalService}Service>(
    () => ${pascalService}ServiceImpl(),
  );''';

  final updated = content.replaceFirst(marker, '$marker\n$registration');
  injectionFile.writeAsStringSync(updated);

  context.logger.success(
    'Registered ${pascalService}Service in $injectionPath',
  );
}

String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])([A-Z])'),
        (m) => '_${m.group(1)}',
      )
      .toLowerCase();
}

String _toPascalCase(String input) {
  if (input.isEmpty) return input;
  if (!input.contains('_') && input[0] == input[0].toUpperCase()) return input;
  return input
      .split('_')
      .map((word) =>
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
      .join();
}
