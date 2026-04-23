import 'package:flutter/material.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/accounts/presentation/pages/accounts_page.dart';
import '../../features/transactions/presentation/pages/transactions_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String dashboard = '/dashboard';
  static const String accounts = '/accounts';
  static const String transactions = '/transactions';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashPage(), settings);
      case login:
        return _fadeRoute(const LoginPage(), settings);
      case dashboard:
        return _fadeRoute(const DashboardPage(), settings);
      case accounts:
        return _slideRoute(const AccountsPage(), settings);
      case transactions:
        return _slideRoute(const TransactionsPage(), settings);
      case profile:
        return _slideRoute(const ProfilePage(), settings);
      default:
        return _fadeRoute(
          Scaffold(
            body: Center(
              child: Text('Ruta no encontrada: ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder<T> _fadeRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static PageRouteBuilder<T> _slideRoute<T>(
    Widget page,
    RouteSettings settings,
  ) {
    return PageRouteBuilder<T>(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.easeInOut));
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
