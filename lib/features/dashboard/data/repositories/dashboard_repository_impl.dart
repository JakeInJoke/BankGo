import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/dashboard/data/models/account_summary_model.dart';
import 'package:bank_go/features/dashboard/data/models/recent_transaction_model.dart';
import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';
import 'package:bank_go/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:bank_go/features/dashboard/data/datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  static const _kSummaryCacheKey = 'CACHE_READ_DASHBOARD_SUMMARY_V1';
  static const _kRecentTxPrefix = 'CACHE_READ_DASHBOARD_TX_V1_';

  const DashboardRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, AccountSummary>> getAccountSummary() async {
    if (!await networkInfo.isConnected) {
      final raw = sharedPreferences.getString(_kSummaryCacheKey);
      if (raw != null) {
        final cached = AccountSummaryModel.fromJson(
            Map<String, dynamic>.from(jsonDecode(raw)));
        return Right(cached);
      }
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final summary = await remoteDataSource.getAccountSummary();
      await sharedPreferences.setString(
        _kSummaryCacheKey,
        jsonEncode({
          'total_balance': summary.totalBalance,
          'available_balance': summary.availableBalance,
          'account_number': summary.accountNumber,
          'account_type': summary.accountType,
          'card_last_four': summary.cardLastFour,
        }),
      );
      return Right(summary);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<RecentTransaction>>> getRecentTransactions({
    int limit = 5,
  }) async {
    final cacheKey = '$_kRecentTxPrefix$limit';
    if (!await networkInfo.isConnected) {
      final raw = sharedPreferences.getString(cacheKey);
      if (raw != null) {
        final decoded = (jsonDecode(raw) as List<dynamic>)
            .map((e) => RecentTransactionModel.fromJson(
                Map<String, dynamic>.from(e as Map)))
            .toList();
        return Right(decoded);
      }
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final transactions = await remoteDataSource.getRecentTransactions(
        limit: limit,
      );
      final serializable = transactions
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'subtitle': t.subtitle,
                'amount': t.amount,
                'type': t.type.name,
                'date': t.date.toIso8601String(),
                'icon_name': t.iconName,
              })
          .toList();
      await sharedPreferences.setString(cacheKey, jsonEncode(serializable));
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
