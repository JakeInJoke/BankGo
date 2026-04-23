import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/recent_transaction.dart';
import '../repositories/dashboard_repository.dart';

class GetRecentTransactionsUseCase {
  final DashboardRepository repository;

  const GetRecentTransactionsUseCase(this.repository);

  Future<Either<Failure, List<RecentTransaction>>> call({int limit = 5}) =>
      repository.getRecentTransactions(limit: limit);
}
