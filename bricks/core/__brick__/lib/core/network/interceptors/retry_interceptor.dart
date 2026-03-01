{{#network}}
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'package:{{package_name}}/core/network/request_extras.dart';

/// Automatically retries failed requests using exponential back-off.
///
/// Retry policy:
/// - Retries up to [maxAttempts] times (default 3)
/// - Applies only to network-level errors and 5xx server errors
/// - Skips retry for 4xx client errors (no point retrying bad requests)
/// - Back-off delays: 1s, 2s, 4s (doubles each attempt, capped at [maxDelayMs])
///
/// **Per-request opt-out:**
/// ```dart
/// // Never retry this call (e.g. payment capture)
/// dio.post('/payments/capture', options: Options(
///   extra: {RequestExtras.enableRetry: false},
/// ));
/// ```
///
/// Usage - add to Dio interceptors BEFORE [LoggingInterceptor]:
/// ```dart
/// dio.interceptors.add(RetryInterceptor(dio: _dio));
/// ```
class RetryInterceptor extends Interceptor {
  RetryInterceptor({
    required Dio dio,
    this.maxAttempts = 3,
    this.initialDelayMs = 1000,
    this.maxDelayMs = 16000,
  }) : _dio = dio;

  final Dio _dio;
  final int maxAttempts;
  final int initialDelayMs;
  final int maxDelayMs;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Bail if caller has explicitly opted out of retry
    if (err.requestOptions.extra[RequestExtras.enableRetry] == false) {
      handler.next(err);
      return;
    }

    final attempt =
        (err.requestOptions.extra[RequestExtras.retryAttempt] as int?) ?? 0;

    final shouldRetry = _isRetryable(err) && attempt < maxAttempts;

    if (!shouldRetry) {
      handler.next(err);
      return;
    }

    final delayMs = min(
      initialDelayMs * pow(2, attempt).toInt(),
      maxDelayMs,
    );

    debugPrint(
      '[Retry] attempt ${attempt + 1}/$maxAttempts after ${delayMs}ms '
      '- ${err.requestOptions.method} ${err.requestOptions.uri}',
    );

    await Future<void>.delayed(Duration(milliseconds: delayMs));

    try {
      final options = err.requestOptions;
      options.extra[RequestExtras.retryAttempt] = attempt + 1;

      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryErr) {
      handler.next(retryErr);
    }
  }

  bool _isRetryable(DioException err) {
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.sendTimeout) {
      return true;
    }
    final statusCode = err.response?.statusCode;
    if (statusCode != null && statusCode >= 500) return true;
    return false;
  }
}
{{/network}}
