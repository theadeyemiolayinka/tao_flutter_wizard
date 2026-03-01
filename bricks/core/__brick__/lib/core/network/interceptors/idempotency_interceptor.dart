{{#network}}
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

/// Attaches a unique [Idempotency-Key] header to all mutating HTTP requests
/// (POST, PUT, PATCH, DELETE). This allows servers to safely deduplicate
/// retried or duplicate requests.
///
/// The key is a UUID v4 generated fresh per request.
///
/// Server-side support is required - the server must store and honour
/// idempotency keys (typically for 24 h). See:
/// https://stripe.com/docs/idempotency
class IdempotencyInterceptor extends Interceptor {
  static const _headerKey = 'Idempotency-Key';
  static const _mutateMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_mutateMethods.contains(options.method.toUpperCase())) {
      options.headers[_headerKey] = _uuid.v4();
    }
    handler.next(options);
  }
}
{{/network}}
