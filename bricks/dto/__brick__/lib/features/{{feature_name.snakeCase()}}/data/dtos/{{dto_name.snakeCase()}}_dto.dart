import 'package:freezed_annotation/freezed_annotation.dart';

import 'package:{{package_name}}/core/dto/core_dto.dart';
import 'package:{{package_name}}/features/{{feature_name.snakeCase()}}/domain/entities/{{entity_name.snakeCase()}}.dart';

part '{{dto_name.snakeCase()}}_dto.freezed.dart';
part '{{dto_name.snakeCase()}}_dto.g.dart';

/// Data Transfer Object for [{{entity_name.pascalCase()}}].
///
/// Lives in the **data layer** - convert to/from domain entity at
/// repository boundaries using [toEntity] and [fromEntity].
///
/// Run build_runner after generating:
///   dart run build_runner build --delete-conflicting-outputs
@freezed
class {{dto_name.pascalCase()}}Dto
    with _${{dto_name.pascalCase()}}Dto
    implements CoreDto<{{dto_name.pascalCase()}}Dto> {
  const {{dto_name.pascalCase()}}Dto._();

  const factory {{dto_name.pascalCase()}}Dto({
    {{#has_fields}}
    {{#fields}}
    {{#isnullable}}
    {{type}}? {{name.camelCase()}},
    {{/isnullable}}
    {{^isnullable}}
    required {{type}} {{name.camelCase()}},
    {{/isnullable}}
    {{/fields}}
    {{/has_fields}}
    {{^has_fields}}
    // TODO: add fields here
    {{/has_fields}}
  }) = _{{dto_name.pascalCase()}}Dto;

  factory {{dto_name.pascalCase()}}Dto.fromJson(Map<String, dynamic> json) =>
      _${{dto_name.pascalCase()}}DtoFromJson(json);

  /// Map from domain entity → DTO (for outgoing requests).
  factory {{dto_name.pascalCase()}}Dto.fromEntity({{entity_name.pascalCase()}} entity) {
    // TODO: map entity fields to DTO fields
    return {{dto_name.pascalCase()}}Dto(
      {{#has_fields}}
      {{#fields}}
      {{name.camelCase()}}: entity.{{name.camelCase()}},
      {{/fields}}
      {{/has_fields}}
    );
  }

  /// Map from DTO → domain entity (for incoming responses).
  {{entity_name.pascalCase()}} toEntity() {
    // TODO: map DTO fields to entity fields
    return {{entity_name.pascalCase()}}(
      {{#has_fields}}
      {{#fields}}
      {{name.camelCase()}}: {{name.camelCase()}},
      {{/fields}}
      {{/has_fields}}
    );
  }

  @override
  Map<String, dynamic> toJson() => _${{dto_name.pascalCase()}}DtoToJson(this);
}
