# Logger RS

[![pub package](https://img.shields.io/pub/v/logger_rs.svg)](https://pub.dev/packages/logger_rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful Rust-style logger for Dart with colored output, precise file locations, and clean formatting inspired by the Rust compiler.

## Features

- 🎨 **Beautiful colored output** - Different colors for each log level
- 📍 **Precise location tracking** - Shows exact file, line, and column
- 🦀 **Rust-inspired formatting** - Clean and readable output format
- 🚀 **High performance** - Minimal overhead for production apps
- 📝 **Multiple log levels** - Debug, Info, Warning, Error, Critical, Trace
- 🔧 **Zero configuration** - Works out of the box
- 💻 **Cross-platform** - Supports all Dart platforms

## Screenshots
<img width="700" height="400" alt="Screenshot 2025-08-15 at 12 32 02 AM" src="https://github.com/user-attachments/assets/c2874ef1-af6f-4486-bbff-b3721978131d" />

## Installation

Add `logger_rs` to your `pubspec.yaml`:

```yaml
dependencies:
  logger_rs: ^1.0.1
```

Then run:

```bash
dart pub get
```

## Usage

### Basic Usage

```dart
import 'package:logger_rs/logger_rs.dart';

void main() {
  // Debug message
  Log.d('Application started');
  
  // Info message
  Log.i('Server connected successfully');
  
  // Warning message
  Log.w('Low memory detected');
  
  // Error message
  Log.e('Failed to load configuration');
  
  // Critical/Fatal message
  Log.f('Critical system failure');
  
  // Trace message (most verbose)
  Log.t('Entering function X');
}
```

### Error Handling with Stack Traces

```dart
try {
  // Some risky operation
  await riskyOperation();
} catch (error, stackTrace) {
  Log.e('Operation failed', error: error, stackTrace: stackTrace);
}
```

### Output Examples

#### Info Level
```
INFO: Server connected successfully package:example/main.dart:15:7
```

#### Warning Level
```
warning: Deprecated API usage detected
  --> package:example/main.dart:23:5
   |
```

#### Error Level with Stack Trace
```
ERROR: Database connection failed
  --> package:example/database.dart:45:12
   |
   = error: SocketException: Connection refused
 1 | #0      DatabaseConnection.connect (package:example/database.dart:45:12)
 2 | #1      main (package:example/main.dart:10:5)
   |
```

#### Critical Level
```
CRITICAL: System memory exhausted
  --> package:example/memory_manager.dart:89:3
   |
   = critical: System requires immediate attention
   = help: Check system logs and restart if necessary
```

## Log Levels

| Level | Method | Color | Use Case |
|-------|--------|-------|----------|
| Trace | `Log.t()` | Gray | Most verbose logging, method entry/exit |
| Debug | `Log.d()` | Cyan | Development and debugging information |
| Info | `Log.i()` | Green | General information messages |
| Warning | `Log.w()` | Yellow | Potentially harmful situations |
| Error | `Log.e()` | Red | Error events with optional stack traces |
| Critical | `Log.f()` | Magenta | Fatal errors requiring immediate attention |

## Platform Support

Logger RS works on all Dart platforms:

- ✅ Flutter (iOS, Android, Web, Desktop)
- ✅ Dart VM
- ✅ Dart Native

Color output is automatically enabled on platforms that support ANSI colors (macOS, Linux, and most terminals). On other platforms, the logger falls back to plain text output.

## Advanced Features

### Custom Object Logging

Logger RS automatically converts objects to strings:

```dart
final user = {'name': 'John', 'age': 30};
Log.i(user); // Output: INFO: {name: John, age: 30}

final list = [1, 2, 3, 'four'];
Log.d(list); // Output: DEBUG: [1, 2, 3, four]
```

### Performance

Logger RS is designed for minimal overhead:

```dart
// Logs 100 messages in < 50ms
for (int i = 0; i < 100; i++) {
  Log.d('Performance test log #$i');
}
```

## Configuration

Logger RS works out of the box with zero configuration. The logger automatically:

- Detects the platform and enables/disables colors accordingly
- Extracts caller information from stack traces
- Formats output in a clean, readable manner
- Handles multi-line messages properly

## Why Logger RS?

### Comparison with Other Loggers

| Feature | Logger RS | logger | logging |
|---------|-----------|--------|---------|
| Rust-style output | ✅ | ❌ | ❌ |
| Colored output | ✅ | ✅ | ❌ |
| Precise location | ✅ | ⚠️ | ⚠️ |
| Zero config | ✅ | ❌ | ⚠️ |
| Stack traces | ✅ | ✅ | ✅ |
| Performance | 🚀 | 🚀 | 🚀 |

### Design Philosophy

Logger RS is inspired by the Rust compiler's error messages, which are known for being:

1. **Clear and readable** - Information is well-structured
2. **Helpful** - Provides context and suggestions
3. **Beautiful** - Uses colors and formatting effectively
4. **Precise** - Shows exact locations of issues

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

**JhonaCode**

- GitHub: [@JhonaCodes](https://github.com/JhonaCodes)

## Support

If you find this package useful, please consider giving it a star on [GitHub](https://github.com/JhonaCodes/logger_rs) and a like on [pub.dev](https://pub.dev/packages/logger_rs).

For issues and feature requests, please use the [GitHub issue tracker](https://github.com/JhonaCodes/logger_rs/issues).

---

Made with ❤️ by JhonaCode
