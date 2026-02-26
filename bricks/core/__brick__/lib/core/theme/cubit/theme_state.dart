{{#theme}}
{{#theme_cubit}}
part of 'theme_cubit.dart';

@freezed
sealed class ThemeState with _$ThemeState {
  const factory ThemeState.light() = LightThemeState;
  const factory ThemeState.dark() = DarkThemeState;
  const factory ThemeState.system() = SystemThemeState;

  factory ThemeState.fromJson(Map<String, dynamic> json) =>
      _$ThemeStateFromJson(json);
}
{{/theme_cubit}}
{{/theme}}
