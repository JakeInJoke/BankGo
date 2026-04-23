import 'package:dio/dio.dart';

import '../errors/exceptions.dart';

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
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw TimeoutException(message: 'Tiempo de espera agotado');
      case DioExceptionType.connectionError:
        throw NetworkException(message: 'Error de conexión');
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if (statusCode == 401) {
          throw UnauthorizedException();
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
