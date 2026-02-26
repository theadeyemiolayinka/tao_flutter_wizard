part of '{{bloc_name.snakeCase()}}_bloc.dart';

@freezed
sealed class {{bloc_name.pascalCase()}}State with _${{bloc_name.pascalCase()}}State {
  {{#states}}
  {{#hydrated}}@JsonSerializable(){{/hydrated}}
  const factory {{bloc_name.pascalCase()}}State.{{#camelCase}}{{.}}{{/camelCase}}() = {{bloc_name.pascalCase()}}{{.}}State;
  {{/states}}
}
