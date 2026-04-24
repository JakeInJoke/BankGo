import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_event.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsUseCase getTransactionsUseCase;
  static const int _pageSize = 5;

  TransactionsBloc({required this.getTransactionsUseCase})
      : super(const TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionsFilterChanged>(_onFilterChanged);
    on<TransactionsLoadMore>(_onLoadMore);
  }

  Future<void> _onLoad(
    TransactionsLoadRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());
    final result = await getTransactionsUseCase(
      page: 1,
      limit: _pageSize,
      type: event.type,
    );
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (transactions) => emit(
        TransactionsLoaded(
          transactions: transactions,
          activeFilter: event.type,
          currentPage: 1,
          hasMorePages: transactions.length >= _pageSize,
        ),
      ),
    );
  }

  Future<void> _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    // Reset to page 1 when filter changes
    add(TransactionsLoadRequested(type: event.type));
  }

  Future<void> _onLoadMore(
    TransactionsLoadMore event,
    Emitter<TransactionsState> emit,
  ) async {
    if (state is TransactionsLoaded) {
      final currentState = state as TransactionsLoaded;
      if (currentState.isLoadingMore || !currentState.hasMorePages) {
        return;
      }

      // Emit loading state
      emit(currentState.copyWith(isLoadingMore: true));

      final nextPage = currentState.currentPage + 1;
      final result = await getTransactionsUseCase(
        page: nextPage,
        limit: _pageSize,
        type: event.type ?? currentState.activeFilter,
      );

      result.fold(
        (failure) => emit(TransactionsError(failure.message)),
        (newTransactions) => emit(
          currentState.copyWith(
            transactions: [...currentState.transactions, ...newTransactions],
            currentPage: nextPage,
            hasMorePages: newTransactions.length >= _pageSize,
            isLoadingMore: false,
          ),
        ),
      );
    }
  }
}
