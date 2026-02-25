import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/{{entity_name.snakeCase()}}.dart';

part '{{entity_name.snakeCase()}}_model.freezed.dart';
part '{{entity_name.snakeCase()}}_model.g.dart';

@freezed
class {{entity_name.pascalCase()}}Model with _${{entity_name.pascalCase()}}Model {
  const factory {{entity_name.pascalCase()}}Model({
    {{#fields}}
    {{#isnullable}}
    @JsonKey(name: '{{name}}') {{type}}? {{name}},
    {{/isnullable}}
    {{^isnullable}}
    @JsonKey(name: '{{name}}') required {{type}} {{name}},
    {{/isnullable}}
    {{/fields}}
  }) = _{{entity_name.pascalCase()}}Model;

  factory {{entity_name.pascalCase()}}Model.fromJson(Map<String, dynamic> json) =>
      _${{entity_name.pascalCase()}}ModelFromJson(json);

  const {{entity_name.pascalCase()}}Model._();

  factory {{entity_name.pascalCase()}}Model.fromEntity({{entity_name.pascalCase()}} entity) =>
      {{entity_name.pascalCase()}}Model(
        {{#fields}}
        {{name}}: entity.{{name}},
        {{/fields}}
      );

  {{entity_name.pascalCase()}} toEntity() => {{entity_name.pascalCase()}}(
        {{#fields}}
        {{name}}: {{name}}{{^isnullable}}!{{/isnullable}},
        {{/fields}}
      );
}
