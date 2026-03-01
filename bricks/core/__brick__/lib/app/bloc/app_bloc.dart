{{#app_bloc}}
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:{{package_name}}/app/bloc/app_event.dart';
import 'package:{{package_name}}/app/bloc/app_state.dart';
{{#connectivity}}
import 'package:{{package_name}}/core/platform/connectivity_service.dart';
{{/connectivity}}

/// Application-level orchestration bloc.
///
/// Manages cross-cutting concerns that must be available globally:
/// - Theme mode (persisted via HydratedBloc)
/// - Locale (persisted)
/// - First-launch flag (persisted)
/// - Authentication status (runtime - driven by auth feature changes)
/// - Connectivity status (runtime - driven by [ConnectivityService])
/// - Force-update flag (runtime - driven by remote config)
///
/// Usage in main.dart:
/// ```dart
/// BlocProvider(
///   create: (_) => getIt<AppBloc>()..add(const AppEvent.started()),
///   child: BlocBuilder<AppBloc, AppState>(
///     builder: (context, state) => MaterialApp.router(
///       themeMode: state.themeMode,
///       theme: AppTheme.light,
///       darkTheme: AppTheme.dark,
///       ...
///     ),
///   ),
/// )
/// ```
class AppBloc extends HydratedBloc<AppEvent, AppState> {
  AppBloc({
    {{#connectivity}}
    required ConnectivityService connectivityService,
    {{/connectivity}}
  }) : super(AppState.initial()) {
    on<AppStarted>(_onStarted);
    on<ThemeModeChanged>(_onThemeModeChanged);
    on<LocaleChanged>(_onLocaleChanged);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    {{#connectivity}}
    on<ConnectivityChanged>(_onConnectivityChanged);
    {{/connectivity}}
    on<ForceUpdateFlagReceived>(_onForceUpdateFlagReceived);
    on<FirstLaunchAcknowledged>(_onFirstLaunchAcknowledged);

    {{#connectivity}}
    // Subscribe to connectivity changes
    _connectivitySubscription = connectivityService.onStatusChange.listen(
      (status) => add(AppEvent.connectivityChanged(status)),
    );
    {{/connectivity}}
  }

  {{#connectivity}}
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  {{/connectivity}}

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    // State is already restored by HydratedBloc fromJson.
    // Emit to trigger downstream listeners (e.g. for auth check).
    emit(state);
  }

  void _onThemeModeChanged(ThemeModeChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(themeMode: event.mode));
  }

  void _onLocaleChanged(LocaleChanged event, Emitter<AppState> emit) {
    emit(state.copyWith(locale: event.locale));
  }

  void _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(authStatus: event.status));
  }

  {{#connectivity}}
  void _onConnectivityChanged(
    ConnectivityChanged event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(connectivityStatus: event.status));
  }
  {{/connectivity}}

  void _onForceUpdateFlagReceived(
    ForceUpdateFlagReceived event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(forceUpdateRequired: event.required));
  }

  void _onFirstLaunchAcknowledged(
    FirstLaunchAcknowledged event,
    Emitter<AppState> emit,
  ) {
    emit(state.copyWith(isFirstLaunch: false));
  }

  @override
  AppState? fromJson(Map<String, dynamic> json) {
    try {
      return AppState.fromJson(json);
    } catch (_) {
      return AppState.initial();
    }
  }

  @override
  Map<String, dynamic>? toJson(AppState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> close() {
    {{#connectivity}}
    _connectivitySubscription?.cancel();
    {{/connectivity}}
    return super.close();
  }
}
{{/app_bloc}}
