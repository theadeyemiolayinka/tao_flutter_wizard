{{#setup_main}}
{{#app_bloc}}
import 'package:{{package_name}}/app/bloc/app_bloc.dart';
import 'package:{{package_name}}/app/bloc/app_event.dart';
import 'package:{{package_name}}/app/bloc/app_state.dart';
{{/app_bloc}}
{{#app_router}}
import 'package:{{package_name}}/core/router/app_router.dart';
{{/app_router}}
{{#theme}}
import 'package:{{package_name}}/core/theme/app_theme.dart';
{{/theme}}
import 'package:flutter/material.dart';
{{#app_bloc}}
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
{{/app_bloc}}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
{{#app_bloc}}
    return BlocProvider(
      create: (context) => GetIt.I<AppBloc>()..add(const AppEvent.started()),
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return MaterialApp{{#app_router}}.router{{/app_router}}(
            title: '{{package_name}}',
            debugShowCheckedModeBanner: false,
{{#theme}}
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: state.themeMode,
{{/theme}}
{{#app_router}}
            routerConfig: appRouter,
{{/app_router}}
          );
        },
      ),
    );
{{/app_bloc}}
{{^app_bloc}}
    return MaterialApp{{#app_router}}.router{{/app_router}}(
      title: '{{package_name}}',
      debugShowCheckedModeBanner: false,
{{#theme}}
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
{{/theme}}
{{#app_router}}
      routerConfig: appRouter,
{{/app_router}}
    );
{{/app_bloc}}
  }
}
{{/setup_main}}
