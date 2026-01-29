import 'package:logging/logging.dart';

import 'location_resolver.dart';
import 'log_formatter.dart';
import 'object_formatter.dart';

/// Rust-style logger for Dart.
///
/// A beautiful logging library that mimics Rust's compiler output format.
/// Features colored output, precise file locations, and clean formatting.
///
/// Example:
/// ```dart
/// Log.d('Starting application');
/// Log.i('Server connected successfully');
/// Log.w('Deprecated API usage detected');
/// Log.e('Connection failed', error: exception, stackTrace: stackTrace);
/// Log.f('Critical system failure');
/// ```
class Log {
  static final Logger _logger = _initLogger();

  Log._();

  static Logger _initLogger() {
    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((record) {
      final location = LocationResolver.resolve(StackTrace.current);
      final output = LogFormatter.format(record, location);
      // ignore: avoid_print
      print(output);
    });

    return Logger.root;
  }

  static String _format(dynamic message) => ObjectFormatter.format(message);

  /// Log a trace message (most verbose).
  static void t(dynamic message) => _logger.finest(_format(message));

  /// Log a debug message.
  static void d(dynamic message) => _logger.fine(_format(message));

  /// Log an info message.
  static void i(dynamic message) => _logger.info(_format(message));

  /// Log a warning message.
  static void w(dynamic message) => _logger.warning(_format(message));

  /// Log an error message with optional error object and stack trace.
  static void e(
    dynamic message, {
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _logger.severe(_format(message), error, stackTrace);

  /// Log a critical/fatal message.
  static void f(dynamic message) => _logger.shout(_format(message));
}
