import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_account_summary_usecase.dart';
import '../../domain/usecases/get_recent_transactions_usecase.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetAccountSummaryUseCase getAccountSummaryUseCase;
  final GetRecentTransactionsUseCase getRecentTransactionsUseCase;

  DashboardBloc({
    required this.getAccountSummaryUseCase,
    required this.getRecentTransactionsUseCase,
  }) : super(const DashboardInitial()) {
    on<DashboardLoadRequested>(_onLoad);
    on<DashboardRefreshRequested>(_onLoad);
  }

  Future<void> _onLoad(
    DashboardEvent event,
    Emitter<DashboardState> emit,
  ) async {
    emit(const DashboardLoading());

    final summaryResult = await getAccountSummaryUseCase();
    final transactionsResult = await getRecentTransactionsUseCase(limit: 5);

    summaryResult.fold(
      (failure) => emit(DashboardError(failure.message)),
      (summary) => transactionsResult.fold(
        (failure) => emit(DashboardError(failure.message)),
        (transactions) => emit(
          DashboardLoaded(
            accountSummary: summary,
            recentTransactions: transactions,
          ),
        ),
      ),
    );
  }
}
