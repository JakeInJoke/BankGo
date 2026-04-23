import 'package:bank_go/features/dashboard/domain/entities/account_summary.dart';

class AccountSummaryModel extends AccountSummary {
  const AccountSummaryModel({
    required super.totalBalance,
    required super.availableBalance,
    required super.accountNumber,
    required super.accountType,
    required super.cardLastFour,
  });

  factory AccountSummaryModel.fromJson(Map<String, dynamic> json) {
    return AccountSummaryModel(
      totalBalance: (json['total_balance'] as num).toDouble(),
      availableBalance: (json['available_balance'] as num).toDouble(),
      accountNumber: json['account_number'] as String,
      accountType: json['account_type'] as String,
      cardLastFour: json['card_last_four'] as String,
    );
  }

  /// Placeholder data used when API is not yet available.
  factory AccountSummaryModel.placeholder() {
    return const AccountSummaryModel(
      totalBalance: 24350.80,
      availableBalance: 22100.00,
      accountNumber: '****  ****  ****  4521',
      accountType: 'Cuenta de Ahorros',
      cardLastFour: '4521',
    );
  }
}
