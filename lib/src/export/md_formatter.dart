import 'tagged_entry.dart';

/// Formats tagged log entries to Markdown for AI analysis.
///
/// Generates clean, readable Markdown without ANSI color codes,
/// optimized for analysis by AI systems like Claude.
///
/// The output format includes:
/// - Metadata header with tag name, timestamp, and counts
/// - Summary section with entry counts by level
/// - Timeline section with all entries in chronological order
/// - Collapsible stack traces for error entries
///
/// Example output:
/// ```markdown
/// > **Tag:** `auth`
/// > **Generated:** 2024-01-30 12:30:45
/// > **Entries:** 5 | **Errors:** 1
///
/// ## Summary
/// - **ERROR**: 1
/// - **INFO**: 2
/// - **DEBUG**: 2
///
/// ## Timeline
/// ### 12:30:45.001 [INFO] auth_service.dart:23
/// User login attempt
/// ```
abstract final class MdFormatter {
  /// Formats a list of tagged entries to Markdown.
  ///
  /// Returns a complete Markdown document optimized for AI analysis.
  ///
  /// Parameters:
  /// - [tag]: The tag name (used in metadata header)
  /// - [entries]: List of [TaggedEntry] objects to format
  ///
  /// The output includes:
  /// - Metadata with tag name, generation time, and entry/error counts
  /// - Summary showing count breakdown by log level
  /// - Timeline with all entries, including JSON formatting for Maps
  /// - Collapsible stack traces using HTML details tags
  static String format(String tag, List<TaggedEntry> entries) {
    final buffer = StringBuffer();
    final now = DateTime.now();
    final errorCount = entries.where((e) => e.isError).length;

    _writeMetadata(buffer, tag, now, entries.length, errorCount);
    _writeSummary(buffer, entries);
    _writeTimeline(buffer, entries);
    _writeFooter(buffer);

    return buffer.toString();
  }

  /// Writes the metadata header section.
  static void _writeMetadata(
    StringBuffer buffer,
    String tag,
    DateTime now,
    int entryCount,
    int errorCount,
  ) {
    buffer.writeln('> **Tag:** `$tag`');
    buffer.writeln('> **Generated:** ${_formatDateTime(now)}');
    buffer.writeln('> **Entries:** $entryCount | **Errors:** $errorCount');
    buffer.writeln();
  }

  /// Writes the summary section with counts by level.
  static void _writeSummary(StringBuffer buffer, List<TaggedEntry> entries) {
    buffer.writeln('## Summary');
    buffer.writeln();

    final levelCounts = _countByLevel(entries);
    for (final entry in levelCounts.entries) {
      buffer.writeln('- **${entry.key}**: ${entry.value}');
    }
    buffer.writeln();
  }

  /// Writes the timeline section with all entries.
  static void _writeTimeline(StringBuffer buffer, List<TaggedEntry> entries) {
    buffer.writeln('## Timeline');
    buffer.writeln();

    for (final entry in entries) {
      _writeEntry(buffer, entry);
    }
  }

  /// Writes the footer section.
  static void _writeFooter(StringBuffer buffer) {
    buffer.writeln('---');
    buffer.writeln('*Exported by logger_rs*');
  }

  /// Formats a single entry to the buffer.
  static void _writeEntry(StringBuffer buffer, TaggedEntry entry) {
    final time = _formatTime(entry.timestamp);
    final icon = _levelIcon(entry.level);

    // Entry header with timestamp, level icon, level name, and location
    buffer.writeln('### $time $icon [${entry.level}] ${entry.location}');
    buffer.writeln();

    // Message content (JSON formatted if applicable)
    _writeMessage(buffer, entry.message);

    // Error object if present
    if (entry.error != null) {
      buffer.writeln();
      buffer.writeln('**Error:** `${entry.error}`');
    }

    // Stack trace if present (collapsible)
    if (entry.stackTrace != null) {
      _writeStackTrace(buffer, entry.stackTrace!);
    }

    buffer.writeln();
  }

  /// Writes the message content, detecting JSON format.
  static void _writeMessage(StringBuffer buffer, String message) {
    final trimmed = message.trim();

    // Detect JSON content (starts with { or [)
    if (trimmed.startsWith('{') || trimmed.startsWith('[')) {
      buffer.writeln('```json');
      buffer.writeln(trimmed);
      buffer.writeln('```');
    } else {
      buffer.writeln(trimmed);
    }
  }

  /// Writes a collapsible stack trace section.
  ///
  /// Uses HTML details/summary tags for collapsible content.
  /// The stack trace is formatted as a dart code block.
  static void _writeStackTrace(StringBuffer buffer, StackTrace stackTrace) {
    buffer.writeln();
    buffer.writeln('<details>');
    buffer.writeln('<summary>Stack Trace</summary>');
    buffer.writeln();
    buffer.writeln('```dart');
    buffer.writeln(stackTrace.toString().trim());
    buffer.writeln('```');
    buffer.writeln();
    buffer.writeln('</details>');
  }

  /// Counts entries by level, sorted by severity (highest first).
  static Map<String, int> _countByLevel(List<TaggedEntry> entries) {
    final counts = <String, int>{};

    for (final entry in entries) {
      counts[entry.level] = (counts[entry.level] ?? 0) + 1;
    }

    // Sort by severity (highest first)
    const severityOrder = [
      'CRITICAL',
      'ERROR',
      'WARNING',
      'INFO',
      'DEBUG',
      'TRACE',
    ];

    final sorted = <String, int>{};
    for (final level in severityOrder) {
      if (counts.containsKey(level)) {
        sorted[level] = counts[level]!;
      }
    }

    return sorted;
  }

  /// Returns an emoji icon for the given log level.
  static String _levelIcon(String level) => switch (level) {
    'CRITICAL' => '🔴',
    'ERROR' => '🔴',
    'WARNING' => '🟡',
    'INFO' => '🟢',
    'DEBUG' => '🔵',
    'TRACE' => '⚪',
    _ => '⚪',
  };

  /// Formats a DateTime as `YYYY-MM-DD HH:MM:SS`.
  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${_pad(dt.month)}-${_pad(dt.day)} '
        '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}';
  }

  /// Formats a DateTime as `HH:MM:SS.mmm` for timeline entries.
  static String _formatTime(DateTime dt) {
    return '${_pad(dt.hour)}:${_pad(dt.minute)}:${_pad(dt.second)}.'
        '${dt.millisecond.toString().padLeft(3, '0')}';
  }

  /// Pads a number to 2 digits with leading zero.
  static String _pad(int n) => n.toString().padLeft(2, '0');
}
