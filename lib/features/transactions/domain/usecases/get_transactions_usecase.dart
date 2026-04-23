import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';
import '../repositories/transactions_repository.dart';

class GetTransactionsUseCase {
  final TransactionsRepository repository;

  const GetTransactionsUseCase(this.repository);

  Future<Either<Failure, List<Transaction>>> call({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) {
    return repository.getTransactions(
      page: page,
      limit: limit,
      type: type,
      from: from,
      to: to,
    );
  }
}
