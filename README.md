# Logger RS

[![pub package](https://img.shields.io/pub/v/logger_rs.svg)](https://pub.dev/packages/logger_rs)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A beautiful Rust-style logger for Dart with colored output, precise file locations, tag-based logging for AI analysis, and clean formatting inspired by the Rust compiler.

## Features

- 🎨 **Beautiful colored output** - Different colors for each log level
- 📍 **Precise location tracking** - Shows exact file, line, and column
- 🦀 **Rust-inspired formatting** - Clean and readable output format
- 🤖 **AI-ready tag logging** - Export logs as Markdown for AI analysis
- 🚀 **High performance** - Minimal overhead for production apps
- 📝 **Multiple log levels** - Debug, Info, Warning, Error, Critical, Trace
- 🔧 **Zero configuration** - Works out of the box
- 💻 **Cross-platform** - Supports all Dart platforms
- ⚡ **Zero overhead in release** - Tag code completely removed by compiler in production

## Screenshots

<img width="700" height="400" alt="Screenshot 2025-08-15 at 12 32 02 AM" src="https://github.com/user-attachments/assets/c2874ef1-af6f-4486-bbff-b3721978131d" />

## Installation

Add `logger_rs` to your `pubspec.yaml`:

```yaml
dependencies:
  logger_rs: ^2.0.0
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

## Tag Logging for AI Analysis

Tag logging allows you to group related logs across different layers (UI, Service, Repository) and export them as Markdown for AI analysis.

### Basic Tag Usage

```dart
// Tag logs across your application layers
Log.tag('auth', 'User pressed login button');           // UI
Log.tag('auth', 'Validating credentials');              // Service
Log.tag('auth', {'email': 'user@example.com'});         // With JSON data
Log.tag('auth', 'Query executed', level: Level.INFO);   // With level

// Export to console when ready
Log.export('auth');
```

### Auto Stack Trace Capture

For error levels (WARNING, ERROR, CRITICAL), the stack trace is captured automatically:

```dart
// No need to pass StackTrace.current - it's automatic!
Log.tag('payment', 'Payment failed', level: Level.SEVERE);
```

### Conditional Export

Control when to export based on your own logic:

```dart
// Export based on custom condition
bool shouldExport = myValidation();
Log.export('flow', export: shouldExport);

// Only export when errors occur
Log.export('order', onlyOnError: true);

// Combine both: your condition AND must have errors
Log.export('debug', export: isDebugMode, onlyOnError: true);
```

Example with error handling:

```dart
try {
  await processOrder();
  Log.export('order', onlyOnError: true);  // Won't export if no errors
} catch (e) {
  Log.tag('order', 'Failed: $e', level: Level.SEVERE);
  Log.export('order', onlyOnError: true);  // Will export with full trace
}
```

### Real-World Example

```dart
// auth_page.dart (UI Layer)
void onLoginPressed() {
  Log.tag('auth', 'User tapped login');
  Log.tag('auth', {'screen': 'LoginPage', 'action': 'submit'});
  authController.login(email, password);
}

// auth_controller.dart (Controller Layer)
Future<void> login(String email, String password) async {
  Log.tag('auth', 'Starting authentication', level: Level.INFO);
  try {
    final user = await authService.authenticate(email, password);
    Log.tag('auth', 'Login successful', level: Level.INFO);
    Log.export('auth', onlyOnError: true);  // Won't export - no errors
  } catch (e) {
    Log.tag('auth', 'Login failed: $e', level: Level.SEVERE);
    Log.export('auth');  // Exports full flow for debugging
  }
}

// auth_service.dart (Service Layer)
Future<User> authenticate(String email, String password) async {
  Log.tag('auth', {'validating': email});
  // ... authentication logic
}
```

### Exported Markdown Format

When you call `Log.export('auth')`, the output looks like:

```
# Tag: auth
════════════════════════════════════════════════════════════════════════════════
> **Tag:** `auth`
> **Generated:** 2024-01-30 12:30:45
> **Entries:** 5 | **Errors:** 1

## Summary
- **ERROR**: 1
- **INFO**: 2
- **DEBUG**: 2

## Timeline

### 12:30:45.001 🔵 [DEBUG] auth_page.dart:23:7
User tapped login

### 12:30:45.015 🟢 [INFO] auth_controller.dart:45:9
Starting authentication

### 12:30:45.050 🔵 [DEBUG] auth_service.dart:32:7
```json
{
  "validating": "user@example.com"
}
```

### 12:30:46.200 🔴 [ERROR] auth_controller.dart:52:11
Login failed: AuthException: Invalid credentials

**Error:** `AuthException: Invalid credentials`

<details>
<summary>Stack Trace</summary>

```dart
#0      AuthService.authenticate (auth_service.dart:45:5)
#1      AuthController.login (auth_controller.dart:52:11)
#2      LoginPage.onLoginPressed (auth_page.dart:28:5)
```

</details>

---
*Exported by logger_rs*
════════════════════════════════════════════════════════════════════════════════
```

Copy the content between the separators and paste it into Claude or ChatGPT for analysis!

### Tag API Reference

| Method | Description |
|--------|-------------|
| `Log.tag(name, msg)` | Log with tag (also prints normally) |
| `Log.tag(name, msg, level: Level.SEVERE)` | With specific level |
| `Log.export(name)` | Export tag to console |
| `Log.export(name, export: false)` | Skip export, just clear the tag |
| `Log.export(name, export: condition)` | Export based on custom condition |
| `Log.export(name, onlyOnError: true)` | Export only if errors exist |
| `Log.exportAll()` | Export all tags |
| `Log.exportAll(export: condition)` | Export all based on condition |
| `Log.clear(name)` | Clear tag without exporting |
| `Log.clearAll()` | Clear all tags |
| `Log.hasTag(name)` | Check if tag exists |
| `Log.hasErrors(name)` | Check if tag has errors |
| `Log.entryCount(name)` | Get entry count |

## Output Examples

Each log level has a distinct visual style inspired by Rust's compiler output:

### Trace Level (Gray - Most Verbose)
```
TRACE: Entering processData function src/service.dart:42:5
```

### Debug Level (Cyan)
```
DEBUG: Processing user request src/controller.dart:28:7
```

### Info Level (Green)
```
INFO: Server started on port 8080 src/main.dart:15:3
```

For multiline content:
```
INFO: src/config.dart:23:5
   |
   ┌─
{
  "host": "localhost",
  "port": 8080,
  "debug": true
}
   └─
```

### Warning Level (Yellow)
```
WARNING: Deprecated API usage detected
  --> src/legacy.dart:67:9
   |
   └─
```

### Error Level (Red)
```
ERROR: Database connection failed
  --> src/database.dart:45:12
   |
   = error: SocketException: Connection refused
 1 | #0      Database.connect (src/database.dart:45:12)
 2 | #1      App.initialize (src/app.dart:23:5)
 3 | #2      main (src/main.dart:10:3)
   └─
```

### Critical Level (Magenta)
```
CRITICAL: System out of memory
  --> src/core.dart:112:7
   |
   = critical: System requires immediate attention
   = help: Check system logs and restart if necessary
   └─
```

### JSON Objects (Pretty Printed)
```
DEBUG: src/api.dart:34:5
   |
   ┌─
{
  "userId": 123,
  "action": "login",
  "timestamp": "2024-01-30T12:30:45Z"
}
   └─
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
- ✅ Web (with WASM compatibility)

Color output is automatically enabled on all platforms including Web.

## Performance

Logger RS is optimized for high-performance logging:

### Benchmarks

| Operation | Time | Throughput |
|-----------|------|------------|
| Simple log | ~17μs | ~58,000 ops/sec |
| Map/JSON log | ~24μs | ~41,000 ops/sec |
| Error with stack | ~27μs | ~37,000 ops/sec |
| Export 500 entries | ~4ms | - |

### Optimizations

- **Early return pattern** - Stack trace filtering uses ordered checks with early exits
- **Single stack capture** - Tagged logs capture `StackTrace.current` once, not twice
- **Fast path for simple Maps** - Small maps bypass JSON encoder overhead
- **Pre-compiled patterns** - RegExp patterns are static final, compiled once
- **Zero allocation in hot paths** - Avoids closure allocation in loops

### Release Mode

Tag storage uses `assert()` blocks, meaning the compiler **completely removes** the tag storage code in release builds - zero memory usage, zero CPU overhead for tag features.

## Advanced Features

### Custom Object Logging

Logger RS automatically converts objects to formatted JSON:

```dart
final user = {'name': 'John', 'age': 30, 'roles': ['admin', 'user']};
Log.i(user);
// Output: Pretty-printed JSON

final list = [1, 2, 3, 'four'];
Log.d(list);
```

## Why Logger RS?

### Comparison with Other Loggers

| Feature | Logger RS | logger | logging |
|---------|-----------|--------|---------|
| Rust-style output | ✅ | ❌ | ❌ |
| Colored output | ✅ | ✅ | ❌ |
| Precise location | ✅ | ⚠️ | ⚠️ |
| Tag logging | ✅ | ❌ | ❌ |
| AI export | ✅ | ❌ | ❌ |
| Zero config | ✅ | ❌ | ⚠️ |
| Stack traces | ✅ | ✅ | ✅ |

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
