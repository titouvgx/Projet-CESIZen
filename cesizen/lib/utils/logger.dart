import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class AppLogger {
  static const bool _isProduction = bool.fromEnvironment('dart.vm.product');

  static void debug(String message, {String? context}) {
    if (!_isProduction) _log(LogLevel.debug, message, context: context);
  }

  static void info(String message, {String? context}) {
    if (!_isProduction) _log(LogLevel.info, message, context: context);
  }

  static void warning(String message, {String? context}) {
    _log(LogLevel.warning, message, context: context);
  }

  static void error(String message, {String? context, Object? exception}) {
    _log(LogLevel.error, message, context: context);
    if (exception != null && !_isProduction) {
      debugPrint('Exception: $exception');
    }
  }

  static void _log(LogLevel level, String message, {String? context}) {
    final prefix = switch (level) {
      LogLevel.debug   => '🔵 DEBUG',
      LogLevel.info    => '🟢 INFO',
      LogLevel.warning => '🟡 WARN',
      LogLevel.error   => '🔴 ERROR',
    };
    final ctx = context != null ? '[$context]' : '';
    debugPrint('$prefix $ctx $message');
  }
}
