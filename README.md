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

## Output Examples

### Simple Messages

```
TRACE: Entering function src/service.dart:10:3

DEBUG: Processing request src/controller.dart:25:5

INFO: Server started on port 8080 src/main.dart:15:3

WARNING: Deprecated API usage
  --> src/legacy.dart:67:9
   |
   └─

ERROR: Connection failed
  --> src/database.dart:45:12
   |
   └─

CRITICAL: System out of memory
  --> src/core.dart:112:7
   |
   └─
```

### With Error and Stack Trace

```dart
try {
  await riskyOperation();
} catch (error, stackTrace) {
  Log.e('Operation failed', error: error, stackTrace: stackTrace);
}
```

```
ERROR: Operation failed
  --> src/service.dart:45:12
   |
   = error: SocketException: Connection refused
 1 | #0  Service.call (src/service.dart:45:12)
 2 | #1  App.run (src/app.dart:23:5)
   └─
```

### With Objects (JSON)

```dart
Log.i({'user': 'john', 'action': 'login'});
```

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

### Export Output

When you call `Log.export('auth')`, the output is Markdown formatted for AI analysis:

```
# Tag: auth
════════════════════════════════════════════════════════════════════════════════
> **Tag:** `auth`
> **Generated:** 2024-01-30 12:30:45
> **Entries:** 4 | **Errors:** 1

## Summary
- **ERROR**: 1
- **INFO**: 2
- **DEBUG**: 1

## Timeline

### 12:30:45.001 🔵 [DEBUG] auth_page.dart:23:7
User pressed login

### 12:30:45.015 🟢 [INFO] auth_controller.dart:45:9
Validating credentials

### 12:30:45.050 🔵 [DEBUG] auth_service.dart:32:7
```json
{
  "email": "user@example.com"
}
```

### 12:30:46.200 🔴 [ERROR] auth_controller.dart:52:11
Login failed: Invalid credentials

<details>
<summary>Stack Trace</summary>

```dart
#0  AuthService.authenticate (auth_service.dart:45:5)
#1  AuthController.login (auth_controller.dart:52:11)
```

</details>

---
*Exported by logger_rs*

════════════════════════════

Copy the content between the separators and paste it into llm.

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

## License

MIT License - see [LICENSE](LICENSE) for details.

## Author

**JhonaCode** - [@JhonaCodes](https://github.com/JhonaCodes)
