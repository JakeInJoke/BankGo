import 'package:equatable/equatable.dart';

import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';

class DashboardData extends Equatable {
  final AccountSummary accountSummary;
  final List<RecentTransaction> recentTransactions;

  const DashboardData({
    required this.accountSummary,
    required this.recentTransactions,
  });

  @override
  List<Object> get props => [accountSummary, recentTransactions];
}
