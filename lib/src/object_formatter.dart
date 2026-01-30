import 'dart:convert';

/// Formats objects for readable log output.
///
/// Converts Maps to pretty-printed JSON format.
/// Lists are shown inline for readability.
abstract final class ObjectFormatter {
  /// Pre-compiled JSON encoder for complex objects.
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Threshold for fast path formatting (small maps without nesting).
  static const int _fastPathThreshold = 3;

  /// Formats a message for logging.
  ///
  /// If the message is a Map, returns pretty-printed JSON.
  /// Uses a fast path for small, flat maps to avoid encoder overhead.
  /// Lists and other types return their string representation.
  static String format(dynamic message) {
    if (message is Map) {
      return _formatMap(message);
    }
    return message.toString();
  }

  /// Formats a map, using fast path for simple maps.
  static String _formatMap(Map<dynamic, dynamic> map) {
    // Fast path: small maps without nested structures
    if (map.length <= _fastPathThreshold && _isSimpleMap(map)) {
      return _formatSimpleMap(map);
    }

    // Standard path: use JSON encoder for complex maps
    try {
      return _encoder.convert(map);
    } catch (_) {
      return map.toString();
    }
  }

  /// Returns true if map has no nested Maps or Lists.
  static bool _isSimpleMap(Map<dynamic, dynamic> map) {
    for (final value in map.values) {
      if (value is Map || value is List) return false;
    }
    return true;
  }

  /// Formats a simple map without using the JSON encoder.
  static String _formatSimpleMap(Map<dynamic, dynamic> map) {
    if (map.isEmpty) return '{}';

    final buffer = StringBuffer('{\n');
    final entries = map.entries.toList();

    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final key = entry.key;
      final value = entry.value;
      final comma = i < entries.length - 1 ? ',' : '';

      buffer.write('  ');
      buffer.write(_formatKey(key));
      buffer.write(': ');
      buffer.write(_formatValue(value));
      buffer.writeln(comma);
    }

    buffer.write('}');
    return buffer.toString();
  }

  /// Formats a map key.
  static String _formatKey(dynamic key) {
    if (key is String) return '"$key"';
    return '"$key"';
  }

  /// Formats a simple value (not Map or List).
  static String _formatValue(dynamic value) {
    if (value == null) return 'null';
    if (value is String) return '"${_escapeString(value)}"';
    if (value is num || value is bool) return value.toString();
    return '"$value"';
  }

  /// Escapes special characters in strings.
  static String _escapeString(String s) {
    return s
        .replaceAll('\\', '\\\\')
        .replaceAll('"', '\\"')
        .replaceAll('\n', '\\n')
        .replaceAll('\r', '\\r')
        .replaceAll('\t', '\\t');
  }
}
