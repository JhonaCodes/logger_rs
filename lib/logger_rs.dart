/// A beautiful Rust-style logger for Dart.
///
/// Logger RS provides a clean, colorful logging experience inspired by
/// the Rust compiler's output format. It features precise location tracking,
/// multiple log levels, and zero-configuration setup.
///
/// Example usage:
/// ```dart
/// import 'package:logger_rs/logger_rs.dart';
///
/// void main() {
///   Log.i('Application started');
///   Log.w('This is a warning');
///   Log.e('An error occurred', error: exception);
/// }
/// ```
library;

export 'src/log.dart' show Log;
