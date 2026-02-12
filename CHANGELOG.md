# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2026-02-13

### Added
- **`Log.init(level:)`** - Configure the log level at startup. Use `Level.OFF` to silence all logs in production, `Level.SEVERE` to show only errors, or `Level.ALL` (default) for full output. If not called, behavior is unchanged (all levels printed).

---

## [2.0.3] - 2026-02-01

### Added
- **`Log.export()` now returns `String?`** - Returns the formatted Markdown for custom use (saving to files, etc.)
- **`Log.exportAll()` now returns `Map<String, String>`** - Returns all exported tags as a map

### Changed
- New "Save to File" section in README documenting the return values

---

## [2.0.2] - 2026-02-01

### Changed
- **Complete README rewrite** - Cleaner, more concise documentation
- Reorganized structure: Quick Start first, advanced features later
- Added output examples for all log levels
- Added export output example showing the Markdown format

---

## [2.0.1] - 2026-01-30

### Added

- **`Log.export(name, export: bool)`** - New parameter to conditionally enable/disable export based on custom logic
- **`Log.exportAll(export: bool)`** - Same parameter for batch export

### Performance Optimizations

Major performance improvements reducing log operation time by ~40-50%:

#### LocationResolver Optimizations
- **Early return pattern** in `_shouldIgnoreLine()` - Replaced `List.any()` with inline checks and early returns
- **Pattern ordering by frequency** - Most common patterns checked first for faster short-circuiting
- **Eliminated closure allocation** - Removes per-call closure creation overhead

#### Single StackTrace Capture
- **`Log.tag()` now captures stack once** - Eliminated redundant `StackTrace.current` calls
- **New `_logWithLocation()` method** - Internal method that accepts pre-resolved location
- **~15-25μs saved** per tagged log operation

#### ObjectFormatter Fast Path
- **Fast path for simple Maps** - Maps with ≤3 entries and no nesting bypass JsonEncoder
- **Direct string formatting** - Avoids encoder overhead for simple cases
- **~5-25μs saved** for simple map operations

#### LogFormatter Cache
- **Multiline check cached** - `contains('\n')` evaluated once per format operation
- **Variable reuse** - Eliminates redundant string scans

### Performance Results

| Operation | Before | After | Improvement |
|-----------|--------|-------|-------------|
| Simple tag | ~25μs | ~17μs | ~32% faster |
| Map tag | ~35μs | ~24μs | ~31% faster |
| Error tag | ~35μs | ~27μs | ~23% faster |

---

## [2.0.0] - 2026-01-30

### Added

#### Tag Logging System for AI Analysis
- **`Log.tag(name, message)`** - Group related logs across layers with tags
- **`Log.export(name)`** - Export tagged logs as Markdown to console
- **`Log.export(name, onlyOnError: true)`** - Conditional export only when errors occur
- **`Log.exportAll()`** - Export all tags at once
- **`Log.clear(name)`** - Clear a tag without exporting
- **`Log.clearAll()`** - Clear all tags
- **`Log.hasTag(name)`** - Check if a tag exists
- **`Log.hasErrors(name)`** - Check if a tag has error entries
- **`Log.entryCount(name)`** - Get entry count for a tag

#### Auto Stack Trace Capture
- Automatic stack trace capture for WARNING, ERROR, and CRITICAL levels
- No need to manually pass `StackTrace.current` for error logs

#### Markdown Export Format
- Clean Markdown output optimized for AI analysis (Claude, ChatGPT, etc.)
- Visual separators for easy copy-paste
- JSON syntax highlighting for Map objects
- Collapsible stack traces using HTML details tags
- Summary section with entry counts by level
- Timeline section with timestamps and source locations

#### New Export Module
- `lib/src/export/tagged_entry.dart` - Entry model for tagged logs
- `lib/src/export/md_formatter.dart` - Markdown formatter for AI-friendly output

### Changed
- Improved documentation with comprehensive examples
- Better code organization with section separators
- Enhanced docstrings for all public methods

### Technical Details
- Zero overhead in release builds (tag storage code is removed by compiler)
- No file I/O - exports to console for universal compatibility
- Works with Flutter, Dart VM, Web, and all platforms

## [1.0.4]
- Remove dart:io for `jaspr` support

## [1.0.3]
- `WARNING` in capital letters

## [1.0.2]

### Added
- Full Web platform support with conditional imports
- WASM runtime compatibility
- Support for all 6 Dart platforms (Android, iOS, Windows, macOS, Linux, Web)

### Changed
- Replaced `dart:io` imports with conditional platform abstraction
- Improved cross-platform console output handling
- Enhanced Web browser console integration

### Fixed
- Web platform compatibility issue that prevented deployment
- WASM runtime compatibility for future-proofing
- Platform detection now works correctly across all environments

### Technical Details
- Implemented conditional imports for platform-specific code
- Added platform abstraction layer (`platform_io.dart`, `platform_web.dart`, `platform_stub.dart`)
- Ensured ANSI color codes work seamlessly on Web platforms
- Removed direct `dart:io` dependency from main logger code

## [1.0.1]

### Added
- Screenshot in README showing actual logger output with colors and formatting

### Changed
- Updated README with proper screenshot dimensions
- Improved screenshot visibility in documentation

### Fixed
- README formatting issues
- Missing screenshot that was referenced but not included in initial release

## [1.0.0] - 2025-01-14

### Added
- Initial release of Logger RS
- Rust-style formatted output with beautiful colors
- Support for multiple log levels: Trace, Debug, Info, Warning, Error, Critical
- Precise file location tracking (file:line:column)
- ANSI color support for terminals
- Stack trace support for error logging
- Zero-configuration setup
- Cross-platform support (Flutter, Dart VM, Dart Native)
- High-performance logging with minimal overhead
- Custom object logging support
- Comprehensive test suite
- Complete documentation and examples

### Features
- `Log.t()` - Trace level logging (most verbose)
- `Log.d()` - Debug level logging
- `Log.i()` - Info level logging
- `Log.w()` - Warning level logging
- `Log.e()` - Error level logging with optional stack traces
- `Log.f()` - Critical/Fatal level logging

### Technical Details
- Built on top of the `logging` package for reliability
- Smart platform detection for color support
- Automatic caller location extraction from stack traces
- Clean and readable Rust-inspired formatting
