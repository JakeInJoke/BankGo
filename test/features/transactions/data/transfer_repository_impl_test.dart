import 'package:flutter_test/flutter_test.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/transactions/data/datasources/transfer_remote_datasource.dart';
import 'package:bank_go/features/transactions/data/repositories/transfer_repository_impl.dart';
import 'package:bank_go/features/transactions/domain/entities/transfer_recipient.dart';

class _FakeNetworkInfo implements NetworkInfo {
  final bool connected;

  _FakeNetworkInfo(this.connected);

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeTransferRemoteDataSource implements TransferRemoteDataSource {
  TransferRecipient? recipient;
  String token = '654321';
  Object? validateError;
  Object? tokenError;
  Object? submitError;

  @override
  Future<String> requestSecurityToken() async {
    if (tokenError != null) throw tokenError!;
    return token;
  }

  @override
  Future<void> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  }) async {
    if (submitError != null) throw submitError!;
  }

  @override
  Future<TransferRecipient> validateDestinationAccount(
      String accountNumber) async {
    if (validateError != null) throw validateError!;
    return recipient ??
        TransferRecipient(
          accountNumber: accountNumber,
          holderName: 'Demo User',
          bankName: 'Banco mock',
        );
  }
}

void main() {
  group('TransferRepositoryImpl', () {
    late _FakeTransferRemoteDataSource remoteDataSource;

    setUp(() {
      remoteDataSource = _FakeTransferRemoteDataSource();
    });

    test('valida cuenta destino con conexión activa', () async {
      remoteDataSource.recipient = const TransferRecipient(
        accountNumber: '1234567890123456',
        holderName: 'Mariana Silva',
        bankName: 'Banco BankGo',
      );

      final repository = TransferRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(true),
      );

      final result =
          await repository.validateDestinationAccount('1234567890123456');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Se esperaba un destinatario válido'),
        (recipient) => expect(recipient.holderName, 'Mariana Silva'),
      );
    });

    test('retorna fallo de red al solicitar token sin conexión', () async {
      final repository = TransferRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(false),
      );

      final result = await repository.requestSecurityToken();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Se esperaba un NetworkFailure'),
      );
    });

    test('mapea errores del datasource al enviar transferencia', () async {
      remoteDataSource.submitError =
          const ServerException(message: 'Token inválido', statusCode: 400);

      final repository = TransferRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(true),
      );

      final result = await repository.submitTransfer(
        beneficiary: '1234567890123456',
        sourceAccountId: '1',
        amount: 150,
        token: '000000',
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Token inválido');
        },
        (_) => fail('Se esperaba un ServerFailure'),
      );
    });
  });
}
