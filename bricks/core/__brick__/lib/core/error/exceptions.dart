{{#use_cases}}
class ServerException implements Exception {
  const ServerException({required this.message, this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException: $message (statusCode: $statusCode)';
}

class CacheException implements Exception {
  const CacheException({required this.message});

  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({required this.message});

  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class ValidationException implements Exception {
  const ValidationException({required this.message});

  final String message;

  @override
  String toString() => 'ValidationException: $message';
}
{{/use_cases}}
