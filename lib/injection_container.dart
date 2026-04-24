import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/network/network_info.dart';
import 'package:bank_go/core/network/dio_interceptor.dart';
import 'package:bank_go/core/network/mock_interceptor.dart';
import 'package:bank_go/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bank_go/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:bank_go/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bank_go/features/auth/domain/repositories/auth_repository.dart';
import 'package:bank_go/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:bank_go/features/auth/domain/usecases/login_usecase.dart';
import 'package:bank_go/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:bank_go/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:bank_go/features/dashboard/domain/repositories/dashboard_repository.dart';
import 'package:bank_go/features/dashboard/domain/usecases/get_account_summary_usecase.dart';
import 'package:bank_go/features/dashboard/domain/usecases/get_recent_transactions_usecase.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:bank_go/features/transactions/data/datasources/transactions_remote_datasource.dart';
import 'package:bank_go/features/transactions/data/repositories/transactions_repository_impl.dart';
import 'package:bank_go/features/transactions/domain/repositories/transactions_repository.dart';
import 'package:bank_go/features/transactions/domain/usecases/get_transactions_usecase.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transactions_bloc.dart';
import 'package:bank_go/features/accounts/data/datasources/accounts_remote_datasource.dart';
import 'package:bank_go/features/accounts/data/repositories/accounts_repository_impl.dart';
import 'package:bank_go/features/accounts/domain/repositories/accounts_repository.dart';

import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transfer_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ────────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => const FlutterSecureStorage());
  sl.registerLazySingleton(() => Connectivity());

  sl.registerLazySingleton(() => const MockBankApi());

  sl.registerLazySingleton(() {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.bankgo.com/v1',
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Security Interceptor
    dio.interceptors.add(DioInterceptor(getAccessToken: () {
      try {
        return sl<AuthLocalDataSource>().getUserSync()?.token;
      } catch (_) {
        return null;
      }
    }));

    // Add Mock Interceptor
    dio.interceptors.add(MockInterceptor(mockBankApi: sl()));

    return dio;
  });

  // ─── Core ─────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // ─── Features: Auth ───────────────────────────────────────────────────────────
  // BLoC
  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getCachedUserUseCase: sl(),
    ),
  );
  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetCachedUserUseCase(sl()));
  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(mockBankApi: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(
      sharedPreferences: sl(),
      secureStorage: sl(),
    ),
  );

  // ─── Features: Dashboard ──────────────────────────────────────────────────────
  // BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getAccountSummaryUseCase: sl(),
      getRecentTransactionsUseCase: sl(),
    ),
  );
  sl.registerFactory(() => SimulationBloc());
  // Use cases
  sl.registerLazySingleton(() => GetAccountSummaryUseCase(sl()));
  sl.registerLazySingleton(() => GetRecentTransactionsUseCase(sl()));
  // Repository
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<DashboardRemoteDataSource>(
    () => DashboardRemoteDataSourceImpl(mockBankApi: sl()),
  );

  // ─── Features: Transactions ───────────────────────────────────────────────────
  sl.registerFactory(
    () => TransactionsBloc(getTransactionsUseCase: sl()),
  );
  sl.registerFactory(() => TransferBloc(sl()));

  // ─── Features: Accounts ───────────────────────────────────────────────────────
  // BLoC
  sl.registerFactory(() => CardBloc(sl()));

  // Repository
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AccountsRemoteDataSource>(
    () => AccountsRemoteDataSourceImpl(mockBankApi: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTransactionsUseCase(sl()));
  // Repository
  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(
      remoteDataSource: sl(),
      networkInfo: sl(),
    ),
  );
  // Data sources
  sl.registerLazySingleton<TransactionsRemoteDataSource>(
    () => TransactionsRemoteDataSourceImpl(mockBankApi: sl()),
  );
}
