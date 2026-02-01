# Logger RS

[![pub package](https://img.shields.io/pub/v/logger_rs.svg)](https://pub.dev/packages/logger_rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A Rust-style logger for Dart with colored output, precise file locations, and clean formatting inspired by the Rust compiler.

<img width="700" alt="Logger RS Output" src="https://github.com/user-attachments/assets/c2874ef1-af6f-4486-bbff-b3721978131d" />

## Installation

```yaml
dependencies:
  logger_rs: ^2.0.2
```

## Quick Start

```dart
import 'package:logger_rs/logger_rs.dart';

void main() {
  Log.d('Debug message');     // Cyan
  Log.i('Info message');      // Green
  Log.w('Warning message');   // Yellow
  Log.e('Error message');     // Red
  Log.f('Fatal message');     // Magenta
  Log.t('Trace message');     // Gray
}
```

## Log Levels

| Level | Method | Color | Description |
|-------|--------|-------|-------------|
| Trace | `Log.t()` | Gray | Verbose debugging, method entry/exit |
| Debug | `Log.d()` | Cyan | Development information |
| Info | `Log.i()` | Green | General information |
| Warning | `Log.w()` | Yellow | Potential issues |
| Error | `Log.e()` | Red | Errors with optional stack traces |
| Fatal | `Log.f()` | Magenta | Critical failures |

## Error Handling

```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  Log.e('Operation failed', error: error, stackTrace: stackTrace);
}
```

Output:
```
ERROR: Operation failed
  --> src/service.dart:45:12
   |
   = error: SocketException: Connection refused
 1 | #0  Service.call (src/service.dart:45:12)
 2 | #1  App.run (src/app.dart:23:5)
   └─
```

## Logging Objects

Maps and objects are automatically formatted as JSON:

```dart
Log.i({'user': 'john', 'action': 'login'});
```

Output:
```
INFO: src/auth.dart:15:3
   |
   ┌─
{
  "user": "john",
  "action": "login"
}
   └─
```

## Tag Logging (Advanced)

Group related logs across your application and export them for debugging or AI analysis.

### Basic Usage

```dart
// Tag logs throughout your code
Log.tag('auth', 'User pressed login');
Log.tag('auth', 'Validating credentials', level: Level.INFO);
Log.tag('auth', {'email': 'user@example.com'});

// Export when needed
Log.export('auth');
```

### Conditional Export

```dart
// Export only if errors occurred
Log.export('auth', onlyOnError: true);

// Export based on custom condition
Log.export('auth', export: isDebugMode);
```

### Tag API

| Method | Description |
|--------|-------------|
| `Log.tag(name, msg)` | Add log to tag |
| `Log.tag(name, msg, level: Level.SEVERE)` | Add with specific level |
| `Log.export(name)` | Export tag to console |
| `Log.export(name, onlyOnError: true)` | Export only if errors exist |
| `Log.exportAll()` | Export all tags |
| `Log.clear(name)` | Clear tag without exporting |
| `Log.clearAll()` | Clear all tags |
| `Log.hasTag(name)` | Check if tag exists |
| `Log.hasErrors(name)` | Check if tag has errors |
| `Log.entryCount(name)` | Get entry count |

Tags are automatically removed in release builds (zero overhead).

## Platform Support

Works on all Dart platforms with automatic color support:

- Flutter (iOS, Android, Web, Desktop)
- Dart VM / Native
- Web (WASM compatible)

## Performance

| Operation | Time |
|-----------|------|
| Simple log | ~17μs |
| Map/JSON log | ~24μs |
| Error with stack | ~27μs |

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**JhonaCode** - [@JhonaCodes](https://github.com/JhonaCodes)
