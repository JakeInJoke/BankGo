import 'package:flutter_test/flutter_test.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

void main() {
  group('MockBankApi', () {
    const mockApi = MockBankApi();

    test('retorna usuario demo con credenciales válidas', () async {
      final result = await mockApi.login(
        email: MockBankApi.demoEmail,
        password: MockBankApi.demoPassword,
      );

      expect(result['email'], MockBankApi.demoEmail);
      expect(result['token'], isNotNull);
    });

    test('lanza UnauthorizedException con credenciales inválidas', () async {
      expect(
        () => mockApi.login(email: 'otro@bankgo.com', password: 'incorrecta'),
        throwsA(isA<UnauthorizedException>()),
      );
    });

    test('pagina transacciones y filtra por tipo', () async {
      final result = await mockApi.getTransactions(
        page: 1,
        limit: 2,
        type: TransactionType.expense,
      );

      expect(result, hasLength(2));
      expect(result.every((item) => item['type'] == 'expense'), isTrue);
    });
  });
}
