import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/features/accounts/domain/entities/card_details.dart';

abstract class CardRepository {
  Future<Either<Failure, CardDetails>> getCardDetails(String accountId);

  Future<Either<Failure, String>> requestSecurityToken({String? accountId});

  Future<Either<Failure, void>> toggleCardFreeze({
    required String accountId,
    required bool freeze,
    required String token,
  });
}
