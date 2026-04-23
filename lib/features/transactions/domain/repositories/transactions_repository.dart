import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/transaction.dart';

abstract class TransactionsRepository {
  Future<Either<Failure, List<Transaction>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  });
}
