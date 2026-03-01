{{#network}}
import 'package:dio/dio.dart';

import 'package:{{package_name}}/core/network/constants/api_constants.dart';
import 'package:{{package_name}}/core/network/interceptors/error_interceptor.dart';
import 'package:{{package_name}}/core/network/interceptors/idempotency_interceptor.dart';
import 'package:{{package_name}}/core/network/interceptors/logging_interceptor.dart';
import 'package:{{package_name}}/core/network/interceptors/retry_interceptor.dart';
import 'package:{{package_name}}/core/network/interceptors/token_interceptor.dart';

/// Pre-configured [Dio] HTTP client for the app.
///
/// Interceptor order (request → response):
/// 1. [TokenInterceptor]      - attach + refresh bearer tokens
/// 2. [IdempotencyInterceptor]- add Idempotency-Key to mutating requests
/// 3. [LoggingInterceptor]    - log request / response (debug only)
/// 4. [RetryInterceptor]      - exponential back-off on network/5xx errors
/// 5. [ErrorInterceptor]      - normalise errors into typed [AppException]s
///
/// Usage - resolve via GetIt:
/// ```dart
/// final dio = getIt<DioClient>().dio;
/// ```
class DioClient {
  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeoutMs),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeoutMs),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      TokenInterceptor(
        dio: _dio,
        // TODO: Wire these callbacks to your token storage (e.g. FlutterSecureStorage)
        onGetAccessToken: () async => null,
        onRefreshToken: () async => null,
        onTokenRefreshed: (_) async {},
        onRefreshFailed: () async {},
      ),
      {{#idempotency}}
      IdempotencyInterceptor(),
      {{/idempotency}}
      LoggingInterceptor(),
      {{#retry}}
      RetryInterceptor(dio: _dio),
      {{/retry}}
      ErrorInterceptor(),
    ]);
  }

  late final Dio _dio;

  Dio get dio => _dio;
}
{{/network}}
