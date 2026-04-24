import 'package:flutter_test/flutter_test.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

void main() {
  group('MockBankApi', () {
    const mockApi = MockBankApi();

    setUp(() {
      MockBankApi.resetState();
    });

    test('retorna usuario demo con credenciales válidas', () async {
      final result = await mockApi.login(
        dni: MockBankApi.demoDni,
        password: MockBankApi.demoPassword,
      );

      expect(result['email'], isNotNull);
      expect(result['token'], isNotNull);
    });

    test('lanza UnauthorizedException con credenciales inválidas', () async {
      expect(
        () => mockApi.login(dni: '00000000', password: 'incorrecta'),
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

    test('procesa pago de servicio con tarjeta encendida', () async {
      final result = await mockApi.processServicePayment(
        serviceName: 'Internet',
        amount: 100,
        sourceAccountId: '1',
      );

      expect(result['type'], 'service');
      expect(result['amount'], -100.0);
    });

    test('rechaza compra cuando la tarjeta está apagada', () async {
      final token = await mockApi.requestSecurityToken(accountId: '1');
      await mockApi.toggleCardFreeze(
        accountId: '1',
        freeze: true,
        token: token,
      );

      expect(
        () => mockApi.processServicePayment(
          serviceName: 'Internet',
          amount: 100,
          sourceAccountId: '1',
        ),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            contains('tarjeta apagada'),
          ),
        ),
      );
    });

    test('procesa pago con saldo suficiente', () async {
      final result = await mockApi.processServicePayment(
        serviceName: 'Agua',
        amount: 50,
        sourceAccountId: '2',
      );

      expect(result['title'], contains('Pago de Agua'));
    });

    test('rechaza compra con saldo insuficiente', () async {
      expect(
        () => mockApi.processServicePayment(
          serviceName: 'Luz',
          amount: 50000,
          sourceAccountId: '2',
        ),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            contains('Saldo insuficiente'),
          ),
        ),
      );
    });

    test('permite transferencia desde cuenta verificada de ahorro', () async {
      final token = await mockApi.requestSecurityToken();

      final result = await mockApi.submitTransfer(
        beneficiary: '7711223344556677',
        sourceAccountId: '1',
        amount: 150,
        token: token,
      );

      expect(result['type'], 'transfer');
      expect(result['title'], contains('María García'));
    });

    test('rechaza transferencia desde tarjeta de crédito', () async {
      final token = await mockApi.requestSecurityToken();

      expect(
        () => mockApi.submitTransfer(
          beneficiary: '7711223344556677',
          sourceAccountId: '3',
          amount: 150,
          token: token,
        ),
        throwsA(
          isA<ServerException>().having(
            (error) => error.message,
            'message',
            contains('tarjeta de crédito'),
          ),
        ),
      );
    });
  });
}
