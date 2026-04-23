import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/network/network_info.dart';
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

final sl = GetIt.instance;

Future<void> init() async {
  // ─── External ────────────────────────────────────────────────────────────────
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  sl.registerLazySingleton(() => Dio(
        BaseOptions(
          baseUrl: 'https://api.bankgo.com/v1',
          connectTimeout: const Duration(seconds: 30),
          receiveTimeout: const Duration(seconds: 30),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      ));
  sl.registerLazySingleton(() => const MockBankApi());

  // ─── Core ─────────────────────────────────────────────────────────────────────
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

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
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  // ─── Features: Dashboard ──────────────────────────────────────────────────────
  // BLoC
  sl.registerFactory(
    () => DashboardBloc(
      getAccountSummaryUseCase: sl(),
      getRecentTransactionsUseCase: sl(),
    ),
  );
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
  // BLoC
  sl.registerFactory(
    () => TransactionsBloc(getTransactionsUseCase: sl()),
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
