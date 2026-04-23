import 'package:equatable/equatable.dart';

class AccountSummary extends Equatable {
  final double totalBalance;
  final double availableBalance;
  final String accountNumber;
  final String accountType;
  final String cardLastFour;

  const AccountSummary({
    required this.totalBalance,
    required this.availableBalance,
    required this.accountNumber,
    required this.accountType,
    required this.cardLastFour,
  });

  @override
  List<Object> get props => [
        totalBalance,
        availableBalance,
        accountNumber,
        accountType,
        cardLastFour,
      ];
}
