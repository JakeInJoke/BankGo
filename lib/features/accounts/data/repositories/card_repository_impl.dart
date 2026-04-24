import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/data/datasources/card_remote_datasource.dart';
import 'package:bank_go/features/accounts/domain/entities/card_details.dart';
import 'package:bank_go/features/accounts/domain/repositories/card_repository.dart';

class CardRepositoryImpl implements CardRepository {
  final CardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const CardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, CardDetails>> getCardDetails(String accountId) async {
    try {
      final details = await remoteDataSource.getCardDetails(accountId);
      return Right(details);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, String>> requestSecurityToken({
    String? accountId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(
          message: 'Sin conexión a internet. No se puede solicitar el token.',
        ),
      );
    }
    try {
      final token =
          await remoteDataSource.requestSecurityToken(accountId: accountId);
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCardFreeze({
    required String accountId,
    required bool freeze,
    required String token,
  }) async {
    try {
      await remoteDataSource.toggleCardFreeze(
        accountId: accountId,
        freeze: freeze,
        token: token,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
