import 'package:equatable/equatable.dart';

import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final AccountSummary accountSummary;
  final List<RecentTransaction> recentTransactions;

  const DashboardLoaded({
    required this.accountSummary,
    required this.recentTransactions,
  });

  @override
  List<Object> get props => [accountSummary, recentTransactions];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object> get props => [message];
}
