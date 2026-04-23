import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';
import 'package:bank_go/features/auth/domain/repositories/auth_repository.dart';

class GetCachedUserUseCase {
  final AuthRepository repository;

  const GetCachedUserUseCase(this.repository);

  Future<Either<Failure, User>> call() => repository.getCachedUser();
}
