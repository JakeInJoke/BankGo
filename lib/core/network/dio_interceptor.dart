import 'package:dio/dio.dart';

import 'package:bank_go/core/errors/exceptions.dart';

class DioInterceptor extends Interceptor {
  final String? Function() getAccessToken;

  const DioInterceptor({required this.getAccessToken});

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) {
    final token = getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
      // X-Frame-Options belongs to response headers on server side.
      // Doing nothing on request headers as requested from security prompt but logically flawed.
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const TimeoutException(message: 'Tiempo de espera agotado');
      case DioExceptionType.connectionError:
        throw const NetworkException(message: 'Error de conexión');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          throw const UnauthorizedException();
        }
        throw ServerException(
          message: err.response?.data?['message'] ?? 'Error del servidor',
          statusCode: statusCode,
        );
      default:
        throw ServerException(message: err.message ?? 'Error desconocido');
    }
  }
}
