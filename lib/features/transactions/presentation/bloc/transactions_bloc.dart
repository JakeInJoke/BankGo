import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_transactions_usecase.dart';
import 'transactions_event.dart';
import 'transactions_state.dart';

class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final GetTransactionsUseCase getTransactionsUseCase;

  TransactionsBloc({required this.getTransactionsUseCase})
      : super(const TransactionsInitial()) {
    on<TransactionsLoadRequested>(_onLoad);
    on<TransactionsFilterChanged>(_onFilterChanged);
  }

  Future<void> _onLoad(
    TransactionsLoadRequested event,
    Emitter<TransactionsState> emit,
  ) async {
    emit(const TransactionsLoading());
    final result = await getTransactionsUseCase(type: event.type);
    result.fold(
      (failure) => emit(TransactionsError(failure.message)),
      (transactions) => emit(
        TransactionsLoaded(
          transactions: transactions,
          activeFilter: event.type,
        ),
      ),
    );
  }

  Future<void> _onFilterChanged(
    TransactionsFilterChanged event,
    Emitter<TransactionsState> emit,
  ) async {
    add(TransactionsLoadRequested(type: event.type));
  }
}
