import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/transactions/data/datasources/transfer_remote_datasource.dart';
import 'package:bank_go/features/transactions/domain/entities/transfer_recipient.dart';
import 'package:bank_go/features/transactions/domain/repositories/transfer_repository.dart';

class TransferRepositoryImpl implements TransferRepository {
  final TransferRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const TransferRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, TransferRecipient>> validateDestinationAccount(
    String accountNumber,
  ) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final recipient =
          await remoteDataSource.validateDestinationAccount(accountNumber);
      return Right(recipient);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, String>> requestSecurityToken() async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'Sin conexión a internet. No se puede solicitar el token.',
        ),
      );
    }
    try {
      final token = await remoteDataSource.requestSecurityToken();
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      await remoteDataSource.submitTransfer(
        beneficiary: beneficiary,
        sourceAccountId: sourceAccountId,
        amount: amount,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
