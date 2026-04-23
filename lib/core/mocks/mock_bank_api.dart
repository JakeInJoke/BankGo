import 'dart:async';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

class MockBankApi {
  static const String demoEmail = 'demo@bankgo.com';
  static const String demoPassword = 'BankGo123!';

  const MockBankApi();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const UnauthorizedException(
        message: 'Credenciales demo inválidas',
      );
    }

    return {
      'id': 'usr_demo_001',
      'name': 'Ana Gómez',
      'email': demoEmail,
      'phone': '+52 55 1234 5678',
      'avatar_url': null,
      'token': 'mock-access-token-demo-001',
    };
  }

  Future<Map<String, dynamic>> getAccountSummary() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return {
      'total_balance': 24350.80,
      'available_balance': 22100.00,
      'account_number': '****  ****  ****  4521',
      'account_type': 'Cuenta de Ahorros',
      'card_last_four': '4521',
    };
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    return _allTransactions
        .take(limit)
        .map(
          (transaction) => {
            'id': transaction['id'],
            'title': transaction['title'],
            'subtitle': transaction['subtitle'],
            'amount': transaction['amount'],
            'type': transaction['type'],
            'date': transaction['date'],
            'icon_name': transaction['icon_name'],
          },
        )
        .toList();
  }

  Future<List<Map<String, dynamic>>> getTransactions({
    int page = 1,
    int limit = 20,
    TransactionType? type,
    DateTime? from,
    DateTime? to,
  }) async {
    await Future.delayed(const Duration(milliseconds: 450));

    final filtered = _allTransactions.where((transaction) {
      final transactionDate = DateTime.parse(transaction['date'] as String);

      final matchesType = type == null || transaction['type'] == type.name;
      final matchesFrom = from == null || !transactionDate.isBefore(from);
      final matchesTo = to == null || !transactionDate.isAfter(to);

      return matchesType && matchesFrom && matchesTo;
    }).toList();

    final start = (page - 1) * limit;
    if (start >= filtered.length) {
      return [];
    }

    final end = (start + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<Map<String, dynamic>> submitTransfer({
    required String beneficiary,
    required double amount,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return {
      'id': 'trf_mock_001',
      'beneficiary': beneficiary,
      'amount': amount,
      'status': 'completed',
      'confirmation_message': 'Transferencia mock completada con éxito',
    };
  }

  Future<Map<String, dynamic>> toggleCardFreeze({
    required bool freeze,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return {
      'status': freeze ? 'frozen' : 'active',
      'message': freeze
          ? 'Tarjeta congelada correctamente'
          : 'Tarjeta reactivada correctamente',
    };
  }

  static final List<Map<String, dynamic>> _allTransactions = [
    {
      'id': '1',
      'title': 'Salario mensual',
      'subtitle': 'Empresa XYZ',
      'description': 'Depósito de nómina - Empresa XYZ S.A.',
      'amount': 15000.00,
      'type': 'income',
      'status': 'completed',
      'date': '2026-04-23T08:30:00.000',
      'category': 'Nómina',
      'reference': 'NOM-2026-001',
      'icon_name': 'payroll',
    },
    {
      'id': '2',
      'title': 'Supermercado Walmart',
      'subtitle': 'Walmart',
      'description': 'Compra con tarjeta - Walmart Insurgentes',
      'amount': -850.50,
      'type': 'expense',
      'status': 'completed',
      'date': '2026-04-22T18:45:00.000',
      'category': 'Alimentación',
      'reference': null,
      'icon_name': 'cart',
    },
    {
      'id': '3',
      'title': 'Transferencia a Juan Pérez',
      'subtitle': 'A: Juan Pérez',
      'description': 'Pago de renta de local',
      'amount': -2000.00,
      'type': 'transfer',
      'status': 'completed',
      'date': '2026-04-21T10:15:00.000',
      'category': 'Transferencia',
      'reference': 'TRF-20260421-003',
      'icon_name': 'transfer',
    },
    {
      'id': '4',
      'title': 'Netflix',
      'subtitle': 'Suscripción mensual',
      'description': 'Suscripción mensual Premium',
      'amount': -219.00,
      'type': 'expense',
      'status': 'completed',
      'date': '2026-04-20T07:30:00.000',
      'category': 'Entretenimiento',
      'reference': null,
      'icon_name': 'movie',
    },
    {
      'id': '5',
      'title': 'Pago recibido',
      'subtitle': 'De: María García',
      'description': 'Transferencia de María García',
      'amount': 500.00,
      'type': 'income',
      'status': 'completed',
      'date': '2026-04-19T14:00:00.000',
      'category': 'Transferencia',
      'reference': 'TRF-20260419-011',
      'icon_name': 'payment',
    },
    {
      'id': '6',
      'title': 'CFE - Luz',
      'subtitle': 'Servicio eléctrico',
      'description': 'Pago de servicio eléctrico',
      'amount': -450.00,
      'type': 'expense',
      'status': 'completed',
      'date': '2026-04-18T11:20:00.000',
      'category': 'Servicios',
      'reference': null,
      'icon_name': 'bolt',
    },
    {
      'id': '7',
      'title': 'Pago freelance',
      'subtitle': 'Cliente ABC',
      'description': 'Proyecto web - Cliente ABC',
      'amount': 5000.00,
      'type': 'income',
      'status': 'pending',
      'date': '2026-04-17T16:30:00.000',
      'category': 'Freelance',
      'reference': 'FRL-2026-008',
      'icon_name': 'wallet',
    },
  ];
}
