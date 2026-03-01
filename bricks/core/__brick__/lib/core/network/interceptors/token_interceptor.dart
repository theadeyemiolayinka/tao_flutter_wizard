{{#network}}
import 'dart:async';

import 'package:dio/dio.dart';

import 'package:{{package_name}}/core/network/request_extras.dart';

import 'package:{{package_name}}/core/error/exceptions.dart';

/// Handles 401 token refresh with a lock to prevent thundering-herd.
///
/// When a 401 is received:
/// 1. Acquires a lock (all concurrent requests queue behind it)
/// 2. Attempts to refresh the access token once
/// 3. Replays all queued requests with the new token
/// 4. If refresh fails → clears tokens + propagates [ServerException]
///
/// Configure [onRefreshToken] and [onTokenRefreshed] / [onRefreshFailed]
/// to integrate with your storage solution.
class TokenInterceptor extends Interceptor {
  TokenInterceptor({
    required Dio dio,
    required Future<String?> Function() onGetAccessToken,
    required Future<String?> Function() onRefreshToken,
    required Future<void> Function(String accessToken) onTokenRefreshed,
    required Future<void> Function() onRefreshFailed,
  })  : _dio = dio,
        _onGetAccessToken = onGetAccessToken,
        _onRefreshToken = onRefreshToken,
        _onTokenRefreshed = onTokenRefreshed,
        _onRefreshFailed = onRefreshFailed;

  final Dio _dio;
  final Future<String?> Function() _onGetAccessToken;
  final Future<String?> Function() _onRefreshToken;
  final Future<void> Function(String accessToken) _onTokenRefreshed;
  final Future<void> Function() _onRefreshFailed;

  bool _isRefreshing = false;
  final _queue = <Completer<String?>>[];

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Caller can opt out of auth header for public endpoints
    final skipAuth = options.extra[RequestExtras.skipAuth] == true;
    if (!skipAuth) {
      final token = await _onGetAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    // Already replayed with refreshed token - don't loop
    if (err.requestOptions.extra[RequestExtras.tokenRefreshed] == true) {
      handler.next(err);
      return;
    }

    if (_isRefreshing) {
      // Queue this request - wait for the refresh to complete
      final completer = Completer<String?>();
      _queue.add(completer);
      final newToken = await completer.future;
      if (newToken == null) {
        handler.next(err);
        return;
      }
      handler.resolve(await _retryWithToken(err.requestOptions, newToken));
      return;
    }

    _isRefreshing = true;

    try {
      final newToken = await _onRefreshToken();

      if (newToken == null) {
        await _onRefreshFailed();
        _resolveQueue(null);
        handler.next(
          err.copyWith(
            error: const ServerException(
              message: 'Token refresh failed. Please log in again.',
              statusCode: 401,
            ),
          ),
        );
        return;
      }

      await _onTokenRefreshed(newToken);
      _resolveQueue(newToken);

      err.requestOptions.extra[RequestExtras.tokenRefreshed] = true;
      handler.resolve(await _retryWithToken(err.requestOptions, newToken));
    } catch (_) {
      await _onRefreshFailed();
      _resolveQueue(null);
      handler.next(err);
    } finally {
      _isRefreshing = false;
    }
  }

  void _resolveQueue(String? token) {
    for (final completer in _queue) {
      completer.complete(token);
    }
    _queue.clear();
  }

  Future<Response<dynamic>> _retryWithToken(
    RequestOptions options,
    String token,
  ) {
    options.headers['Authorization'] = 'Bearer $token';
    return _dio.fetch<dynamic>(options);
  }
}
{{/network}}
