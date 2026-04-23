import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction.dart';

abstract class TransactionsEvent extends Equatable {
  const TransactionsEvent();

  @override
  List<Object?> get props => [];
}

class TransactionsLoadRequested extends TransactionsEvent {
  final TransactionType? type;

  const TransactionsLoadRequested({this.type});

  @override
  List<Object?> get props => [type];
}

class TransactionsFilterChanged extends TransactionsEvent {
  final TransactionType? type;

  const TransactionsFilterChanged({this.type});

  @override
  List<Object?> get props => [type];
}
