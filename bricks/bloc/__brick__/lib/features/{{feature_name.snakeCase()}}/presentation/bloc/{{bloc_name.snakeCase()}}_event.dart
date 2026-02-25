part of '{{bloc_name.snakeCase()}}_bloc.dart';

@freezed
sealed class {{bloc_name.pascalCase()}}Event with _${{bloc_name.pascalCase()}}Event {
  {{#events}}
  const factory {{bloc_name.pascalCase()}}Event.{{#camelCase}}{{.}}{{/camelCase}}() = {{bloc_name.pascalCase()}}{{.}}Event;
  {{/events}}
}
