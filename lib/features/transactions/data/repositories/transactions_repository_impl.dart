import 'package:dartz/dartz.dart';

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

  const TransactionsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    if (!await networkInfo.isConnected) {
      // Si no hay conexión, devolvemos un set de datos de prueba,
      // esto asegura que mostremos "datos no sensibles" en caso de
      // que no haya red, de acuerdo a la instrucción.
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
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
