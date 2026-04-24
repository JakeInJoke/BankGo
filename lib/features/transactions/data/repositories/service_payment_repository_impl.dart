import 'package:dartz/dartz.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/transactions/data/datasources/service_payment_remote_datasource.dart';
import 'package:bank_go/features/transactions/domain/repositories/service_payment_repository.dart';

class ServicePaymentRepositoryImpl implements ServicePaymentRepository {
  final ServicePaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  const ServicePaymentRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, void>> processServicePayment({
    required String serviceName,
    required double amount,
    required String sourceAccountId,
  }) async {
    if (!await networkInfo.isConnected) {
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      await remoteDataSource.processServicePayment(
        serviceName: serviceName,
        amount: amount,
        sourceAccountId: sourceAccountId,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
