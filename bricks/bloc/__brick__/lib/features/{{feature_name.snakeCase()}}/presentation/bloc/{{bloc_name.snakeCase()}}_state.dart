part of '{{bloc_name.snakeCase()}}_bloc.dart';

@freezed
sealed class {{bloc_name.pascalCase()}}State with _${{bloc_name.pascalCase()}}State {
  {{#states}}
  const factory {{bloc_name.pascalCase()}}State.{{#camelCase}}{{.}}{{/camelCase}}() = {{bloc_name.pascalCase()}}{{.}}State;
  {{/states}}
  {{#hydrated}}
  /// Required by Freezed to generate union fromJson / toJson.
  /// Each variant's JSON includes a 'runtimeType' discriminator automatically.
  factory {{bloc_name.pascalCase()}}State.fromJson(Map<String, dynamic> json) =>
      _${{bloc_name.pascalCase()}}StateFromJson(json);
  {{/hydrated}}
}
