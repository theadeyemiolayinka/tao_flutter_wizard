import 'package:freezed_annotation/freezed_annotation.dart';

part '{{entity_name.snakeCase()}}.freezed.dart';

@freezed
class {{entity_name.pascalCase()}} with _${{entity_name.pascalCase()}} {
  const factory {{entity_name.pascalCase()}}({
    {{#fields}}
    {{#isnullable}}
    {{type}}? {{name}},
    {{/isnullable}}
    {{^isnullable}}
    required {{type}} {{name}},
    {{/isnullable}}
    {{/fields}}
  }) = _{{entity_name.pascalCase()}};
}
