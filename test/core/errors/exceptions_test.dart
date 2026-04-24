import 'package:flutter_test/flutter_test.dart';

import 'package:bank_go/core/errors/exceptions.dart';

void main() {
  group('App exceptions', () {
    test('UnauthorizedException captura status code 401', () {
      const exception = UnauthorizedException();

      expect(exception.statusCode, 401);
      expect(exception.message, 'Sesión no válida');
    });

    test('TimeoutException captura status code 408', () {
      const exception = TimeoutException();

      expect(exception.statusCode, 408);
      expect(exception.message, 'Tiempo de espera agotado');
    });

    test('ServerException conserva mensaje pero no muestra status en toString', () {
      const exception = ServerException(
        message: 'Operación inválida',
        statusCode: 422,
      );

      expect(exception.statusCode, 422);
      expect(exception.toString(), 'Operación inválida');
      expect(exception.toString(), isNot(contains('status')));
    });
  });
}
