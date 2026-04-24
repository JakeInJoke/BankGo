import 'package:equatable/equatable.dart';

enum TransactionType { income, expense, transfer, service }

enum TransactionStatus { completed, pending, failed }

class Transaction extends Equatable {
  final String id;
  final String title;
  final String description;
  final double amount;
  final TransactionType type;
  final TransactionStatus status;
  final DateTime date;
  final String? category;
  final String? reference;

  const Transaction({
    required this.id,
    required this.title,
    required this.description,
    required this.amount,
    required this.type,
    required this.status,
    required this.date,
    this.category,
    this.reference,
  });

  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
  bool get isTransfer => type == TransactionType.transfer;
  bool get isCompleted => status == TransactionStatus.completed;
  bool get isPending => status == TransactionStatus.pending;
  bool get isFailed => status == TransactionStatus.failed;

  @override
  List<Object?> get props =>
      [id, title, description, amount, type, status, date, category, reference];
}
