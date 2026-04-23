import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetAccountSummaryUseCase {
  final DashboardRepository repository;

  const GetAccountSummaryUseCase(this.repository);

  Future<Either<Failure, AccountSummary>> call() =>
      repository.getAccountSummary();
}
