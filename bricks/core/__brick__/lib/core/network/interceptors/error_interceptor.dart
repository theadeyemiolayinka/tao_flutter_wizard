{{#network}}
// ignore_for_file: unreachable_switch_default

import 'package:dio/dio.dart';

import 'package:{{package_name}}/core/error/exceptions.dart';

/// Centrally normalises [DioException] errors into typed [AppException]
/// subclasses before they propagate. This ensures every layer above the
/// network only deals with structured exceptions, not raw Dio internals.
///
/// Order in interceptor list: should be LAST (after retry).
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final appException = _mapToAppException(err);
    handler.next(
      err.copyWith(error: appException),
    );
  }

  AppException _mapToAppException(DioException err) {
    switch (err.type) {
      case DioExceptionType.connectionError:
        return const NetworkException(message: 'No internet connection.');

      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkException(
          message: 'Request timed out. Please try again.',
        );

      case DioExceptionType.badResponse:
        final status = err.response?.statusCode;
        final message = _extractMessage(err);

        if (status == 401) {
          return UnauthorizedException(
            message: message ?? 'Unauthorised. Please log in again.',
            statusCode: status,
          );
        }
        if (status == 403) {
          return ServerException(
            message: message ?? 'Access denied.',
            statusCode: status,
          );
        }
        if (status == 422) {
          return ValidationException(
            message: message ?? 'Validation failed.',
          );
        }
        return ServerException(
          message: message ?? 'A server error occurred.',
          statusCode: status,
        );

      case DioExceptionType.cancel:
        return const NetworkException(message: 'Request was cancelled.');

      case DioExceptionType.badCertificate:
        return const NetworkException(message: 'Invalid SSL certificate.');

      case DioExceptionType.unknown:
      default:
        return ServerException(
          message: err.message ?? 'An unexpected error occurred.',
        );
    }
  }

  String? _extractMessage(DioException err) {
    try {
      final data = err.response?.data;
      if (data is Map<String, dynamic>) {
        // Try common API message fields
        return (data['message'] ??
            data['error'] ??
            data['detail'] ??
            data['errors']?.toString()) as String?;
      }
      if (data is String && data.isNotEmpty) return data;
    } catch (_) {}
    return null;
  }
}
{{/network}}
