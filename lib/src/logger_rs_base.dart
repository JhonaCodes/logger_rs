import 'dart:io';

import 'package:logging/logging.dart';

/// Rust-style logger for Dart
///
/// A beautiful logging library for Dart that mimics Rust's compiler output format.
/// Features colored output, precise file locations, and clean formatting.
///
/// Example:
/// ```dart
/// // Debug information
/// Log.d('Starting application');
///
/// // General information
/// Log.i('Server connected successfully');
///
/// // Warnings
/// Log.w('Deprecated API usage detected');
///
/// // Errors with context
/// Log.e('Connection failed', error: exception, stackTrace: stackTrace);
///
/// // Critical/Fatal errors
/// Log.f('Critical system failure');
/// ```

class Log {
  static final Logger _log = _getLogger();

  Log._();

  // ANSI Color codes - Rust style with proper dim colors
  static const String _reset = '\x1B[0m';
  static const String _red = '\x1B[31m';
  static const String _redDim = '\x1B[2m\x1B[31m'; // Dim red
  static const String _yellow = '\x1B[33m';
  static const String _yellowDim = '\x1B[2m\x1B[33m'; // Dim yellow
  static const String _green = '\x1B[32m';
  static const String _greenDim = '\x1B[2m\x1B[32m'; // Dim green
  static const String _cyan = '\x1B[36m';
  static const String _cyanDim = '\x1B[2m\x1B[36m'; // Dim cyan
  static const String _magenta = '\x1B[35m';
  static const String _magentaDim = '\x1B[2m\x1B[35m'; // Dim magenta
  static const String _gray = '\x1B[90m';
  static const String _bold = '\x1B[1m';
  static const String _dim = '\x1B[2m';

  static Logger _getLogger() {
    final logger = Logger.root;

    Logger.root.level = Level.ALL;

    Logger.root.onRecord.listen((LogRecord record) {
      final now = DateTime.now();
      final timestamp =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}.${now.millisecond.toString().padLeft(3, '0')}';

      String levelName = '';
      String prefix = '';
      String message = '';
      String additionalInfo = '';

      // Get caller information for Rust-like location display
      final stackTrace = StackTrace.current.toString();
      final lines = stackTrace.split('\n');
      String location = '';
      String fullPath = '';

      // Find the first valid caller location (skip logging infrastructure)
      for (final line in lines) {
        // Skip internal logging calls
        if (line.contains('logger_rs_base.dart') ||
            line.contains('logging.dart') ||
            line.contains('zone.dart') ||
            line.contains('Logger.')) {
          continue;
        }

        // Try to extract location from package format
        RegExpMatch? match = RegExp(
          r'package:([^/]+)/(.+\.dart):(\d+):(\d+)',
        ).firstMatch(line);

        if (match != null) {
          final packageName = match.group(1)!;
          final filePath = match.group(2)!;
          final lineNum = match.group(3)!;
          final colNum = match.group(4)!;

          // For main package, show relative path
          if (packageName == 'logger_rs') {
            location = 'lib/$filePath:$lineNum:$colNum';
          } else {
            location = 'package:$packageName/$filePath:$lineNum:$colNum';
          }
          fullPath = location;
          break;
        }

        // Try file:// format
        match = RegExp(
          r'file:///(.+\.dart):(\d+):(\d+)',
        ).firstMatch(line);

        if (match != null) {
          fullPath = match.group(1)!;
          final parts = fullPath.split('/');
          if (parts.length > 2) {
            // Show only last 2 parts of path for brevity
            location =
                '${parts[parts.length - 2]}/${parts.last}:${match.group(2)}:${match.group(3)}';
          } else {
            location = '${parts.last}:${match.group(2)}:${match.group(3)}';
          }
          break;
        }
      }

      // Fallback if no location found
      if (location.isEmpty) {
        location = 'unknown location';
        fullPath = '';
      }

      // Rust-like formatting with proper spacing and colors
      switch (record.level) {
        case Level.SEVERE: // Check if it's e() or f() call
          final stackLines = StackTrace.current.toString().split('\n');
          bool isFatalCall = false;

          // Check if called via f() method by looking at stack
          for (final line in stackLines) {
            if (line.contains('Log.f')) {
              isFatalCall = true;
              break;
            }
          }

          if (isFatalCall) {
            // F = CRITICAL (morado)
            levelName = 'critical';
            prefix = '$_bold${_magenta}CRITICAL$_reset';
            message = ': $_magentaDim${record.message}$_reset';
            additionalInfo =
                '\n$_bold$_magenta  --> $_reset$_gray$location$_reset';
            if (fullPath.isNotEmpty && fullPath != location) {
              additionalInfo += '\n$_gray       $fullPath$_reset';
            }
            additionalInfo += '\n$_bold$_magenta   |$_reset';
            additionalInfo +=
                '\n$_bold$_magenta   = $_reset${_bold}critical$_reset: ${_magentaDim}System requires immediate attention$_reset';
            additionalInfo +=
                '\n$_bold$_magenta   = $_reset${_bold}help$_reset: ${_magentaDim}Check system logs and restart if necessary$_reset';
          } else {
            // E = ERROR (rojo)
            levelName = 'error';
            prefix = '$_bold${_red}ERROR$_reset';
            message = ': $_redDim${record.message}$_reset';
            additionalInfo = '\n$_bold$_red  --> $_reset$_gray$location$_reset';
            if (fullPath.isNotEmpty && fullPath != location) {
              additionalInfo += '\n$_gray       $fullPath$_reset';
            }
            additionalInfo += '\n$_bold$_red   |$_reset';

            if (record.error != null) {
              additionalInfo +=
                  '\n$_bold$_red   = $_reset${_bold}error$_reset: $_redDim${record.error}$_reset';
            }
            if (record.stackTrace != null) {
              final errorStackLines =
                  record.stackTrace.toString().split('\n').take(4).toList();
              for (int i = 0; i < errorStackLines.length; i++) {
                final lineNum = (i + 1).toString().padLeft(2);
                additionalInfo +=
                    '\n$_bold$_red$lineNum |$_reset $_gray${errorStackLines[i].trim()}$_reset';
              }
              additionalInfo += '\n$_bold$_red   |$_reset';
            }
          }
          additionalInfo += '\n';
          break;

        case Level.WARNING: // Warning - Yellow like Rust warning
          levelName = 'warning';
          prefix = '$_bold${_yellow}WARNING$_reset';
          message = ': $_yellowDim${record.message}$_reset';
          additionalInfo =
              '\n$_bold$_yellow  --> $_reset$_gray$location$_reset';
          if (fullPath.isNotEmpty && fullPath != location) {
            additionalInfo += '\n$_gray       $fullPath$_reset';
          }
          additionalInfo += '\n$_bold$_yellow   |$_reset';

          if (record.error != null) {
            additionalInfo +=
                '\n$_bold$_yellow   = $_reset${_bold}note$_reset: $_yellowDim${record.error}$_reset';
          }
          additionalInfo += '\n';
          break;

        case Level.INFO: // Info - Green with spacing and clickable link
          levelName = 'info';
          prefix = '$_bold${_green}INFO$_reset';
          message = ': $_greenDim${record.message}$_reset';
          additionalInfo = ' $_gray$location$_reset\n';
          break;

        case Level.FINE: // Debug - Cyan with spacing and clickable link
          levelName = 'debug';
          prefix = '$_bold${_cyan}DEBUG$_reset';
          message = ': $_cyanDim${record.message}$_reset';
          additionalInfo = ' $_gray$location$_reset\n';
          break;

        default: // Trace - Dim with spacing and clickable link
          levelName = 'trace';
          prefix = '$_dim${_gray}TRACE$_reset';
          message = ': $_gray${record.message}$_reset';
          additionalInfo = ' $_gray$location$_reset\n';
      }

      // Rust-like format with proper spacing
      final rustFormat = '$prefix$message$additionalInfo';

      // Print only with Rust-like format (no duplication)

      if (Platform.isAndroid ||
          Platform.isIOS ||
          Platform.isMacOS ||
          Platform.isLinux) {
        // ignore: avoid_print
        print(rustFormat);
      } else {
        // ignore: avoid_print
        print('[$levelName] $timestamp ${record.message}$additionalInfo');
      }
    });

    return logger;
  }

  /// Log a debug message
  static void d(dynamic message) => _log.fine(message);

  /// Log an info message
  static void i(dynamic message) => _log.info(message);

  /// Log a warning message
  static void w(dynamic message) => _log.warning(message);

  /// Log a critical/fatal message
  static void f(dynamic message) => _log.severe(message);

  /// Log an error message with optional error object and stack trace
  static void e(
    dynamic message, {
    DateTime? time,
    Object? error,
    StackTrace? stackTrace,
  }) =>
      _log.severe(message, error, stackTrace);

  /// Log a trace message (most verbose)
  static void t(dynamic message) => _log.finest(message);
}
