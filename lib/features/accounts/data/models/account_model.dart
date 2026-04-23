import 'package:bank_go/features/accounts/domain/entities/account.dart';

class AccountModel extends Account {
  const AccountModel({
    required super.id,
    required super.accountNumber,
    required super.alias,
    required super.type,
    required super.balance,
    required super.currency,
    super.isDefault,
  });

  factory AccountModel.fromJson(Map<String, dynamic> json) {
    return AccountModel(
      id: json['id'] as String,
      accountNumber: json['account_number'] as String,
      alias: json['alias'] as String,
      type: AccountType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => AccountType.savings,
      ),
      balance: (json['balance'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'MXN',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  static List<AccountModel> placeholders() {
    return [
      const AccountModel(
        id: '1',
        accountNumber: '4512345678901234',
        alias: 'Cuenta Principal',
        type: AccountType.savings,
        balance: 24350.80,
        currency: 'MXN',
        isDefault: true,
      ),
      const AccountModel(
        id: '2',
        accountNumber: '4598765432109876',
        alias: 'Cuenta Corriente',
        type: AccountType.checking,
        balance: 8750.00,
        currency: 'MXN',
      ),
      const AccountModel(
        id: '3',
        accountNumber: '5412345678904321',
        alias: 'Tarjeta de Crédito',
        type: AccountType.credit,
        balance: -3200.50,
        currency: 'MXN',
      ),
    ];
  }
}
