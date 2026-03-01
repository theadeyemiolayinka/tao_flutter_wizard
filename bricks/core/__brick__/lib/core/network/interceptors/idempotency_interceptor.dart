{{#network}}
import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart';

import 'package:{{package_name}}/core/network/request_extras.dart';

/// Attaches a unique [Idempotency-Key] header to HTTP requests.
///
/// Behaviour depends on [applyToAllMutations]:
///
/// **Opt-in mode** (default, `applyToAllMutations = false`):
///   Only applied when the request explicitly sets:
///   ```dart
///   options: Options(extra: {RequestExtras.enableIdempotency: true})
///   ```
///
/// **Opt-out mode** (`applyToAllMutations = true`):
///   Applied to ALL POST/PUT/PATCH/DELETE requests unless the request sets:
///   ```dart
///   options: Options(extra: {RequestExtras.enableIdempotency: false})
///   ```
///
/// Server-side support is required - the server must store and honour
/// idempotency keys (typically for 24 h). See:
/// https://stripe.com/docs/idempotency
class IdempotencyInterceptor extends Interceptor {
  IdempotencyInterceptor({this.applyToAllMutations = false});

  /// When [true], applies to all mutating requests (opt-out mode).
  /// When [false], only applies when explicitly requested (opt-in mode).
  final bool applyToAllMutations;

  static const _headerKey = 'Idempotency-Key';
  static const _mutateMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};
  static const _uuid = Uuid();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_shouldApply(options)) {
      options.headers[_headerKey] = _uuid.v4();
    }
    handler.next(options);
  }

  bool _shouldApply(RequestOptions options) {
    if (!_mutateMethods.contains(options.method.toUpperCase())) return false;

    final extra = options.extra[RequestExtras.enableIdempotency];

    if (applyToAllMutations) {
      // Opt-out: apply unless explicitly disabled
      return extra != false;
    } else {
      // Opt-in: apply only when explicitly enabled
      return extra == true;
    }
  }
}
{{/network}}
