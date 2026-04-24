import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

abstract class AccountsRepository {
  Future<Either<Failure, List<Account>>> getAccounts();

  Future<Either<Failure, List<Transaction>>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  });
}
