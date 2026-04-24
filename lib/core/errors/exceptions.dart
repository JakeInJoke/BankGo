class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException({required this.message, this.statusCode});

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException({required super.message, super.statusCode});
}

class NetworkException extends AppException {
  const NetworkException({required super.message, super.statusCode});
}

class CacheException extends AppException {
  const CacheException({required super.message, super.statusCode});
}

class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message = 'Sesión no válida',
    super.statusCode = 401,
  });
}

class TimeoutException extends AppException {
  const TimeoutException({
    super.message = 'Tiempo de espera agotado',
    super.statusCode = 408,
  });
}
