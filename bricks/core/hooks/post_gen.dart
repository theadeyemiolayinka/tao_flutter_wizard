import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  final cwd = Directory.current.path;
  final coreDir = Directory('$cwd/lib/core');

  _deleteEmptyFiles(coreDir, context);
  _deleteEmptyDirs(coreDir);

  _patchInjection(cwd, context);

  context.logger
    ..success('Core scaffold generated!')
    ..info('')
    ..info('Next steps:')
    ..info('  1. Run: dart run build_runner build --delete-conflicting-outputs')
    ..info('     (generates .freezed.dart and .g.dart files)')
    ..info('  2. If you chose config/envied: create a .env file at project root')
    ..info('  3. Add to main.dart:')
    ..info('       Bloc.observer = const AppBlocObserver();')
    ..info('       registerCoreDependencies(GetIt.instance);')
    ..info('  4. Wire appRouter + AppTheme in your MaterialApp.router');
}

void _deleteEmptyFiles(Directory dir, HookContext context) {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true)) {
    if (entity is File && entity.readAsStringSync().trim().isEmpty) {
      entity.deleteSync();
      context.logger.detail('Removed empty file: ${entity.path}');
    }
  }
}

void _deleteEmptyDirs(Directory dir) {
  if (!dir.existsSync()) return;
  for (final entity in dir.listSync(recursive: true).reversed) {
    if (entity is Directory && entity.listSync().isEmpty) {
      entity.deleteSync();
    }
  }
}

void _patchInjection(String cwd, HookContext context) {
  final network = context.vars['network'] as bool? ?? false;
  final themeCubit = (context.vars['theme'] as bool? ?? false) &&
      (context.vars['theme_cubit'] as bool? ?? false);
  final blocObserver = context.vars['bloc_observer'] as bool? ?? false;

  final file = File('$cwd/lib/core/injection.dart');
  if (!file.existsSync()) return;

  var content = file.readAsStringSync();
  final packageName = context.vars['package_name'] as String? ?? 'app';

  if (network) {
    const networkAnchor = '// mason:core-network';
    const networkImport = "import 'package:dio/dio.dart';";
    if (!content.contains('DioClient') && content.contains(networkAnchor)) {
      if (!content.contains(networkImport)) {
        content = "$networkImport\nimport 'package:$packageName/core/network/dio_client.dart';\n$content";
      }
      content = content.replaceFirst(
        networkAnchor,
        '  getIt\n    ..registerLazySingleton(Dio.new)\n    ..registerLazySingleton(DioClient.new);\n  $networkAnchor',
      );
    }
  }

  if (themeCubit) {
    const blocsAnchor = '// mason:core-blocs';
    if (!content.contains('ThemeCubit') && content.contains(blocsAnchor)) {
      content = "import 'package:$packageName/core/theme/cubit/theme_cubit.dart';\n$content";
      content = content.replaceFirst(
        blocsAnchor,
        '  getIt.registerLazySingleton(ThemeCubit.new);\n  $blocsAnchor',
      );
    }
  }

  file.writeAsStringSync(content);
  if (network || themeCubit) {
    context.logger.success('Patched lib/core/injection.dart');
  }
}
