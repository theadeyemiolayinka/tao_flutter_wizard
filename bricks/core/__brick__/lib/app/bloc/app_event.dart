{{#app_bloc}}
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:{{package_name}}/app/bloc/app_state.dart';
{{#connectivity}}
import 'package:{{package_name}}/core/platform/connectivity_service.dart';
{{/connectivity}}

part 'app_event.freezed.dart';

/// All events that drive [AppBloc].
@freezed
sealed class AppEvent with _$AppEvent {
  const factory AppEvent.started() = AppStarted;

  const factory AppEvent.themeModeChanged(ThemeMode mode) = ThemeModeChanged;

  const factory AppEvent.localeChanged(Locale locale) = LocaleChanged;

  const factory AppEvent.authStatusChanged(AuthStatus status) = AuthStatusChanged;

  {{#connectivity}}
  const factory AppEvent.connectivityChanged(
    ConnectivityStatus status,
  ) = ConnectivityChanged;
  {{/connectivity}}

  const factory AppEvent.forceUpdateFlagReceived({
    required bool required,
  }) = ForceUpdateFlagReceived;

  const factory AppEvent.firstLaunchAcknowledged() = FirstLaunchAcknowledged;
}
{{/app_bloc}}
