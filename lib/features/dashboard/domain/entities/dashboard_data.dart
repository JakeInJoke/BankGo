import 'package:equatable/equatable.dart';

import '../entities/account_summary.dart';
import '../entities/recent_transaction.dart';

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
