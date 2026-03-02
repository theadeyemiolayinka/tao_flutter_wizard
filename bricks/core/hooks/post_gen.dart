import 'dart:io';
import 'package:mason/mason.dart';

void run(HookContext context) {
  final cwd = Directory.current.path;
  final coreDir = Directory('$cwd/lib/core');
  final libDir = Directory('$cwd/lib');

  _deleteEmptyFiles(libDir, context);
  _deleteEmptyDirs(coreDir);

  _patchInjection(cwd, context);
  _ensureL10nGenDir(cwd, context);

  final setupMain = context.vars['setup_main'] as bool? ?? false;
  final appBloc = context.vars['app_bloc'] as bool? ?? false;
  final blocObserver = context.vars['bloc_observer'] as bool? ?? false;
  final appRouter = context.vars['app_router'] as bool? ?? false;
  final theme = context.vars['theme'] as bool? ?? false;

  context.logger
    ..success('Core scaffold generated!')
    ..info('')
    ..info('Next steps:')
    ..info('  1. Run: dart run build_runner build --delete-conflicting-outputs')
    ..info('     (generates .freezed.dart and .g.dart files)');

  if (!setupMain) {
    context.logger
      ..info('  2. Add to your main.dart:');
    if (blocObserver) {
      context.logger.info('       Bloc.observer = const AppBlocObserver();');
    }
    if (appBloc) {
      context.logger
        ..info('       final storageDir = await getApplicationDocumentsDirectory();')
        ..info('       HydratedBloc.storage = await HydratedStorage.build(')
        ..info('         storageDirectory: HydratedStorageDirectory(storageDir.path),')
        ..info('       );');
    }
    context.logger.info('       registerCoreDependencies(GetIt.instance);');
    if (appRouter && theme) {
      context.logger.info('  3. Wire appRouter + AppTheme in your MaterialApp.router');
    } else if (appRouter) {
      context.logger.info('  3. Wire appRouter in your MaterialApp.router');
    } else if (theme) {
      context.logger.info('  3. Wire AppTheme in your MaterialApp');
    }
  } else {
    context.logger
      ..info('  2. lib/main.dart and lib/app.dart have been generated — review and adjust imports as needed')
      ..info('  3. If you chose config/envied: create a .env file at project root');
  }

  context.logger
    ..info('  ${setupMain ? '4' : (appRouter || theme ? '4' : '3')}. Run: flutter gen-l10n')
    ..info('     (merges all ARB files and generates lib/l10n/generated/app_localizations.dart)');

  if (context.vars['config'] as bool? ?? false) {
    context.logger.info('  • Create a .env file at project root for envied config');
  }
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
  final appBloc = context.vars['app_bloc'] as bool? ?? false;
  final connectivity = context.vars['connectivity'] as bool? ?? false;

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

  if (appBloc) {
    const blocsAnchor = '// mason:core-blocs';
    if (!content.contains('AppBloc') && content.contains(blocsAnchor)) {
      content = "import 'package:$packageName/app/bloc/app_bloc.dart';\n$content";
      final connectivityParam = connectivity
          ? '  getIt.registerLazySingleton(() => AppBloc(connectivityService: getIt()));'
          : '  getIt.registerLazySingleton(AppBloc.new);';
      content = content.replaceFirst(
        blocsAnchor,
        '$connectivityParam\n  $blocsAnchor',
      );
    }
  }

  file.writeAsStringSync(content);
  if (network || appBloc) {
    context.logger.success('Patched lib/core/injection.dart');
  }
}

/// Ensures the lib/l10n/generated/ directory exists so Flutter gen-l10n
/// has a valid output target without errors on first run.
void _ensureL10nGenDir(String cwd, HookContext context) {
  final genDir = Directory('$cwd/lib/l10n/generated');
  if (!genDir.existsSync()) {
    genDir.createSync(recursive: true);
    // Write a placeholder so git doesn't ignore the empty directory
    File('${genDir.path}/.gitkeep').writeAsStringSync('');
    context.logger.detail('Created lib/l10n/generated/ (output dir for flutter gen-l10n)');
  }
}
