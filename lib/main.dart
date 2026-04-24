import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/core/theme/app_theme.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
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

    _inactivityTimer = Timer(const Duration(minutes: 3), () {
      final currentContext = navigatorKey.currentContext;
      if (currentContext != null) {
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
          create: (_) =>
              GetIt.instance<SimulationBloc>()..add(StartSimulation()),
        ),
        BlocProvider<CardBloc>(
          create: (_) => GetIt.instance<CardBloc>(),
        ),
      ],
      child: BlocListener<SimulationBloc, SimulationState>(
        listener: (context, state) {
          if (state.isBlockedAttempt && state.message != null) {
            _showInAppAlert(state.message!);
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
    );
  }

  void _showInAppAlert(String message) {
    messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
