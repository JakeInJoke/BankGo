import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import 'package:bank_go/features/auth/presentation/pages/login_page.dart';
import 'package:bank_go/features/auth/presentation/pages/pin_login_page.dart';
import 'package:bank_go/features/auth/presentation/pages/pin_setup_page.dart';
import 'package:bank_go/features/auth/presentation/pages/splash_page.dart';
import 'package:bank_go/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:bank_go/features/accounts/presentation/pages/accounts_page.dart';
import 'package:bank_go/features/transactions/presentation/pages/transactions_page.dart';
import 'package:bank_go/features/transactions/presentation/pages/payment_page.dart';
import 'package:bank_go/features/profile/presentation/pages/profile_page.dart';

import 'package:bank_go/features/transactions/presentation/pages/transfer_wizard_page.dart';
import 'package:bank_go/features/accounts/presentation/pages/card_details_page.dart';
import 'package:bank_go/features/transactions/presentation/pages/service_payment_page.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';
import 'package:bank_go/features/accounts/presentation/bloc/card_bloc.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String pinSetup = '/pin-setup';
  static const String pinLogin = '/pin-login';
  static const String dashboard = '/dashboard';
  static const String accounts = '/accounts';
  static const String transactions = '/transactions';
  static const String payment = '/payment';
  static const String profile = '/profile';
  static const String transferWizard = '/transfer-wizard';
  static const String cardDetails = '/card-details';
  static const String servicePayment = '/service-payment';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashPage(), settings);
      case login:
        return _fadeRoute(const LoginPage(), settings);
      case pinSetup:
        return _fadeRoute(const PinSetupPage(), settings);
      case pinLogin:
        return _fadeRoute(const PinLoginPage(), settings);
      case dashboard:
        return _fadeRoute(const DashboardPage(), settings);
      case accounts:
        return _slideRoute(const AccountsPage(), settings);
      case transactions:
        return _slideRoute(const TransactionsPage(), settings);
      case payment:
        return _slideRoute(const PaymentPage(), settings);
      case profile:
        return _slideRoute(const ProfilePage(), settings);
      case transferWizard:
        return _slideRoute(const TransferWizardPage(), settings);
      case cardDetails:
        final account = settings.arguments as Account;
        return _slideRoute(
          BlocProvider(
            create: (_) => GetIt.instance<CardBloc>(),
            child: CardDetailsPage(account: account),
          ),
          settings,
        );
      case servicePayment:
        final initialService = settings.arguments as String?;
        return _slideRoute(
          ServicePaymentPage(initialService: initialService),
          settings,
        );
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
