/// Resolves caller location from stack trace.
///
/// Extracts file path and line number from the current stack trace,
/// filtering out internal logging infrastructure.
abstract final class LocationResolver {
  static final RegExp _packagePattern = RegExp(
    r'package:([^/]+)/(.+\.dart):(\d+):(\d+)',
  );
  static final RegExp _filePattern = RegExp(
    r'file:///(.+\.dart):(\d+):(\d+)',
  );

  static const List<String> _ignoredPatterns = [
    'logger_rs_base.dart',
    'log.dart',
    'log_formatter.dart',
    'location_resolver.dart',
    'logging.dart',
    'zone.dart',
    'stack_trace/',
    'Logger.',
  ];

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

  static bool _shouldIgnoreLine(String line) {
    return _ignoredPatterns.any((pattern) => line.contains(pattern));
  }

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
class LocationInfo {
  final String short;
  final String full;

  const LocationInfo(this.short, this.full);

  bool get hasDifferentFullPath => full.isNotEmpty && full != short;
}
