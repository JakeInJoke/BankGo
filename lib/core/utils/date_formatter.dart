import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd/MM/yyyy', 'es_PE');
  static final DateFormat _dateTimeFormat =
      DateFormat('dd/MM/yyyy HH:mm', 'es_PE');
  static final DateFormat _timeFormat = DateFormat('HH:mm', 'es_PE');
  static final DateFormat _monthYearFormat = DateFormat('MMMM yyyy', 'es_PE');
  static final DateFormat _shortDateFormat = DateFormat('dd MMM', 'es_PE');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  static String formatTime(DateTime date) => _timeFormat.format(date);

  static String formatMonthYear(DateTime date) => _monthYearFormat.format(date);

  static String formatShortDate(DateTime date) => _shortDateFormat.format(date);

  /// Returns a relative time string (e.g., "Hace 2 horas")
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inSeconds < 60) return 'Hace un momento';
    if (diff.inMinutes < 60) return 'Hace ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Hace ${diff.inHours} h';
    if (diff.inDays == 1) return 'Ayer';
    if (diff.inDays < 7) return 'Hace ${diff.inDays} días';
    return formatDate(date);
  }
}
