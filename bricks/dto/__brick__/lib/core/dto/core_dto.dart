import 'package:freezed_annotation/freezed_annotation.dart';

part 'core_dto.freezed.dart';
part 'core_dto.g.dart';

/// Base contract that all feature DTOs must satisfy.
///
/// DTOs (Data Transfer Objects) live in the **data layer** and are
/// responsible for serialising/deserialising network/local-storage
/// payloads. They must NOT bleed into the domain layer - convert them
/// via [toEntity] / [fromEntity] at repository boundaries.
///
/// Usage (in a concrete DTO):
/// ```dart
/// @freezed
/// class UserDto with _$UserDto implements CoreDto<UserDto> {
///   const UserDto._();
///   const factory UserDto({
///     required String id,
///     required String name,
///   }) = _UserDto;
///
///   factory UserDto.fromJson(Map<String, dynamic> json) =>
///       _$UserDtoFromJson(json);
///
///   @override
///   Map<String, dynamic> toJson() => _$UserDtoToJson(this);
/// }
/// ```
abstract interface class CoreDto<Self> {
  /// Serialise to JSON-compatible map.
  Map<String, dynamic> toJson();
}
