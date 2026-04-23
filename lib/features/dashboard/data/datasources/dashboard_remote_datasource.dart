import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/account_summary_model.dart';
import '../models/recent_transaction_model.dart';

abstract class DashboardRemoteDataSource {
  Future<AccountSummaryModel> getAccountSummary();
  Future<List<RecentTransactionModel>> getRecentTransactions({int limit = 5});
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final Dio dio;

  const DashboardRemoteDataSourceImpl({required this.dio});

  @override
  Future<AccountSummaryModel> getAccountSummary() async {
    try {
      // TODO: Replace with real endpoint once API is ready.
      // final response = await dio.get('/dashboard/summary');
      // return AccountSummaryModel.fromJson(response.data);
      await Future.delayed(const Duration(milliseconds: 800));
      return AccountSummaryModel.placeholder();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error al obtener resumen',
        statusCode: e.response?.statusCode,
      );
    }
  }

  @override
  Future<List<RecentTransactionModel>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      // TODO: Replace with real endpoint once API is ready.
      // final response = await dio.get('/dashboard/transactions', queryParameters: {'limit': limit});
      // return (response.data as List).map((e) => RecentTransactionModel.fromJson(e)).toList();
      await Future.delayed(const Duration(milliseconds: 600));
      return RecentTransactionModel.placeholders().take(limit).toList();
    } on DioException catch (e) {
      throw ServerException(
        message: e.message ?? 'Error al obtener transacciones',
        statusCode: e.response?.statusCode,
      );
    }
  }
}
