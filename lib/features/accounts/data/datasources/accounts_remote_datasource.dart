import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/transactions/data/models/transaction_model.dart';

abstract class AccountsRemoteDataSource {
  Future<List<AccountModel>> getAccounts();

  Future<List<TransactionModel>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  });
}

class AccountsRemoteDataSourceImpl implements AccountsRemoteDataSource {
  final MockBankApi mockBankApi;

  const AccountsRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<List<AccountModel>> getAccounts() async {
    try {
      final response = await mockBankApi.getAccounts();
      return response.map(AccountModel.fromJson).toList();
    } catch (_) {
      throw const ServerException(message: 'Error al obtener cuentas.');
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  }) async {
    try {
      final response = await mockBankApi.getTransactionsForAccount(
        accountId: accountId,
        limit: limit,
      );
      return response.map(TransactionModel.fromJson).toList();
    } catch (_) {
      throw const ServerException(
        message: 'Error al obtener movimientos de la cuenta.',
      );
    }
  }
}
