import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer }

class RecentTransaction extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? iconName;

  const RecentTransaction({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.type,
    required this.date,
    this.iconName,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;

  @override
  List<Object?> get props =>
      [id, title, subtitle, amount, type, date, iconName];
}
