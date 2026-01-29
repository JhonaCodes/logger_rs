import 'dart:convert';

/// Formats objects for readable log output.
///
/// Converts Maps to pretty-printed JSON format.
/// Lists are shown inline for readability.
abstract final class ObjectFormatter {
  static const JsonEncoder _encoder = JsonEncoder.withIndent('  ');

  /// Formats a message for logging.
  ///
  /// If the message is a Map, returns pretty-printed JSON.
  /// Lists and other types return their string representation.
  static String format(dynamic message) {
    if (message is Map) {
      try {
        return _encoder.convert(message);
      } catch (_) {
        return message.toString();
      }
    }
    return message.toString();
  }
}
