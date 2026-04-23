import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/features/dashboard/domain/entities/recent_transaction.dart';
import 'package:bank_go/features/dashboard/data/models/recent_transaction_model.dart';

void main() {
  group('RecentTransactionModel', () {
    test('placeholders returns non-empty list', () {
      final placeholders = RecentTransactionModel.placeholders();
      expect(placeholders, isNotEmpty);
    });

    test('placeholder items have non-zero amounts', () {
      final placeholders = RecentTransactionModel.placeholders();
      for (final t in placeholders) {
        expect(t.amount, isNot(equals(0)));
      }
    });

    test('income transactions have positive amounts', () {
      final placeholders = RecentTransactionModel.placeholders();
      final incomeTransactions =
          placeholders.where((t) => t.type == TransactionType.income);
      for (final t in incomeTransactions) {
        expect(t.amount, greaterThan(0));
      }
    });

    test('expense transactions have negative amounts', () {
      final placeholders = RecentTransactionModel.placeholders();
      final expenseTransactions =
          placeholders.where((t) => t.type == TransactionType.expense);
      for (final t in expenseTransactions) {
        expect(t.amount, lessThan(0));
      }
    });

    test('isIncome returns true for income type', () {
      final transaction = RecentTransactionModel(
        id: '1',
        title: 'Test',
        subtitle: 'Sub',
        amount: 1000,
        type: TransactionType.income,
        date: DateTime.now(),
      );
      expect(transaction.isIncome, isTrue);
      expect(transaction.isExpense, isFalse);
    });

    test('isExpense returns true for expense type', () {
      final transaction = RecentTransactionModel(
        id: '2',
        title: 'Test',
        subtitle: 'Sub',
        amount: -500,
        type: TransactionType.expense,
        date: DateTime.now(),
      );
      expect(transaction.isExpense, isTrue);
      expect(transaction.isTransfer, isFalse);
    });
  });
}
