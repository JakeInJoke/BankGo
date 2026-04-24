import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  AppLogger._();

  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 100,
      colors: !kReleaseMode,
      printEmojis: false,
    ),
    level: kReleaseMode ? Level.warning : Level.debug,
  );

  static void info(String code, String message) {
    _logger.i('[${_safe(code)}] ${_safe(message)}');
  }

  static void warn(String code, String message, {Object? error}) {
    _logger.w('[${_safe(code)}] ${_safe(message)} ${_safeError(error)}');
  }

  static void error(
    String code,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      '[${_safe(code)}] ${_safe(message)} ${_safeError(error)}',
      error: kReleaseMode ? null : error,
      stackTrace: kReleaseMode ? null : stackTrace,
    );
  }

  static String _safeError(Object? error) {
    if (error == null) return '';
    return _safe(error.toString());
  }

  static String _safe(String raw) {
    var value = raw;
    value = value.replaceAll(
      RegExp(r'[\w.+-]+@[\w.-]+\.[A-Za-z]{2,}'),
      '[redacted-email]',
    );
    value = value.replaceAll(RegExp(r'\b\d{6,}\b'), '[redacted-number]');
    value = value.replaceAll(
        RegExp(r'Bearer\s+[A-Za-z0-9._-]+'), 'Bearer [redacted-token]');
    return value;
  }
}
