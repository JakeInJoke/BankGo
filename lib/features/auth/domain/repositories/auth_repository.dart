import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> login({
    required String dni,
    required String password,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCachedUser();

  Future<Either<Failure, bool>> isLoggedIn();
}
