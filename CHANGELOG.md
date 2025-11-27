# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-XX

### Added
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

