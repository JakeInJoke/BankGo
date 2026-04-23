import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/account_summary.dart';
import '../entities/recent_transaction.dart';

abstract class DashboardRepository {
  Future<Either<Failure, AccountSummary>> getAccountSummary();
  Future<Either<Failure, List<RecentTransaction>>> getRecentTransactions({
    int limit = 5,
  });
}
