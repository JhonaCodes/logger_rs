/// Represents a single tagged log entry for export.
///
/// Used internally by the tag logging system to store log entries
/// before exporting to Markdown format for AI analysis.
///
/// Each entry captures:
/// - The formatted message content
/// - Log level (TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL)
/// - Source code location
/// - Timestamp
/// - Optional error and stack trace
///
/// Example:
/// ```dart
/// final entry = TaggedEntry(
///   message: 'User login failed',
///   level: 'ERROR',
///   location: 'auth_service.dart:45:12',
///   timestamp: DateTime.now(),
///   error: Exception('Invalid credentials'),
/// );
/// ```
class TaggedEntry {
  /// The formatted log message.
  ///
  /// For Map objects, this contains the JSON-formatted string.
  /// For other types, this is the string representation.
  final String message;

  /// Log level name.
  ///
  /// One of: TRACE, DEBUG, INFO, WARNING, ERROR, CRITICAL.
  final String level;

  /// Source location in format `file:line:column`.
  ///
  /// Example: `auth_service.dart:45:12`
  final String location;

  /// Timestamp when the log was recorded.
  final DateTime timestamp;

  /// Optional error object associated with this entry.
  ///
  /// Typically an [Exception] or [Error] instance.
  final Object? error;

  /// Optional stack trace associated with this entry.
  ///
  /// Automatically captured for WARNING, ERROR, and CRITICAL levels
  /// if not explicitly provided.
  final StackTrace? stackTrace;

  /// Creates a new tagged entry.
  const TaggedEntry({
    required this.message,
    required this.level,
    required this.location,
    required this.timestamp,
    this.error,
    this.stackTrace,
  });

  /// Whether this entry represents an error condition.
  ///
  /// Returns `true` for WARNING, ERROR, and CRITICAL levels.
  /// Used by [Log.export] with `onlyOnError: true` to determine
  /// whether to export a tag.
  bool get isError =>
      level == 'WARNING' || level == 'ERROR' || level == 'CRITICAL';
}
