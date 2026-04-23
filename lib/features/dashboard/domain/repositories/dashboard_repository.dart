import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';

abstract class DashboardRepository {
  Future<Either<Failure, AccountSummary>> getAccountSummary();
  Future<Either<Failure, List<RecentTransaction>>> getRecentTransactions({
    int limit = 5,
  });
}
