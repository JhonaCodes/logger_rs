/// ANSI color codes for terminal output.
///
/// Provides Rust-style colors with normal and dim variants.
abstract final class AnsiColors {
  static const String reset = '\x1B[0m';
  static const String bold = '\x1B[1m';
  static const String dim = '\x1B[2m';

  // Red
  static const String red = '\x1B[31m';
  static const String redDim = '\x1B[2m\x1B[31m';

  // Yellow
  static const String yellow = '\x1B[33m';
  static const String yellowDim = '\x1B[2m\x1B[33m';

  // Green
  static const String green = '\x1B[32m';
  static const String greenDim = '\x1B[2m\x1B[32m';

  // Cyan
  static const String cyan = '\x1B[36m';
  static const String cyanDim = '\x1B[2m\x1B[36m';

  // Magenta
  static const String magenta = '\x1B[35m';
  static const String magentaDim = '\x1B[2m\x1B[35m';

  // Gray
  static const String gray = '\x1B[90m';
}
