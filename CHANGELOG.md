# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.1] - 2025-01-XX

### Added
- Comprehensive use cases documentation in README
- Detailed examples for all 12 features
- Improved code comments and documentation

## [1.1.0] - 2025-01-XX

### Changed
- **BREAKING**: Renamed all classes to use "Swift" prefix for consistency:
  - `RxFuture` → `SwiftFuture`
  - `RxField` → `SwiftField`
  - `RxTween` → `SwiftTween`
  - `RxPersisted` → `SwiftPersisted`
- Updated all examples, tests, and documentation to use new naming
- Improved API consistency across the library

## [1.0.1] - 2025-01-XX

### Changed
- Renamed `rx()` function to `swift()` for better API consistency
- Improved type inference - `swift()` now supports both automatic and explicit typing
- Updated all examples to use `swift()` syntax

### Added
- `swift()` function with optional type inference
  - `swift(0)` automatically creates `Rx<int>`
  - `swift<int>(0)` explicitly creates `Rx<int>` (recommended for models)
  - Works with all types: int, String, bool, double, List, Map, custom classes, etc.

## [1.0.0] - 2025-01-XX

### Added
- **Automatic Type Inference with `swift()`** - Use `swift(value)` for automatic inference or `swift<Type>(value)` for explicit typing
  - `swift(0)` automatically creates `Rx<int>`
  - `swift<int>(0)` explicitly creates `Rx<int>` (recommended for models)
  - `swift('hello')` automatically creates `Rx<String>`
  - `swift<User>(user)` explicitly creates `Rx<User>` (for custom models)
  - Works with all types: int, String, bool, double, List, Map, custom classes, etc.
- **Reactive State (Rx)** - Automatic dependency tracking with `Rx<T>`
- **Mark Widget** - Auto-rebuild widget that tracks dependencies automatically
- **Computed Values** - Derived state that automatically updates when dependencies change
- **RxFuture** - Async state management with loading/error/success states
- **Form Validation** - Field validation with built-in validators (`RxField`)
- **Persistence** - Automatic save/load of reactive values (`RxPersisted`)
- **Middleware/Interceptors** - Action interception and logging system
- **Batch Transactions** - Prevent unnecessary rebuilds with transaction batching
- **Debug Logger** - Configurable logging with history and levels
- **Animation Tween** - Reactive animation values (`RxTween`)
- **Lifecycle Controller** - Widget lifecycle state management
- **Global Store/DI** - Dependency injection and global state management
- Comprehensive test suite with 58 passing tests
- Example app demonstrating all features

### Documentation
- Complete README with installation and usage examples
- Architecture review document
- Performance comparison document
- Inline code documentation

