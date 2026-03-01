import 'dart:io';
import 'package:mason/mason.dart';

/// Post-generation hook for the [usecase] brick.
///
/// After the UseCase file is generated, this hook patches the feature's
/// `injection.dart` by inserting a lazy-singleton registration under
/// the `// mason::usecases` marker.
///
/// Requires that `mason make feature` was run first (so the marker exists).
void run(HookContext context) {
  final featureName = context.vars['feature_name'] as String;
  final usecaseName = context.vars['usecase_name'] as String;

  final snakeFeature = _toSnakeCase(featureName);
  final pascalUsecase = _toPascalCase(usecaseName);

  final injectionPath = 'lib/features/$snakeFeature/injection.dart';
  final injectionFile = File(injectionPath);

  if (!injectionFile.existsSync()) {
    context.logger.warn(
      'Could not find $injectionPath - skipping auto-registration.\n'
      'Run `mason make feature --feature-name $snakeFeature` first, then add:\n'
      '  getIt.registerLazySingleton<${pascalUsecase}UseCase>(\n'
      '    () => ${pascalUsecase}UseCase(getIt()),\n'
      '  );',
    );
    return;
  }

  final content = injectionFile.readAsStringSync();
  const marker = '// mason::usecases';

  if (!content.contains(marker)) {
    context.logger.warn(
      '$injectionPath does not contain the "$marker" marker.\n'
      'Add it manually and re-run, or insert the registration yourself:\n'
      '  getIt.registerLazySingleton<${pascalUsecase}UseCase>(\n'
      '    () => ${pascalUsecase}UseCase(getIt()),\n'
      '  );',
    );
    return;
  }

  final registration = '''
  getIt.registerLazySingleton<${pascalUsecase}UseCase>(
    () => ${pascalUsecase}UseCase(getIt()),
  );''';

  if (content.contains('${pascalUsecase}UseCase')) {
    context.logger.info(
      '${pascalUsecase}UseCase is already registered in $injectionPath - skipping.',
    );
    return;
  }

  final updated = content.replaceFirst(marker, '$marker\n$registration');
  injectionFile.writeAsStringSync(updated);

  context.logger.success(
    'Registered ${pascalUsecase}UseCase in $injectionPath',
  );
}

/// Converts a string to snake_case (handles both PascalCase and camelCase).
String _toSnakeCase(String input) {
  return input
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])([A-Z])'),
        (m) => '_${m.group(1)}',
      )
      .toLowerCase();
}

/// Converts a string to PascalCase (handles both snake_case and camelCase).
String _toPascalCase(String input) {
  if (input.isEmpty) return input;
  // If already PascalCase (no underscores, starts with uppercase)
  if (!input.contains('_') && input[0] == input[0].toUpperCase()) return input;
  return input
      .split('_')
      .map((word) =>
          word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1))
      .join();
}
