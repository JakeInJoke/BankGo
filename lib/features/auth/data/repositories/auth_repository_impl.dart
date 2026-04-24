import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';
import 'package:bank_go/features/auth/domain/repositories/auth_repository.dart';
import 'package:bank_go/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bank_go/features/auth/data/datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, User>> login({
    required String dni,
    required String password,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(
        NetworkFailure(message: 'Sin conexión a internet'),
      );
    }
    try {
      final user = await remoteDataSource.login(
        dni: dni,
        password: password,
      );
      await localDataSource.cacheUser(user);
      return Right(user);
    } on UnauthorizedException catch (e) {
      return Left(UnauthorizedFailure(message: e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await localDataSource.clearCache();
      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, User>> getCachedUser() async {
    try {
      final user = await localDataSource.getCachedUser();
      return Right(user);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    }
  }

  @override
  Future<Either<Failure, bool>> isLoggedIn() async {
    final result = await getCachedUser();
    return result.fold(
      (_) => const Right(false),
      (_) => const Right(true),
    );
  }
}
