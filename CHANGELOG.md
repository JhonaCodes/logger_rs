# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
