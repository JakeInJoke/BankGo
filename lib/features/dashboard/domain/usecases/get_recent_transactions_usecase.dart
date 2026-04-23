import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';
import 'package:bank_go/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetRecentTransactionsUseCase {
  final DashboardRepository repository;

  const GetRecentTransactionsUseCase(this.repository);

  Future<Either<Failure, List<RecentTransaction>>> call({int limit = 5}) =>
      repository.getRecentTransactions(limit: limit);
}
