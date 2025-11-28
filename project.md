# Project Overview

## swift_flutter

A reactive state management library for Flutter with automatic dependency tracking. This project provides a Swift-like reactive programming experience for Flutter applications.

## Project Structure

### Core Files
- `pubspec.yaml` - Package configuration and dependencies
- `lib/` - Main library source code
  - `core/` - Core reactive state management functionality
  - `store/` - Store and middleware implementation
  - `ui/` - UI components (Swift widget, Rx builder, etc.)
  - `swift_flutter.dart` - Main library export

### Documentation
- `README.md` - Main documentation and usage guide
- `ARCHITECTURE_REVIEW.md` - Architecture documentation
- `ADVANCED_PATTERNS.md` - Advanced usage patterns
- `DEVTOOLS.md` - DevTools integration guide
- `LIBRARY_REVIEW.md` - Library review and features
- `CHANGELOG.md` - Version history
- `LICENSE` - MIT License

### Testing
- `test/` - Comprehensive test suite
  - `core/` - Core functionality tests
  - `store/` - Store tests

### Configuration
- `analysis_options.yaml` - Dart analyzer configuration
- `.gitignore` - Git ignore rules (excludes platform-specific folders)

## Excluded from Repository

The following platform-specific folders are excluded from version control:
- `/android/` - Android platform files
- `/ios/` - iOS platform files
- `/macos/` - macOS platform files
- `/windows/` - Windows platform files
- `/linux/` - Linux platform files
- `/web/` - Web platform files
- `/build/` - Build artifacts
- `/project/` - Development projects

These are excluded because this is a Flutter package/library, not an application. Platform-specific files are only needed when running the package, not for distribution.

## Required Files for Distribution

The repository includes only the essential files needed for:
- Package distribution on pub.dev
- Library usage by other developers
- Documentation and examples
- Testing and CI/CD

## Version

Current version: 2.1.0

## License

MIT License - See LICENSE file for details.

## Repository

GitHub: https://github.com/ravikinha/swift_flutter

