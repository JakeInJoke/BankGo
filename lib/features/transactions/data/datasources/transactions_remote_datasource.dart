import 'package:dio/dio.dart';

import 'package:bank_go/core/errors/exceptions.dart';
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
  final Dio dio;

  const TransactionsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<TransactionModel>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      // TODO: Replace with real endpoint once API is ready.
      await Future.delayed(const Duration(milliseconds: 700));
      final all = TransactionModel.placeholders();
      final filtered =
          type != null ? all.where((t) => t.type == type).toList() : all;
      return filtered.take(limit).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error al obtener transacciones',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
