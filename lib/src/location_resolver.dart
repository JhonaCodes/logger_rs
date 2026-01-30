/// Resolves caller location from stack trace.
///
/// Extracts file path, line number, and column from the current stack trace,
/// filtering out internal logging infrastructure to show the actual caller.
///
/// Supports two stack trace formats:
/// - Package: `package:app/src/file.dart:42:10`
/// - File: `file:///path/to/file.dart:42:10`
abstract final class LocationResolver {
  /// Regex for package format stack traces.
  static final RegExp _packagePattern = RegExp(
    r'package:([^/]+)/(.+\.dart):(\d+):(\d+)',
  );

  /// Regex for file format stack traces.
  static final RegExp _filePattern = RegExp(r'file:///(.+\.dart):(\d+):(\d+)');

  // Note: _ignoredPatterns list removed - now using inline checks
  // for better performance with early returns (see _shouldIgnoreLine)

  /// Resolves the caller location from the current stack trace.
  ///
  /// Returns a [LocationInfo] with the short location and full path.
  static LocationInfo resolve(StackTrace stackTrace) {
    final lines = stackTrace.toString().split('\n');

    for (final line in lines) {
      if (_shouldIgnoreLine(line)) continue;

      final location = _tryPackageFormat(line) ?? _tryFileFormat(line);
      if (location != null) return location;
    }

    return const LocationInfo('unknown location', '');
  }

  /// Returns true if line matches any ignored pattern.
  ///
  /// Uses early returns with patterns ordered by frequency for performance.
  /// Avoids closure allocation from List.any().
  static bool _shouldIgnoreLine(String line) {
    // Most frequent patterns first (order by probability)
    if (line.contains('Logger.')) return true;
    if (line.contains('log.dart')) return true;
    if (line.contains('zone.dart')) return true;
    if (line.contains('logging.dart')) return true;
    if (line.contains('location_resolver.dart')) return true;
    if (line.contains('log_formatter.dart')) return true;
    if (line.contains('logger_rs_base.dart')) return true;
    if (line.contains('stack_trace/')) return true;
    return false;
  }

  /// Tries to parse package format: `package:name/path.dart:line:col`
  static LocationInfo? _tryPackageFormat(String line) {
    final match = _packagePattern.firstMatch(line);
    if (match == null) return null;

    final packageName = match.group(1)!;
    final filePath = match.group(2)!;
    final lineNum = match.group(3)!;
    final colNum = match.group(4)!;

    final location = packageName == 'logger_rs'
        ? 'lib/$filePath:$lineNum:$colNum'
        : 'package:$packageName/$filePath:$lineNum:$colNum';

    return LocationInfo(location, location);
  }

  /// Tries to parse file format: `file:///path/file.dart:line:col`
  static LocationInfo? _tryFileFormat(String line) {
    final match = _filePattern.firstMatch(line);
    if (match == null) return null;

    final fullPath = match.group(1)!;
    final lineNum = match.group(2)!;
    final colNum = match.group(3)!;
    final parts = fullPath.split('/');

    final shortLocation = parts.length > 2
        ? '${parts[parts.length - 2]}/${parts.last}:$lineNum:$colNum'
        : '${parts.last}:$lineNum:$colNum';

    return LocationInfo(shortLocation, fullPath);
  }
}

/// Contains resolved location information.
///
/// Holds both a compact [short] location for display
/// and the [full] path when available.
class LocationInfo {
  /// Compact location: `path/file.dart:line:col`
  final String short;

  /// Full path when available.
  final String full;

  const LocationInfo(this.short, this.full);

  /// True if [full] provides additional info beyond [short].
  bool get hasDifferentFullPath => full.isNotEmpty && full != short;
}
