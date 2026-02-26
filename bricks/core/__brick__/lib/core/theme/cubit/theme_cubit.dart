{{#theme}}
{{#theme_cubit}}
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';

part 'theme_state.dart';
part 'theme_cubit.freezed.dart';
part 'theme_cubit.g.dart';

class ThemeCubit extends HydratedCubit<ThemeState> {
  ThemeCubit() : super(const ThemeState.system());

  void setLight() => emit(const ThemeState.light());
  void setDark() => emit(const ThemeState.dark());
  void setSystem() => emit(const ThemeState.system());

  void cycle() => state.map(
        light: (_) => setDark(),
        dark: (_) => setSystem(),
        system: (_) => setLight(),
      );

  ThemeMode get themeMode => state.map(
        light: (_) => ThemeMode.light,
        dark: (_) => ThemeMode.dark,
        system: (_) => ThemeMode.system,
      );

  @override
  ThemeState? fromJson(Map<String, dynamic> json) {
    try {
      return ThemeState.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  @override
  Map<String, dynamic>? toJson(ThemeState state) {
    try {
      return state.toJson();
    } catch (_) {
      return null;
    }
  }
}
{{/theme_cubit}}
{{/theme}}
