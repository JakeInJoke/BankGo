import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/errors/failures.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/features/accounts/data/datasources/accounts_remote_datasource.dart';
import 'package:bank_go/features/accounts/data/models/account_model.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';
import 'package:bank_go/features/transactions/data/models/transaction_model.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

class AccountsRepositoryImpl implements AccountsRepository {
  final AccountsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;
  final SharedPreferences sharedPreferences;

  static const _kAccountsCacheKey = 'CACHE_READ_ACCOUNTS_V1';
  static const _kTransactionsByAccountPrefix = 'CACHE_READ_TX_ACCOUNT_V1_';

  const AccountsRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
    required this.sharedPreferences,
  });

  @override
  Future<Either<Failure, List<Account>>> getAccounts() async {
    if (!await networkInfo.isConnected) {
      final raw = sharedPreferences.getString(_kAccountsCacheKey);
      if (raw != null) {
        final decoded =
            (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
        final cached = decoded.map(AccountModel.fromJson).toList();
        return Right(cached);
      }
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final accounts = await remoteDataSource.getAccounts();
      final serializable = accounts
          .map((a) => {
                'id': a.id,
                'account_number': a.accountNumber,
                'alias': a.alias,
                'type': a.type.name,
                'balance': a.balance,
                'currency': a.currency,
                'is_default': a.isDefault,
                'is_linked_to_card': a.isLinkedToCard,
                'credit_limit': a.creditLimit,
                'consumption': a.consumption,
              })
          .toList();
      await sharedPreferences.setString(
        _kAccountsCacheKey,
        jsonEncode(serializable),
      );
      return Right(accounts);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }

  @override
  Future<Either<Failure, List<Transaction>>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  }) async {
    final cacheKey = '$_kTransactionsByAccountPrefix${accountId}_$limit';
    if (!await networkInfo.isConnected) {
      final raw = sharedPreferences.getString(cacheKey);
      if (raw != null) {
        final decoded =
            (jsonDecode(raw) as List<dynamic>).cast<Map<String, dynamic>>();
        final cached = decoded.map(TransactionModel.fromJson).toList();
        return Right(cached);
      }
      return const Left(NetworkFailure(message: 'Sin conexión a internet'));
    }
    try {
      final transactions = await remoteDataSource.getTransactionsForAccount(
        accountId: accountId,
        limit: limit,
      );
      final serializable = transactions
          .map((t) => {
                'id': t.id,
                'title': t.title,
                'description': t.description,
                'amount': t.amount,
                'type': t.type.name,
                'status': t.status.name,
                'date': t.date.toIso8601String(),
                'category': t.category,
                'reference': t.reference,
              })
          .toList();
      await sharedPreferences.setString(cacheKey, jsonEncode(serializable));
      return Right(transactions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, statusCode: e.statusCode));
    }
  }
}
