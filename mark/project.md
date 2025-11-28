# Project Documentation

## Overview

This is the **swift_flutter** project - A reactive state management library for Flutter with automatic dependency tracking.

## Project Structure

### Core Directories

- **`lib/`** - Main library source code
  - `core/` - Core functionality and utilities
  - `store/` - Store and middleware implementation
  - `ui/` - UI components (mark, rx_builder)
  - `swift_flutter.dart` - Main library entry point
  - `main.dart` - Library entry point

- **`test/`** - Test files
  - `core/` - Core functionality tests
  - `store/` - Store tests
  - `widget_test.dart` - Widget tests

- **`tool/`** - Development tools
  - `preprocessor.dart` - Preprocessing utilities

- **`mark/`** - Project documentation and markdown files
  - `project.md` - This file

### Configuration Files

- **`pubspec.yaml`** - Package dependencies and configuration
- **`analysis_options.yaml`** - Dart analyzer configuration
- **`.gitignore`** - Git ignore rules (excludes platform-specific folders)

### Documentation Files

- `README.md` - Main project documentation
- `ARCHITECTURE_REVIEW.md` - Architecture documentation
- `ADVANCED_PATTERNS.md` - Advanced usage patterns
- `LIBRARY_REVIEW.md` - Library review
- `DEVTOOLS.md` - DevTools integration guide
- `BUNDLE_SIZE_OPTIMIZATION.md` - Bundle size optimization
- `ENTERPRISE_FEATURES.md` - Enterprise features
- `IMPLEMENTATION_SUMMARY.md` - Implementation summary
- `CHANGELOG.md` - Version changelog

## Excluded from Git

The following platform-specific folders are excluded from version control (as per `.gitignore`):

- `/android/` - Android platform files
- `/ios/` - iOS platform files
- `/macos/` - macOS platform files
- `/windows/` - Windows platform files
- `/linux/` - Linux platform files
- `/web/` - Web platform files
- `/build/` - Build artifacts
- `/example/` - Example project (separate package)

## Version

Current version: **2.1.0**

## Dependencies

- Flutter SDK: `>=3.0.0`
- Dart SDK: `>=3.0.0 <4.0.0`

## Repository

- **GitHub**: https://github.com/ravikinha/swift_flutter
- **Pub.dev**: https://pub.dev/packages/swift_flutter

## License

MIT License - See [LICENSE](../LICENSE) file for details.

