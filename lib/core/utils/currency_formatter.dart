import 'package:intl/intl.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'es_MX',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _compactFormat = NumberFormat.compact(
    locale: 'es_MX',
  );

  /// Formats [amount] as currency (e.g., $1,234.56)
  static String format(double amount) => _currencyFormat.format(amount);

  /// Formats [amount] in compact notation (e.g., $1.2K)
  static String formatCompact(double amount) {
    return '\$${_compactFormat.format(amount).toUpperCase()}';
  }

  /// Returns a signed string with + or - prefix
  static String formatSigned(double amount) {
    final sign = amount >= 0 ? '+' : '';
    return '$sign${format(amount)}';
  }

  /// Parses a currency string to double. Returns null if invalid.
  static double? parse(String value) {
    try {
      return _currencyFormat.parse(value).toDouble();
    } catch (_) {
      return double.tryParse(
        value.replaceAll(',', '').replaceAll('\$', '').trim(),
      );
    }
  }
}
