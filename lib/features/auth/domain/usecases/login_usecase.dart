import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';
import 'package:bank_go/features/auth/domain/repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  const LoginUseCase(this.repository);

  Future<Either<Failure, User>> call({
    required String dni,
    required String password,
  }) {
    return repository.login(dni: dni, password: password);
  }
}
