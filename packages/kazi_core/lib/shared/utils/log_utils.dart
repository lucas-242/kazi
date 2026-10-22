import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:kazi_core/shared/models/errors.dart';

enum LogColor { red, blue, green, yellow }

abstract class Log {
  static const _logColors = <LogColor, String>{
    LogColor.red: '31',
    LogColor.blue: '32',
    LogColor.yellow: '33',
    LogColor.green: '35',
  };

  static void navigation(String message) {
    _log(
      message: message,
      color: LogColor.blue,
      type: 'Navigation',
    );
  }

  static void info(String message) {
    _log(
      message: message,
      color: LogColor.yellow,
      type: 'Info',
    );
  }

  static void flow(String message) {
    _log(
      message: message,
      color: LogColor.green,
      type: 'Flow',
    );
  }

  static void error(
    Object? error, [
    StackTrace? stackTrace,
    String? message,
  ]) {
    _log(
      type: 'Error',
      message: message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log({
    String? message,
    String type = 'Unknown',
    LogColor color = LogColor.red,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _logEmptyLine(type, color);
    _logMessage(message, type, color);
    _logError(error, type, color);
    _logStackTrace(stackTrace, type, color);
    _logEmptyLine(type, color);
  }

  static void _logEmptyLine(String type, LogColor color) {
    developer.log(
      '''\x1B[${_logColors[color]}m.---------------------------------------------------------------\x1B[0m''',
      name: type,
    );
  }

  static void _logMessage(String? message, String type, LogColor color) {
    if (message != null) {
      developer.log(
        '''\x1B[${_logColors[color]}m. Message: $message\x1B[0m''',
        name: type,
      );
    }
  }

  static void _logError(Object? error, String type, LogColor color) {
    if (error == null) return;
    for (final line in describeError(error)) {
      developer.log(
        '''\x1B[${_logColors[color]}m. $line\x1B[0m''',
        name: type,
      );
    }
  }

  /// The lines [error] prints as: an [AppError] by its code, kind and message,
  /// then one line per cause beneath it; anything else by its `toString`.
  @visibleForTesting
  static List<String> describeError(Object error) {
    if (error is! AppError) return ['Error: $error'];

    final lines = [
      'Error: ${error.code} (${ErrorKind.of(error).value}) — ${error.message}',
    ];
    Object? cause = error.cause;
    while (cause != null) {
      if (cause is AppError) {
        lines.add('Cause: ${cause.code} — ${cause.message}');
        cause = cause.cause;
      } else {
        lines.add('Cause: $cause');
        cause = null;
      }
    }
    return lines;
  }

  static void _logStackTrace(
    StackTrace? stackTrace,
    String type,
    LogColor color,
  ) {
    if (stackTrace != null) {
      developer.log(
        '''\x1B[${_logColors[color]}m. StackTrace: ${stackTrace.toString()} \x1B[0m''',
        name: type,
      );
    }
  }
}
