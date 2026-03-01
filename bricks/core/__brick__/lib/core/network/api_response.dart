{{#network}}
import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';

/// A generic API response envelope.
///
/// Wrap server responses in [ApiResponse] in your datasource layer to
/// provide a consistent contract for repositories.
///
/// ```dart
/// final response = await dio.get('/users');
/// return ApiResponse.fromMap(
///   response.data as Map<String, dynamic>,
///   fromJson: User.fromJson,
/// );
/// ```
@freezed
sealed class ApiResponse<T> with _$ApiResponse<T> {
  /// A successful single-item response.
  const factory ApiResponse.success({
    required T data,
    String? message,
  }) = ApiSuccess<T>;

  /// A paginated list response.
  const factory ApiResponse.paginated({
    required List<T> items,
    required int total,
    required int page,
    required int perPage,
  }) = ApiPaginated<T>;

  /// A failed response with a human-readable message.
  const factory ApiResponse.failure({
    required String message,
    int? statusCode,
  }) = ApiFailure<T>;

  const ApiResponse._();

  /// Whether this response represents a successful result.
  bool get isSuccess => switch (this) {
        ApiSuccess() => true,
        ApiPaginated() => true,
        ApiFailure() => false,
      };

  /// Convenience: unwrap success data or null.
  T? get dataOrNull => switch (this) {
        ApiSuccess(:final data) => data,
        _ => null,
      };

  /// Convenience: unwrap paginated items or empty list.
  List<T> get itemsOrEmpty => switch (this) {
        ApiPaginated(:final items) => items,
        _ => [],
      };

  /// Build from a raw JSON map using a [fromJson] converter.
  ///
  /// Assumes a common envelope shape:
  /// ```json
  /// { "data": {...}, "message": "..." }
  /// ```
  static ApiResponse<T> fromMap<T>(
    Map<String, dynamic> json, {
    required T Function(Map<String, dynamic>) fromJson,
  }) {
    try {
      final rawData = json['data'];
      final message = json['message'] as String?;

      if (rawData is List) {
        return ApiResponse.paginated(
          items: rawData
              .cast<Map<String, dynamic>>()
              .map(fromJson)
              .toList(),
          total: (json['total'] as num?)?.toInt() ?? rawData.length,
          page: (json['page'] as num?)?.toInt() ?? 1,
          perPage: (json['per_page'] as num?)?.toInt() ?? rawData.length,
        );
      }

      if (rawData is Map<String, dynamic>) {
        return ApiResponse.success(
          data: fromJson(rawData),
          message: message,
        );
      }

      return ApiResponse.failure(
        message: message ?? 'Unexpected response shape.',
      );
    } catch (e) {
      return ApiResponse.failure(message: e.toString());
    }
  }
}
{{/network}}
