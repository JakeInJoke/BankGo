import 'package:bank_go/core/mocks/mock_bank_api.dart';

abstract class ServicePaymentRemoteDataSource {
  Future<void> processServicePayment({
    required String serviceName,
    required double amount,
    required String sourceAccountId,
  });
}

class ServicePaymentRemoteDataSourceImpl
    implements ServicePaymentRemoteDataSource {
  final MockBankApi mockBankApi;

  const ServicePaymentRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<void> processServicePayment({
    required String serviceName,
    required double amount,
    required String sourceAccountId,
  }) async {
    await mockBankApi.processServicePayment(
      serviceName: serviceName,
      amount: amount,
      sourceAccountId: sourceAccountId,
    );
  }
}
