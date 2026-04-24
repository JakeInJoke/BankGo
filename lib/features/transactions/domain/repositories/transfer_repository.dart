import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/transactions/domain/entities/transfer_recipient.dart';

abstract class TransferRepository {
  Future<Either<Failure, TransferRecipient>> validateDestinationAccount(
    String accountNumber,
  );

  Future<Either<Failure, String>> requestSecurityToken();

  Future<Either<Failure, void>> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  });
}
