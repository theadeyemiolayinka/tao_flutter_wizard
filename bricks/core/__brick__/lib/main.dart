{{#setup_main}}
import 'package:{{package_name}}/app.dart';
import 'package:{{package_name}}/core/injection.dart';
{{#bloc_observer}}
import 'package:{{package_name}}/core/observer/app_bloc_observer.dart';
{{/bloc_observer}}
import 'package:flutter/material.dart';
{{#app_bloc}}
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
{{/app_bloc}}
import 'package:get_it/get_it.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
{{#bloc_observer}}
  Bloc.observer = const AppBlocObserver();
{{/bloc_observer}}

{{#app_bloc}}
  final storageDir = await getApplicationDocumentsDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(storageDir.path),
  );

{{/app_bloc}}
  registerCoreDependencies(GetIt.instance);
  // mason:core-feature-regis

  runApp(const App());
}
{{/setup_main}}
