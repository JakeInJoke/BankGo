import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';
import 'package:bank_go/features/transactions/data/models/transaction_model.dart';

abstract class TransactionsRemoteDataSource {
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  });
}

class TransactionsRemoteDataSourceImpl implements TransactionsRemoteDataSource {
  final MockBankApi mockBankApi;

  const TransactionsRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final response = await mockBankApi.getTransactions(
        page: page,
        limit: limit,
        type: type,
        from: from,
        to: to,
      );
      return response.map(TransactionModel.fromJson).toList();
    } catch (_) {
      throw const ServerException(message: 'Error al obtener transacciones');
    }
  }
}
