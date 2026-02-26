{{#use_cases}}
import 'package:dio/dio.dart';

import 'package:{{package_name}}/core/error/exceptions.dart';
import 'package:{{package_name}}/core/error/failure.dart';

Failure mapExceptionToFailure(Object error) {
  return switch (error) {
    DioException e when e.type == DioExceptionType.connectionError =>
      const Failure.network(message: 'No internet connection.'),
    DioException e =>
      Failure.server(message: e.response?.data?['message']?.toString() ?? e.message ?? 'Server error'),
    ServerException e => Failure.server(message: e.message),
    CacheException e => Failure.cache(message: e.message),
    NetworkException e => Failure.network(message: e.message),
    ValidationException e => Failure.validation(message: e.message),
    _ => Failure.server(message: error.toString()),
  };
}
{{/use_cases}}
