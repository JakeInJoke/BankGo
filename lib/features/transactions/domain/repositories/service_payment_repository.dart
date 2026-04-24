import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/failures.dart';

abstract class ServicePaymentRepository {
  Future<Either<Failure, void>> processServicePayment({
    required String serviceName,
    required double amount,
    required String sourceAccountId,
  });
}
