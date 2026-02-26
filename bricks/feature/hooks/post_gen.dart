import 'package:mason/mason.dart';

/// Post-generation hook for the [feature] brick.
///
/// Logs instructions to the developer about the next steps after
/// scaffolding a new feature:
///   1. Add the feature's injection setup to the app's DI registration.
///   2. Merge the feature's routes into the app router.
///   3. Add the ARB file to l10n.yaml.
///   4. Run build_runner for Freezed code generation.
void run(HookContext context) {
  final featureName = context.vars['feature_name'] as String;
  final featureSnake = featureName
      .replaceAllMapped(
        RegExp(r'(?<=[a-z0-9])[A-Z]'),
        (m) => '_${m.group(0)!.toLowerCase()}',
      )
      .toLowerCase();

  context.logger
    ..success('Feature "$featureName" scaffold generated!')
    ..info('')
    ..info('Next steps:')
    ..info(
      '  1. In your app DI setup, call:\n'
      '       register${_toPascalCase(featureSnake)}Dependencies(getIt);',
    )
    ..info(
      '  2. In your app router, merge the routes:\n'
      '       ...${_toCamelCase(featureSnake)}Routes,',
    )
    ..info(
      '  3. Add to l10n.yaml:\n'
      '       - lib/features/$featureSnake/l10n/${featureSnake}_en.arb',
    )
    ..info(
      '  4. Run:\n'
      '       dart run build_runner build --delete-conflicting-outputs',
    );
}

String _toPascalCase(String snake) {
  return snake.split('_').map((p) => p[0].toUpperCase() + p.substring(1)).join();
}

String _toCamelCase(String snake) {
  final parts = snake.split('_');
  return parts.first +
      parts.skip(1).map((p) => p[0].toUpperCase() + p.substring(1)).join();
}
