{{#app_bloc}}
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

{{#connectivity}}
import 'package:{{package_name}}/core/platform/connectivity_service.dart';
{{/connectivity}}

part 'app_state.freezed.dart';

/// Authentication state of the session.
enum AuthStatus {
  /// Token presence/validity not yet determined (initial/boot state).
  unknown,

  /// User is logged in with a valid session.
  authenticated,

  /// User is logged out or session has expired.
  unauthenticated,
}

/// Top-level application state managed by [AppBloc].
///
/// Persisted fields (via HydratedBloc): [themeMode], [locale], [isFirstLaunch].
/// Runtime-only fields (not persisted): [authStatus], [connectivityStatus], [forceUpdateRequired].
@freezed
class AppState with _$AppState {
  const AppState._();

  const factory AppState({
    /// Current theme mode (light / dark / system).
    @Default(ThemeMode.system) ThemeMode themeMode,

    /// Current locale - null means use device default.
    Locale? locale,

    /// Whether the user has seen the onboarding screen yet.
    @Default(true) bool isFirstLaunch,

    /// Current authentication state. Not persisted.
    @Default(AuthStatus.unknown) AuthStatus authStatus,

    {{#connectivity}}
    /// Current network connectivity. Not persisted.
    @Default(ConnectivityStatus.online) ConnectivityStatus connectivityStatus,
    {{/connectivity}}

    /// Whether a force-update dialog should be shown. Not persisted.
    @Default(false) bool forceUpdateRequired,
  }) = _AppState;

  /// Initial state - used on first launch.
  factory AppState.initial() => const AppState();

  // ── Convenience getters ──────────────────────────────────────────

  bool get isAuthenticated => authStatus == AuthStatus.authenticated;
  bool get isUnknownAuth => authStatus == AuthStatus.unknown;

  {{#connectivity}}
  bool get isOffline => connectivityStatus == ConnectivityStatus.offline;
  bool get isOnline => connectivityStatus == ConnectivityStatus.online;
  {{/connectivity}}

  // ── JSON persistence (themeMode + locale + isFirstLaunch only) ──

  factory AppState.fromJson(Map<String, dynamic> json) {
    return AppState(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      locale: json['locale'] != null
          ? Locale(json['locale'] as String)
          : null,
      isFirstLaunch: json['isFirstLaunch'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        if (locale != null) 'locale': locale!.languageCode,
        'isFirstLaunch': isFirstLaunch,
        // authStatus, connectivityStatus, forceUpdateRequired are NOT persisted
      };
}
{{/app_bloc}}
