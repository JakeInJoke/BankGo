import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/data/datasources/accounts_remote_datasource.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/transactions/data/models/transaction_model.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

class _FakeNetworkInfo implements NetworkInfo {
  final bool connected;

  _FakeNetworkInfo(this.connected);

  @override
  Future<bool> get isConnected async => connected;
}

class _FakeAccountsRemoteDataSource implements AccountsRemoteDataSource {
  List<AccountModel> accounts = const [];
  List<TransactionModel> transactions = const [];
  Object? accountsError;
  Object? transactionsError;

  @override
  Future<List<AccountModel>> getAccounts() async {
    if (accountsError != null) throw accountsError!;
    return accounts;
  }

  @override
  Future<List<TransactionModel>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  }) async {
    if (transactionsError != null) throw transactionsError!;
    return transactions.take(limit).toList();
  }
}

void main() {
  group('AccountsRepositoryImpl', () {
    late _FakeAccountsRemoteDataSource remoteDataSource;
    late SharedPreferences sharedPreferences;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();
      remoteDataSource = _FakeAccountsRemoteDataSource();
    });

    test('retorna cuentas cuando hay conexión', () async {
      remoteDataSource.accounts = const [
        AccountModel(
          id: '1',
          accountNumber: '1234567890123456',
          alias: 'Cuenta Sueldo',
          type: AccountType.checking,
          balance: 2500,
          currency: 'PEN',
        ),
      ];

      final repository = AccountsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(true),
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getAccounts();

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Se esperaba una lista de cuentas'),
        (accounts) => expect(accounts.single.alias, 'Cuenta Sueldo'),
      );
    });

    test('retorna fallo de red si no hay conexión', () async {
      final repository = AccountsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(false),
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getAccounts();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure, isA<NetworkFailure>()),
        (_) => fail('Se esperaba un NetworkFailure'),
      );
    });

    test('mapea movimientos desde el datasource', () async {
      remoteDataSource.transactions = [
        TransactionModel(
          id: 'tx-1',
          title: 'Transferencia recibida',
          description: 'Ingreso',
          amount: 120,
          type: TransactionType.income,
          status: TransactionStatus.completed,
          date: DateTime(2024, 1, 10),
        ),
      ];

      final repository = AccountsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(true),
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getTransactionsForAccount(accountId: '1');

      expect(result.isRight(), isTrue);
      result.fold(
        (_) => fail('Se esperaba una lista de movimientos'),
        (transactions) =>
            expect(transactions.single.title, 'Transferencia recibida'),
      );
    });

    test('mapea ServerException a ServerFailure', () async {
      remoteDataSource.accountsError =
          const ServerException(message: 'Error del mock', statusCode: 500);

      final repository = AccountsRepositoryImpl(
        remoteDataSource: remoteDataSource,
        networkInfo: _FakeNetworkInfo(true),
        sharedPreferences: sharedPreferences,
      );

      final result = await repository.getAccounts();

      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, 'Error del mock');
        },
        (_) => fail('Se esperaba un ServerFailure'),
      );
    });
  });
}
