import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCachedUserUseCase {
  final AuthRepository repository;

  const GetCachedUserUseCase(this.repository);

  Future<Either<Failure, User>> call() => repository.getCachedUser();
}
