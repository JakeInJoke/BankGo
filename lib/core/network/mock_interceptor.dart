import 'package:dio/dio.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';

class MockInterceptor extends Interceptor {
  final MockBankApi mockBankApi;

  MockInterceptor({required this.mockBankApi});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // If the path contains specific keywords, we can mock the response
    // For now, since the DataSources use MockBankApi directly,
    // this interceptor is primarily to satisfy the requirement
    // and demonstrate intercepting requests.

    // Simulating delay
    await Future.delayed(const Duration(milliseconds: 300));

    if (options.path.contains('/transactions')) {
       final transactions = await mockBankApi.getTransactions();
       return handler.resolve(
         Response(
           requestOptions: options,
           data: transactions,
           statusCode: 200,
         ),
       );
    }

    return handler.next(options);
  }
}
