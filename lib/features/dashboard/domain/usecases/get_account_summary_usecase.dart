import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_summary.dart';
import '../repositories/dashboard_repository.dart';

class GetAccountSummaryUseCase {
  final DashboardRepository repository;

  const GetAccountSummaryUseCase(this.repository);

  Future<Either<Failure, AccountSummary>> call() =>
      repository.getAccountSummary();
}
