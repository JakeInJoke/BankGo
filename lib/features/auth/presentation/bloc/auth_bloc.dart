import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:bank_go/features/auth/domain/usecases/get_cached_user_usecase.dart';
import 'package:bank_go/features/auth/domain/usecases/login_usecase.dart';
import 'package:bank_go/features/auth/domain/usecases/logout_usecase.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_event.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/core/utils/app_logger.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCachedUserUseCase getCachedUserUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getCachedUserUseCase,
  }) : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final result = await getCachedUserUseCase();
      result.fold(
        (failure) {
          AppLogger.warn(
            'AUTH_CHECK_FAIL_${failure.statusCode ?? 'N/A'}',
            failure.message,
          );
          emit(const AuthUnauthenticated());
        },
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_CHECK_EXCEPTION',
        'Error no controlado en verificación de sesión',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final result = await loginUseCase(
        dni: event.dni,
        password: event.password,
      );
      result.fold(
        (failure) {
          AppLogger.warn(
            'AUTH_LOGIN_FAIL_${failure.statusCode ?? 'N/A'}',
            failure.message,
          );
          emit(AuthError(failure.message));
        },
        (user) => emit(AuthAuthenticated(user)),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_LOGIN_EXCEPTION',
        'Error no controlado en login',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const AuthError('No se pudo completar el inicio de sesión.'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(const AuthLoading());
      final result = await logoutUseCase();
      result.fold(
        (failure) {
          AppLogger.warn(
            'AUTH_LOGOUT_FAIL_${failure.statusCode ?? 'N/A'}',
            failure.message,
          );
          emit(AuthError(failure.message));
        },
        (_) => emit(const AuthUnauthenticated()),
      );
    } catch (error, stackTrace) {
      AppLogger.error(
        'AUTH_LOGOUT_EXCEPTION',
        'Error no controlado en cierre de sesión',
        error: error,
        stackTrace: stackTrace,
      );
      emit(const AuthError('No se pudo cerrar sesión correctamente.'));
    }
  }
}
