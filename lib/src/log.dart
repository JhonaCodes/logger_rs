import 'package:logging/logging.dart';

import 'export/md_formatter.dart';
import 'export/tagged_entry.dart';
import 'location_resolver.dart';
import 'log_formatter.dart';
import 'object_formatter.dart';

/// Rust-style logger for Dart.
///
/// A beautiful logging library that mimics Rust's compiler output format.
/// Features colored output, precise file locations, and clean formatting.
///
/// ## Basic Logging
///
/// ```dart
/// Log.t('Trace message');     // Most verbose
/// Log.d('Debug message');     // Development info
/// Log.i('Info message');      // General info
/// Log.w('Warning message');   // Potential issues
/// Log.e('Error message');     // Errors
/// Log.f('Fatal message');     // Critical failures
/// ```
///
/// ## Error Logging with Details
///
/// ```dart
/// try {
///   // risky operation
/// } catch (e, stack) {
///   Log.e('Operation failed', error: e, stackTrace: stack);
/// }
/// ```
///
/// ## Tag Logging for AI Analysis
///
/// Group related logs across layers and export for AI analysis:
///
/// ```dart
/// // Tag logs across your app
/// Log.tag('auth', 'User login attempt');
/// Log.tag('auth', {'userId': 123}, level: Level.INFO);
/// Log.tag('auth', 'Login failed', level: Level.SEVERE);
///
/// // Export to console (copy to Claude for analysis)
/// Log.export('auth');
/// ```
///
/// See [tag], [export], and [exportAll] for more details.
class Log {
  /// Internal logger instance.
  static final Logger _logger = _initLogger();

  Log._();

  /// Initializes the root logger with custom formatting.
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

  /// Formats a message using [ObjectFormatter].
  static String _format(dynamic message) => ObjectFormatter.format(message);

  // ══════════════════════════════════════════════════════════════════════════
  // STANDARD LOGGING METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Logs a trace message (most verbose level).
  ///
  /// Use for detailed debugging information that is usually only needed
  /// when diagnosing specific problems.
  ///
  /// ```dart
  /// Log.t('Entering function with params: $params');
  /// ```
  static void t(dynamic message) => _logger.finest(_format(message));

  /// Logs a debug message.
  ///
  /// Use for development-time information useful during debugging.
  ///
  /// ```dart
  /// Log.d('Processing item: $item');
  /// ```
  static void d(dynamic message) => _logger.fine(_format(message));

  /// Logs an info message.
  ///
  /// Use for general operational information about application progress.
  ///
  /// ```dart
  /// Log.i('Server started on port 8080');
  /// ```
  static void i(dynamic message) => _logger.info(_format(message));

  /// Logs a warning message.
  ///
  /// Use for potentially harmful situations that don't prevent operation
  /// but should be addressed.
  ///
  /// ```dart
  /// Log.w('Deprecated API usage detected');
  /// ```
  static void w(dynamic message) => _logger.warning(_format(message));

  /// Logs an error message with optional error object and stack trace.
  ///
  /// Use for error events that might still allow the application to continue.
  ///
  /// ```dart
  /// try {
  ///   await fetchData();
  /// } catch (e, stack) {
  ///   Log.e('Failed to fetch data', error: e, stackTrace: stack);
  /// }
  /// ```
  static void e(dynamic message, {Object? error, StackTrace? stackTrace}) =>
      _logger.severe(_format(message), error, stackTrace);

  /// Logs a critical/fatal message.
  ///
  /// Use for severe errors that will likely cause the application to abort.
  ///
  /// ```dart
  /// Log.f('Database connection lost - shutting down');
  /// ```
  static void f(dynamic message) => _logger.shout(_format(message));

  // ══════════════════════════════════════════════════════════════════════════
  // TAG LOGGING SYSTEM
  // ══════════════════════════════════════════════════════════════════════════
  //
  // Tag logging allows grouping related logs across different layers
  // (UI, Controller, Service, Repository) and exporting them as Markdown
  // for AI analysis.
  //
  // Key features:
  // - Zero overhead in release builds (all storage in assert blocks)
  // - Auto stack trace capture for error levels
  // - Conditional export (only when errors occur)
  // - Markdown format optimized for AI analysis
  //
  // ══════════════════════════════════════════════════════════════════════════

  /// Storage for tagged log entries.
  ///
  /// Only populated in debug mode via assert blocks.
  /// In release builds, this map remains empty.
  static final Map<String, List<TaggedEntry>> _tags = {};

  /// Visual separator for exported logs.
  static const _separator =
      '════════════════════════════════════════════════════════════════════════════════';

  /// Logs a message with a tag for grouping and later export.
  ///
  /// Tags allow grouping related logs across different layers (UI, Service,
  /// Repository) and exporting them together for AI analysis.
  ///
  /// The message is stored with the tag AND printed normally.
  /// In release builds, only the normal print occurs (storage is skipped).
  ///
  /// **Auto stack trace:** For error levels (WARNING, SEVERE, SHOUT), the
  /// stack trace is captured automatically if not provided. This helps
  /// identify the exact code location that caused the error.
  ///
  /// Parameters:
  /// - [name]: Tag identifier (e.g., 'auth', 'checkout', 'api')
  /// - [message]: Log message (String, Map, or any object)
  /// - [level]: Log level (default: Level.FINE/DEBUG)
  /// - [error]: Optional error object
  /// - [stackTrace]: Optional stack trace (auto-captured for errors)
  ///
  /// Example:
  /// ```dart
  /// // Simple message
  /// Log.tag('auth', 'User pressed login');
  ///
  /// // With JSON data
  /// Log.tag('auth', {'email': email, 'timestamp': DateTime.now()});
  ///
  /// // With specific level
  /// Log.tag('auth', 'Validating token', level: Level.INFO);
  ///
  /// // Error with auto stack trace
  /// Log.tag('auth', 'Login failed', level: Level.SEVERE, error: e);
  /// ```
  static void tag(
    String name,
    dynamic message, {
    Level level = Level.FINE,
    Object? error,
    StackTrace? stackTrace,
  }) {
    // Single stack capture for both location resolution and error tracking
    final capturedStack = StackTrace.current;

    // Auto-capture stack trace for error levels if not provided
    final effectiveStackTrace =
        stackTrace ??
        (level == Level.WARNING || level == Level.SEVERE || level == Level.SHOUT
            ? capturedStack
            : null);

    // Resolve location once from the captured stack
    final location = LocationResolver.resolve(capturedStack);

    assert(() {
      final formatted = ObjectFormatter.format(message);
      _tags
          .putIfAbsent(name, () => [])
          .add(
            TaggedEntry(
              message: formatted,
              level: _levelName(level),
              location: location.short,
              timestamp: DateTime.now(),
              error: error,
              stackTrace: effectiveStackTrace,
            ),
          );
      return true;
    }());

    // Use pre-resolved location to avoid double stack capture
    _logWithLocation(
      level,
      message,
      location,
      error: error,
      stackTrace: effectiveStackTrace,
    );
  }

  /// Exports a tag's logs to console as Markdown and returns the formatted string.
  ///
  /// Prints the formatted Markdown with visual separators for easy copying.
  /// Copy the output between the separators and paste into Claude or any
  /// AI for analysis.
  ///
  /// Returns the formatted Markdown string (without separators) for custom use,
  /// such as saving to a file. Returns `null` in release mode or if the tag
  /// doesn't exist.
  ///
  /// The tag is cleared after export (or after skipping if export is disabled).
  ///
  /// Parameters:
  /// - [name]: Tag identifier to export
  /// - [export]: If false, skips export entirely (clears tag without printing).
  ///   Use this for custom conditions. Default: true.
  /// - [onlyOnError]: If true, only exports if there are WARNING/ERROR/CRITICAL
  ///   entries. Useful for conditional export in try/catch blocks.
  ///
  /// Example:
  /// ```dart
  /// // Always export and get the string
  /// final markdown = Log.export('auth');
  ///
  /// // Save to file if needed
  /// if (markdown != null) {
  ///   File('debug_log.md').writeAsStringSync(markdown);
  /// }
  ///
  /// // Conditional export based on your own logic
  /// bool shouldExport = myCustomValidation();
  /// Log.export('flow', export: shouldExport);
  ///
  /// // Only export if errors occurred
  /// Log.export('flow', onlyOnError: true);
  ///
  /// // Combine both: custom condition AND must have errors
  /// Log.export('flow', export: isDebugMode, onlyOnError: true);
  /// ```
  static String? export(
    String name, {
    bool export = true,
    bool onlyOnError = false,
  }) {
    String? result;
    assert(() {
      final entries = _tags[name];
      if (entries == null || entries.isEmpty) return true;

      // Skip export if export parameter is false
      if (!export) {
        _tags.remove(name);
        return true;
      }

      // Skip export if onlyOnError is true and no errors exist
      if (onlyOnError) {
        final hasErrors = entries.any((e) => e.isError);
        if (!hasErrors) {
          _tags.remove(name);
          return true;
        }
      }

      final errorCount = entries.where((e) => e.isError).length;
      final content = MdFormatter.format(name, entries);

      // Build full formatted output
      final buffer = StringBuffer()
        ..writeln('# Tag: $name')
        ..writeln(_separator)
        ..writeln(content)
        ..writeln(_separator);
      result = buffer.toString();

      // Announce export via logger
      _logger.info(
        'Exporting tag: $name (${entries.length} entries, $errorCount errors)',
      );

      // Print to console
      // ignore: avoid_print
      print('\n$result');

      _tags.remove(name);
      return true;
    }());
    return result;
  }

  /// Exports all tags to console as Markdown and returns them as a map.
  ///
  /// Each tag is exported separately with its own separators.
  /// Returns a map where keys are tag names and values are the formatted
  /// Markdown strings. Returns empty map in release mode.
  ///
  /// Parameters:
  /// - [export]: If false, clears all tags without exporting. Default: true.
  /// - [onlyOnError]: If true, only exports tags that have errors.
  ///
  /// Example:
  /// ```dart
  /// // Export everything and get results
  /// final logs = Log.exportAll();
  ///
  /// // Save all to files
  /// for (final entry in logs.entries) {
  ///   File('${entry.key}_log.md').writeAsStringSync(entry.value);
  /// }
  ///
  /// // Conditional export
  /// Log.exportAll(export: shouldExportLogs);
  ///
  /// // Only export tags with errors
  /// Log.exportAll(onlyOnError: true);
  /// ```
  static Map<String, String> exportAll({
    bool export = true,
    bool onlyOnError = false,
  }) {
    final results = <String, String>{};
    assert(() {
      for (final name in _tags.keys.toList()) {
        final content = Log.export(
          name,
          export: export,
          onlyOnError: onlyOnError,
        );
        if (content != null) {
          results[name] = content;
        }
      }
      return true;
    }());
    return results;
  }

  /// Clears a tag without exporting.
  ///
  /// Useful for canceling a flow that you don't need to analyze,
  /// or for cleanup after conditional checks.
  ///
  /// Example:
  /// ```dart
  /// Log.tag('temp', 'Some debug info');
  /// // ... decide you don't need it
  /// Log.clear('temp');
  /// ```
  static void clear(String name) {
    assert(() {
      _tags.remove(name);
      return true;
    }());
  }

  /// Clears all tags without exporting.
  ///
  /// Useful for cleanup at application boundaries or test teardown.
  static void clearAll() {
    assert(() {
      _tags.clear();
      return true;
    }());
  }

  /// Checks if a tag has any logged entries.
  ///
  /// Returns `false` in release builds (no entries are ever stored).
  ///
  /// Example:
  /// ```dart
  /// if (Log.hasTag('auth')) {
  ///   Log.export('auth');
  /// }
  /// ```
  static bool hasTag(String name) {
    var result = false;
    assert(() {
      result = _tags.containsKey(name) && _tags[name]!.isNotEmpty;
      return true;
    }());
    return result;
  }

  /// Checks if a tag has any error entries (WARNING/ERROR/CRITICAL).
  ///
  /// Returns `false` in release builds.
  ///
  /// Example:
  /// ```dart
  /// if (Log.hasErrors('auth')) {
  ///   Log.export('auth');
  ///   notifyAdmin();
  /// }
  /// ```
  static bool hasErrors(String name) {
    var result = false;
    assert(() {
      final entries = _tags[name];
      if (entries != null) {
        result = entries.any((e) => e.isError);
      }
      return true;
    }());
    return result;
  }

  /// Gets the count of entries for a tag.
  ///
  /// Returns `0` in release builds.
  ///
  /// Example:
  /// ```dart
  /// Log.d('Auth flow has ${Log.entryCount("auth")} entries');
  /// ```
  static int entryCount(String name) {
    var count = 0;
    assert(() {
      count = _tags[name]?.length ?? 0;
      return true;
    }());
    return count;
  }

  // ══════════════════════════════════════════════════════════════════════════
  // PRIVATE HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  /// Converts a [Level] to a readable name string.
  static String _levelName(Level level) => switch (level) {
    Level.FINEST => 'TRACE',
    Level.FINE => 'DEBUG',
    Level.INFO => 'INFO',
    Level.WARNING => 'WARNING',
    Level.SEVERE => 'ERROR',
    Level.SHOUT => 'CRITICAL',
    _ => 'DEBUG',
  };

  /// Internal: logs with a pre-resolved location to avoid double stack capture.
  ///
  /// Used by [tag] to eliminate redundant StackTrace.current calls.
  static void _logWithLocation(
    Level level,
    dynamic message,
    LocationInfo location, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final formatted = _format(message);
    final record = LogRecord(level, formatted, 'logger_rs', error, stackTrace);
    final output = LogFormatter.format(record, location);
    // ignore: avoid_print
    print(output);
  }
}
