import 'package:equatable/equatable.dart';

import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

abstract class TransactionsState extends Equatable {
  const TransactionsState();

  @override
  List<Object?> get props => [];
}

class TransactionsInitial extends TransactionsState {
  const TransactionsInitial();
}

class TransactionsLoading extends TransactionsState {
  const TransactionsLoading();
}

class TransactionsLoaded extends TransactionsState {
  final List<Transaction> transactions;
  final TransactionType? activeFilter;
  final int currentPage;
  final bool hasMorePages;
  final bool isLoadingMore;

  const TransactionsLoaded({
    required this.transactions,
    this.activeFilter,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.isLoadingMore = false,
  });

  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    TransactionType? activeFilter,
    int? currentPage,
    bool? hasMorePages,
    bool? isLoadingMore,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      activeFilter: activeFilter ?? this.activeFilter,
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  @override
  List<Object?> get props =>
      [transactions, activeFilter, currentPage, hasMorePages, isLoadingMore];
}

class TransactionsError extends TransactionsState {
  final String message;

  const TransactionsError(this.message);

  @override
  List<Object> get props => [message];
}
