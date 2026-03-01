{{#network}}
/// Keys for [RequestOptions.extra] that control per-request behaviour.
///
/// Pass extras when creating a Dio request to opt in/out of specific
/// interceptor behaviour:
///
/// ```dart
/// // Enable idempotency for this specific call
/// dio.post('/orders', options: Options(
///   extra: {RequestExtras.enableIdempotency: true},
/// ));
///
/// // Skip retry for non-idempotent operations
/// dio.post('/payments/capture', options: Options(
///   extra: {RequestExtras.enableRetry: false},
/// ));
///
/// // Skip auth header for public endpoints
/// dio.get('/public/prices', options: Options(
///   extra: {RequestExtras.skipAuth: true},
/// ));
/// ```
abstract final class RequestExtras {
  RequestExtras._();

  // ── Public opt-in / opt-out controls ────────────────────────────

  /// Set to [true] to attach an `Idempotency-Key` header.
  ///
  /// By default idempotency is opt-in — only applied when this key
  /// is explicitly set to [true] in request extras.
  ///
  /// Alternatively, set [IdempotencyInterceptor.applyToAllMutations = true]
  /// to invert the behaviour (apply globally, skip per-request when [false]).
  static const enableIdempotency = 'enable_idempotency';

  /// Set to [true] to skip automatic retry for this request.
  ///
  /// Useful for non-idempotent endpoints where a retry could cause
  /// duplicate side-effects (e.g. payment capture, OTP send).
  static const enableRetry = 'enable_retry';

  /// Set to [true] to skip attaching the `Authorization` header.
  ///
  /// Use for public endpoints that must not send credentials.
  static const skipAuth = 'skip_auth';

  /// Set to [true] to skip the [ErrorInterceptor] normalisation for
  /// this request (raw [DioException] will propagate instead).
  static const skipErrorNormalisation = 'skip_error_normalisation';

  // ── Internal keys (used between interceptors, not for callers) ──

  /// Tracks how many retries have been attempted for a request.
  /// Set and incremented by [RetryInterceptor]. Do not set manually.
  static const retryAttempt = '_retry_attempt';

  /// Marks that a request has already been replayed with a refreshed token.
  /// Set by [TokenInterceptor] to prevent infinite 401 loops.
  static const tokenRefreshed = '_token_refreshed';
}
{{/network}}
