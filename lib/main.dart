import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/constants/app_colors.dart';
import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/core/theme/app_theme.dart';
import 'package:bank_go/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_state.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/injection_container.dart' as di;

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PE', null);
  await di.init();
  runApp(const BankGoApp());
}

class BankGoApp extends StatelessWidget {
  const BankGoApp({super.key});

  static const String _kPinConfigured = 'PIN_CONFIGURED';

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Timer? _inactivityTimer;

  void _resetInactivityTimer() async {
    _inactivityTimer?.cancel();

    // Check connectivity for every user interaction as requested
    final connectivity = await di.sl<Connectivity>().checkConnectivity();
    if (connectivity.contains(ConnectivityResult.none)) {
      _showInAppAlert(
          "No hay conexión a internet. Algunas funciones pueden no estar disponibles.");
    }

    final user = di.sl<AuthLocalDataSource>().getUserSync();
    final isPinConfigured =
        di.sl<SharedPreferences>().getBool(_kPinConfigured) ?? false;

    if (user == null || !isPinConfigured) {
      return;
    }

    _inactivityTimer = Timer(const Duration(minutes: 3), () {
      final currentContext = navigatorKey.currentContext;
      if (currentContext != null) {
        currentContext.read<SimulationBloc>().add(StopSimulation());
        Navigator.of(currentContext)
            .pushNamedAndRemoveUntil('/pin-login', (route) => false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => GetIt.instance<AuthBloc>(),
        ),
        BlocProvider<SimulationBloc>(
          create: (_) => GetIt.instance<SimulationBloc>(),
        ),
        BlocProvider<CardBloc>(
          create: (_) => GetIt.instance<CardBloc>(),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated) {
            context.read<SimulationBloc>().add(StartSimulation());
          } else if (authState is AuthUnauthenticated) {
            context.read<SimulationBloc>().add(StopSimulation());
          }
        },
        child: BlocListener<SimulationBloc, SimulationState>(
          listenWhen: (prev, curr) =>
              (curr.isBlockedAttempt && curr.message != null) ||
              curr.notifications.length > prev.notifications.length,
          listener: (context, state) {
            if (state.isBlockedAttempt && state.message != null) {
              _showInAppAlert(state.message!);
            } else if (state.notifications.isNotEmpty) {
              final latest = state.notifications.first;
              _showNotificationBanner(latest.title, latest.message);
            }
          },
          child: Listener(
            onPointerDown: (_) => _resetInactivityTimer(),
            child: MaterialApp(
              navigatorKey: navigatorKey,
              scaffoldMessengerKey: messengerKey,
              title: 'BankGo',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: ThemeMode.system,
              onGenerateRoute: AppRouter.generateRoute,
              initialRoute: AppRouter.splash,
            ),
          ),
        ),
      ),
    );
  }

  void _showInAppAlert(String message) {
    final isDark = (navigatorKey.currentContext != null) &&
        Theme.of(navigatorKey.currentContext!).brightness == Brightness.dark;
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: isDark ? AppColors.white : AppColors.white),
        ),
        backgroundColor: isDark ? AppColors.error : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationBanner(String title, String message) {
    final isDark = (navigatorKey.currentContext != null) &&
        Theme.of(navigatorKey.currentContext!).brightness == Brightness.dark;
    final background = isDark ? AppColors.grey800 : AppColors.primary;
    final primaryText = isDark ? AppColors.white : Colors.white;
    final secondaryText = isDark ? AppColors.grey300 : Colors.white70;

    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.notifications_rounded, color: primaryText, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: primaryText)),
                  Text(message,
                      style: TextStyle(fontSize: 12, color: secondaryText)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
