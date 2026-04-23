import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/core/utils/currency_formatter.dart';

void main() {
  group('CurrencyFormatter', () {
    group('format', () {
      test('formats positive amount with peso sign', () {
        final result = CurrencyFormatter.format(1234.56);
        expect(result, contains('1,234.56'));
        expect(result, startsWith('\$'));
      });

      test('formats zero correctly', () {
        final result = CurrencyFormatter.format(0);
        expect(result, contains('0.00'));
      });

      test('formats large amounts', () {
        final result = CurrencyFormatter.format(1000000);
        expect(result, contains('1,000,000'));
      });
    });

    group('formatSigned', () {
      test('adds + prefix for positive amounts', () {
        final result = CurrencyFormatter.formatSigned(500);
        expect(result, startsWith('+'));
      });

      test('adds - prefix for negative amounts', () {
        final result = CurrencyFormatter.formatSigned(-200);
        expect(result, contains('-'));
      });
    });

    group('formatCompact', () {
      test('formats thousands with K', () {
        final result = CurrencyFormatter.formatCompact(5000);
        expect(result, contains('K'));
      });
    });
  });
}
