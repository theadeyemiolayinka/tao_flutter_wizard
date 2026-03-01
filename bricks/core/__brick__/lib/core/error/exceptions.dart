{{#use_cases}}
abstract class AppException implements Exception {

}

class ServerException implements AppException {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class UnauthorizedException implements AppException {
  const UnauthorizedException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'UnauthorizedException: $message (statusCode: $statusCode)';
}

class CacheException implements AppException {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements AppException {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements AppException {
  const ValidationException({required this.message});

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
{{/use_cases}}
