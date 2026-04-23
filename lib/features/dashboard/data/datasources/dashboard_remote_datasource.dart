import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/dashboard/data/models/account_summary_model.dart';
import 'package:bank_go/features/dashboard/data/models/recent_transaction_model.dart';

abstract class DashboardRemoteDataSource {
  Future<AccountSummaryModel> getAccountSummary();
  Future<List<RecentTransactionModel>> getRecentTransactions({int limit = 5});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final MockBankApi mockBankApi;

  const DashboardRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<AccountSummaryModel> getAccountSummary() async {
    try {
      final response = await mockBankApi.getAccountSummary();
      return AccountSummaryModel.fromJson(response);
    } catch (_) {
      throw const ServerException(message: 'Error al obtener resumen');
    }
  }

  @override
  Future<List<RecentTransactionModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      final response = await mockBankApi.getRecentTransactions(limit: limit);
      return response.map(RecentTransactionModel.fromJson).toList();
    } catch (_) {
      throw const ServerException(message: 'Error al obtener transacciones');
    }
  }
}
