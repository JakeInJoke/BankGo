import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';
import 'package:bank_go/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:bank_go/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:bank_go/features/transactions/data/models/transaction_model.dart';

class TransactionsRepositoryImpl implements TransactionsRepository {
  final TransactionsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  static const _kTransactionsCachePrefix = 'CACHE_READ_TRANSACTIONS_V1_';

  const TransactionsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    final cacheKey =
        '$_kTransactionsCachePrefix${page}_${limit}_${type?.name ?? 'all'}_${from?.toIso8601String() ?? 'na'}_${to?.toIso8601String() ?? 'na'}';

    if (!await networkInfo.isConnected) {
      final raw = sharedPreferences.getString(cacheKey);
      if (raw != null) {
        final cached = (jsonDecode(raw) as List<dynamic>)
            .map((e) =>
                TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList();
        return Right(cached);
      }
      // Fallback demo data no sensible if cache is empty.
      return Right(TransactionModel.placeholders());
    }
    try {
      final transactions = await remoteDataSource.getTransactions(
        page: page,
        limit: limit,
        type: type,
        from: from,
        to: to,
      );
      final serializable = transactions
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'description': t.description,
                'amount': t.amount,
                'type': t.type.name,
                'status': t.status.name,
                'date': t.date.toIso8601String(),
                'category': t.category,
                'reference': t.reference,
              })
          .toList();
      await sharedPreferences.setString(cacheKey, jsonEncode(serializable));
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
