import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/data/datasources/accounts_remote_datasource.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const AccountsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final accounts = await remoteDataSource.getAccounts();
      return Right(accounts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final transactions = await remoteDataSource.getTransactionsForAccount(
        accountId: accountId,
        limit: limit,
      );
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
