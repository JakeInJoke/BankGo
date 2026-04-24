import 'dart:async';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/features/transactions/domain/entities/transaction.dart';

class MockBankApi {
  static const String demoEmail = 'demo@bankgo.com';
  static const String demoPassword = 'BankGo123!';
  static const Map<String, Map<String, String>> _verifiedDestinationAccounts = {
    '7711223344556677': {
      'holder_name': 'María García',
      'bank_name': 'Banco del Pacífico',
      'alias': 'Renta departamento',
    },
    '8899001122334455': {
      'holder_name': 'Juan Pérez',
      'bank_name': 'Banco Andino',
      'alias': 'Proveedor frecuente',
    },
  };

  // Internal state for demo purposes
  static final Map<String, bool> _isCardEnabledByAccount = {
    '1': true,
    '2': true,
    '3': true,
  };
  static const List<String> demoAccountIds = ['1', '2', '3'];

  static bool isCardEnabledForAccount(String accountId) =>
      _isCardEnabledByAccount[accountId] ?? true;

  static bool get isAnyCardEnabled =>
      _isCardEnabledByAccount.values.any((enabled) => enabled);

  static String? currentToken;
  static final Map<String, String> _cardOperationTokenByAccount = {};
  static int _servicePaymentCount = 0;
  static final List<Map<String, dynamic>> _accounts = [
    {
      'id': '1',
      'account_number': '4512345678901234',
      'alias': 'Cuenta Principal',
      'type': 'savings',
      'balance': 24350.80,
      'currency': 'PEN',
      'is_default': true,
      'is_linked_to_card': true,
    },
    {
      'id': '2',
      'account_number': '4598765432109876',
      'alias': 'Cuenta Corriente',
      'type': 'checking',
      'balance': 8750.00,
      'currency': 'PEN',
      'is_default': false,
      'is_linked_to_card': true,
    },
    {
      'id': '3',
      'account_number': '5412345678904321',
      'alias': 'Tarjeta de Crédito',
      'type': 'credit',
      'balance': -3200.50,
      'currency': 'PEN',
      'is_default': false,
      'is_linked_to_card': true,
      'credit_limit': 50000.00,
      'consumption': 3200.50,
    },
  ];
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
      'source_account_id': '1',
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
      'source_account_id': '1',
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
      'source_account_id': '2',
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
      'source_account_id': '3',
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
      'source_account_id': '1',
    },
    {
      'id': '6',
      'title': 'CFE - Luz',
      'subtitle': 'Servicio eléctrico',
      'description': 'Pago de servicio eléctrico',
      'amount': -450.00,
      'status': 'completed',
      'date': '2026-04-18T11:20:00.000',
      'category': 'Servicios',
      'reference': null,
      'icon_name': 'bolt',
      'source_account_id': '2',
      'type': 'service',
    },
  ];

  const MockBankApi();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    String? codeChallenge,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email.trim().toLowerCase() != demoEmail || password != demoPassword) {
      throw const UnauthorizedException(
        message: 'Credenciales demo inválidas',
      );
    }

    // Validate PKCE code_challenge (simulated validation)
    if (codeChallenge != null && codeChallenge.isEmpty) {
      throw const ServerException(
        message: 'Code challenge inválido',
      );
    }

    return {
      'id': 'usr_demo_001',
      'name': 'Ana Gómez',
      'email': demoEmail,
      'phone': '+52 55 1234 5678',
      'avatar_url': null,
      'token': 'mock-access-token-demo-001',
      'access_token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c3JfZGVtb18wMDEiLCJpYXQiOjE2MTY1NjAwMDB9.mock-access-token',
      'id_token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiJ1c3JfZGVtb18wMDEiLCJhdWQiOiJiYW5rZ28tYXBwIiwiaWF0IjoxNjE2NTYwMDAwfQ.mock-id-token',
      'token_type': 'Bearer',
      'expires_in': 3600,
      'scope': 'openid profile email offline_access',
    };
  }

  Future<Map<String, dynamic>> getAccountSummary() async {
    await Future.delayed(const Duration(milliseconds: 1200));
    final principal = _accountById('1')!;
    final accountNumber = principal['account_number'] as String;
    final lastFour = accountNumber.substring(accountNumber.length - 4);
    final availableBalance = (principal['balance'] as num).toDouble();
    return {
      'total_balance': availableBalance,
      'available_balance': availableBalance,
      'account_number': '**** **** **** $lastFour',
      'account_type': 'Cuenta de Ahorros',
      'card_last_four': lastFour,
    };
  }

  Future<List<Map<String, dynamic>>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _accounts.map((a) => Map<String, dynamic>.from(a)).toList();
  }

  Future<Map<String, dynamic>> getCardDetails(String accountId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final cardData = _cardDataByAccountId(accountId);
    // Simulated dynamic CVV and card info
    return {
      'card_number': cardData.cardNumber,
      'card_holder': cardData.cardHolder,
      'expiration_date': cardData.expirationDate,
      'cvv': (100 + (DateTime.now().minute % 900)).toString(),
      'type': cardData.type,
      'is_enabled': isCardEnabledForAccount(accountId),
    };
  }

  Future<String> requestSecurityToken({String? accountId}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final token = (100000 + (DateTime.now().millisecond % 900000)).toString();
    if (accountId == null) {
      currentToken = token;
    } else {
      _cardOperationTokenByAccount[accountId] = token;
    }
    return token;
  }

  Future<bool> validateAccount(String accountNumber) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _verifiedDestinationAccounts.containsKey(accountNumber);
  }

  Future<Map<String, String>?> getVerifiedDestinationAccount(
    String accountNumber,
  ) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final account = _verifiedDestinationAccounts[accountNumber];
    if (account == null) {
      return null;
    }
    return Map<String, String>.from(account)
      ..['account_number'] = accountNumber;
  }

  Future<Map<String, dynamic>> processServicePayment({
    required String serviceName,
    required double amount,
    required String sourceAccountId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    _servicePaymentCount++;
    if (_servicePaymentCount % 2 == 0) {
      throw const ServerException(
          message:
              'No se pudo procesar tu pago en este momento. Intenta de nuevo.');
    }

    if (!isCardEnabledForAccount(sourceAccountId)) {
      throw const ServerException(
          message:
              'No se pueden realizar operaciones con la tarjeta apagada. Por favor enciéndala.');
    }

    final sourceAccount = _accountById(sourceAccountId);
    if (sourceAccount == null) {
      throw const ServerException(message: 'Cuenta de origen no encontrada.');
    }

    final type = sourceAccount['type'] as String;
    if (type == 'credit') {
      final creditLimit =
          (sourceAccount['credit_limit'] as num?)?.toDouble() ?? 0;
      final currentConsumption =
          (sourceAccount['consumption'] as num?)?.toDouble() ?? 0;
      if ((creditLimit - currentConsumption) < amount) {
        throw const ServerException(
            message: 'Línea de crédito insuficiente para realizar el pago.');
      }
      sourceAccount['consumption'] = currentConsumption + amount;
      sourceAccount['balance'] = -(currentConsumption + amount);
    } else {
      final currentBalance = (sourceAccount['balance'] as num).toDouble();
      if (currentBalance < amount) {
        throw const ServerException(
            message: 'Saldo insuficiente para realizar el pago.');
      }
      sourceAccount['balance'] = currentBalance - amount;
    }

    final newTransaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Pago de $serviceName',
      'subtitle': serviceName,
      'description': 'Pago de servicio $serviceName desde la App',
      'amount': -amount,
      'type': 'service',
      'status': 'completed',
      'date': DateTime.now().toIso8601String(),
      'category': 'Servicios',
      'reference': 'PAY-${DateTime.now().millisecondsSinceEpoch}',
      'icon_name': 'receipt',
      'source_account_id': sourceAccountId,
    };

    _allTransactions.insert(0, newTransaction);
    return newTransaction;
  }

  Future<List<Map<String, dynamic>>> getRecentTransactions({
    int limit = 5,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));
    return _allTransactions.take(limit).toList();
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
    if (start >= filtered.length) return [];
    final end = (start + limit).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  Future<Map<String, dynamic>> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final verifiedDestination = _verifiedDestinationAccounts[beneficiary];
    if (verifiedDestination == null) {
      throw const ServerException(
        message: 'La cuenta de destino no está verificada.',
      );
    }

    if (token != currentToken) {
      throw const ServerException(
          message: 'Token de seguridad inválido o expirado.');
    }

    final sourceAccount = _accountById(sourceAccountId);
    if (sourceAccount == null) {
      throw const ServerException(message: 'Cuenta de origen no encontrada.');
    }

    final type = sourceAccount['type'] as String;
    if (type == 'credit') {
      final creditLimit =
          (sourceAccount['credit_limit'] as num?)?.toDouble() ?? 0;
      final currentConsumption =
          (sourceAccount['consumption'] as num?)?.toDouble() ?? 0;
      if ((creditLimit - currentConsumption) < amount) {
        throw const ServerException(
            message: 'Línea de crédito insuficiente para transferir.');
      }
      sourceAccount['consumption'] = currentConsumption + amount;
      sourceAccount['balance'] = -(currentConsumption + amount);
    } else {
      final currentBalance = (sourceAccount['balance'] as num).toDouble();
      if (currentBalance < amount) {
        throw const ServerException(
            message: 'Saldo insuficiente para transferir.');
      }
      sourceAccount['balance'] = currentBalance - amount;
    }

    final newTransaction = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'title': 'Transferencia a ${verifiedDestination['holder_name']}',
      'subtitle': 'A: ${verifiedDestination['holder_name']}',
      'description': 'Transferencia interbancaria SPEI',
      'amount': -amount,
      'type': 'transfer',
      'status': 'completed',
      'date': DateTime.now().toIso8601String(),
      'category': 'Transferencia',
      'reference': 'TRF-${DateTime.now().millisecondsSinceEpoch}',
      'icon_name': 'transfer',
      'source_account_id': sourceAccountId,
    };

    _allTransactions.insert(0, newTransaction);
    currentToken = null; // Invalidate token after use
    return newTransaction;
  }

  Future<Map<String, dynamic>> toggleCardFreeze({
    required String accountId,
    required bool freeze,
    required String token,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (token != _cardOperationTokenByAccount[accountId]) {
      throw const ServerException(
          message:
              'Token de seguridad inválido o expirado para esta operación.');
    }

    _isCardEnabledByAccount[accountId] = !freeze;
    _cardOperationTokenByAccount.remove(accountId); // Consume token
    return {
      'status': isCardEnabledForAccount(accountId) ? 'active' : 'frozen',
      'message': isCardEnabledForAccount(accountId)
          ? 'Tarjeta reactivada correctamente'
          : 'Tarjeta congelada correctamente',
    };
  }

  Future<List<Map<String, dynamic>>> getTransactionsForAccount({
    required String accountId,
    int limit = 10,
  }) async {
    await Future.delayed(const Duration(milliseconds: 250));
    final filtered = _allTransactions
        .where((tx) => tx['source_account_id'] == accountId)
        .take(limit)
        .map((tx) => Map<String, dynamic>.from(tx))
        .toList();
    return filtered;
  }

  _CardData _cardDataByAccountId(String accountId) {
    switch (accountId) {
      case '2':
        return const _CardData(
          cardNumber: '4598 7654 3210 9876',
          cardHolder: 'ANA GOMEZ',
          expirationDate: '09/27',
          type: 'Mastercard Debit',
        );
      case '3':
        return const _CardData(
          cardNumber: '5412 3456 7890 4321',
          cardHolder: 'ANA GOMEZ',
          expirationDate: '01/29',
          type: 'Visa Credit',
        );
      case '1':
      default:
        return const _CardData(
          cardNumber: '4512 3456 7890 1234',
          cardHolder: 'ANA GOMEZ',
          expirationDate: '12/28',
          type: 'Visa Gold',
        );
    }
  }

  Map<String, dynamic>? _accountById(String id) {
    for (final account in _accounts) {
      if (account['id'] == id) return account;
    }
    return null;
  }
}

class _CardData {
  final String cardNumber;
  final String cardHolder;
  final String expirationDate;
  final String type;

  const _CardData({
    required this.cardNumber,
    required this.cardHolder,
    required this.expirationDate,
    required this.type,
  });
}
