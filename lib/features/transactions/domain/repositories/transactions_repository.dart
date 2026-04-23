import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  });
}
