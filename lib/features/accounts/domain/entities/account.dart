import 'package:equatable/equatable.dart';

enum AccountType { savings, checking, credit }

class Account extends Equatable {
  final String id;
  final String accountNumber;
  final String alias;
  final AccountType type;
  final double balance;
  final String currency;
  final bool isDefault;
  final bool isLinkedToCard;
  final double? creditLimit;
  final double? consumption;

  const Account({
    required this.id,
    required this.accountNumber,
    required this.alias,
    required this.type,
    required this.balance,
    required this.currency,
    this.isDefault = false,
    this.isLinkedToCard = false,
    this.creditLimit,
    this.consumption,
  });

  String get maskedNumber {
    if (accountNumber.length > 4) {
      return '**** **** **** ${accountNumber.substring(accountNumber.length - 4)}';
    }
    return accountNumber;
  }

  double get remainingCredit => (creditLimit ?? 0) - (consumption ?? 0);

  @override
  List<Object?> get props => [
        id,
        accountNumber,
        alias,
        type,
        balance,
        currency,
        isDefault,
        isLinkedToCard,
        creditLimit,
        consumption,
      ];
}
