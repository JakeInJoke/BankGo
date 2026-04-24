import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:bank_go/core/routes/app_router.dart';
import 'package:bank_go/core/theme/app_theme.dart';
import 'package:bank_go/core/utils/app_logger.dart';
import 'package:bank_go/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bank_go/features/dashboard/presentation/bloc/simulation_bloc.dart';
import 'package:bank_go/injection_container.dart' as di;

import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    AppLogger.error(
      'SYS_FLUTTER_ERROR',
      details.exceptionAsString(),
      error: details.exception,
      stackTrace: details.stack,
    );
  };

  ui.PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error(
      'SYS_PLATFORM_ERROR',
      'Error de plataforma no controlado',
      error: error,
      stackTrace: stack,
    );
    return true;
  };

  await initializeDateFormatting('es_PE', null);
  await di.init();
  runApp(const BankGoApp());
}

class BankGoApp extends StatefulWidget {
  const BankGoApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<BankGoApp> createState() => _BankGoAppState();
}

class _BankGoAppState extends State<BankGoApp> {
  static Timer? _inactivityTimer;
  bool _isOffline = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _connectivitySub =
        di.sl<Connectivity>().onConnectivityChanged.listen((results) {
      final offline = results.contains(ConnectivityResult.none);
      if (offline != _isOffline) {
        setState(() => _isOffline = offline);
      }
    });
    // Check initial state
    di.sl<Connectivity>().checkConnectivity().then((results) {
      if (mounted) {
        setState(() => _isOffline = results.contains(ConnectivityResult.none));
      }
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    _inactivityTimer?.cancel();
    super.dispose();
  }

  void _resetInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(const Duration(minutes: 3), () {
      final currentContext = BankGoApp.navigatorKey.currentContext;
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
      ],
      child: BlocListener<SimulationBloc, SimulationState>(
        listener: (context, state) {
          if (state.hasBlockedAttempt && state.latestMessage != null) {
            _showInAppAlert(state.latestMessage!);
          }
        },
        child: Listener(
          onPointerDown: (_) => _resetInactivityTimer(),
          child: Stack(
            alignment: Alignment.topLeft,
            children: [
              MaterialApp(
                navigatorKey: BankGoApp.navigatorKey,
                scaffoldMessengerKey: BankGoApp.messengerKey,
                title: 'BankGo',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: ThemeMode.system,
                onGenerateRoute: AppRouter.generateRoute,
                initialRoute: AppRouter.splash,
              ),
              if (_isOffline)
                Positioned(
                  top: 48,
                  right: 16,
                  child: SafeArea(
                    child: Material(
                      color: Colors.transparent,
                      child: Tooltip(
                        message: 'Sin conexión a internet',
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade700,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withValues(alpha: 0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.signal_wifi_connected_no_internet_4_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInAppAlert(String message) {
    BankGoApp.messengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
