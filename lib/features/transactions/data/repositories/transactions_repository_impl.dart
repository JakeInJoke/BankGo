import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transactions_repository.dart';
import '../datasources/transactions_remote_datasource.dart';

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
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
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
