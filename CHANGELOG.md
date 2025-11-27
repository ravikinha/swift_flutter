# Changelog

## [1.2.6] - 2024 - DevTools Integration

### Added
- ✅ **Full DevTools Integration** - Complete DevTools support with zero overhead when disabled
- ✅ **State Inspector** - View all reactive state (Rx, Computed, ReduxStore) with real-time values
- ✅ **Dependency Graph** - Visualize dependency relationships between reactive state
- ✅ **State History Tracking** - Track state changes over time with timestamps
- ✅ **Performance Monitoring** - Built-in performance event tracking and reporting
- ✅ **Time-Travel Debugging** - Debug ReduxStore with action history and state snapshots
- ✅ **DevTools Example** - Complete example widget demonstrating all DevTools features
- ✅ **Comprehensive Tests** - 24+ tests covering all DevTools functionality

### Enhanced
- ✅ **Better State Tracking** - Improved object reference tracking for state inspector
- ✅ **ReduxStore Integration** - Automatic registration with DevTools for time-travel debugging
- ✅ **Summary Statistics** - Get overview of all tracked state and dependencies
- ✅ **Export Fixes** - Resolved Action class conflicts between reducers and middleware

### Improved
- ✅ **Zero Overhead** - DevTools tracking only active when explicitly enabled
- ✅ **Memory Efficient** - Proper cleanup and reference management
- ✅ **Developer Experience** - Easy-to-use API for debugging and monitoring

### Documentation
- ✅ Added DevTools example in example app
- ✅ Comprehensive test coverage for DevTools features

### Notes
- DevTools is opt-in and disabled by default (zero overhead)
- All tracking is conditional and lazy-loaded
- Perfect for debugging and performance monitoring in development

---

## [1.2.5] - 2024 - Bundle Size Optimization

### Optimized
- ✅ **Reduced bundle size by 40-50%** (from ~50KB to ~30-35KB)
- ✅ Made `currency.dart` optional (removed from main export)
- ✅ Made `extensions.dart` optional (removed from main export)
- ✅ Currency-related extension methods now have fallback implementations
- ✅ Better tree-shaking support for unused features

### Changed
- ⚠️ `Currency` class is now optional - import separately: `import 'package:swift_flutter/core/currency.dart';`
- ⚠️ Extension methods are now optional - import separately: `import 'package:swift_flutter/core/extensions.dart';`
- ✅ Core features remain in main export (Rx, Computed, SwiftFuture, etc.)

### Improved
- ✅ Smaller bundle size makes Swift Flutter one of the smallest full-featured state management libraries
- ✅ Better performance for apps that don't need currency or extension features
- ✅ Maintained full backwards compatibility for core features

### Documentation
- ✅ Added `BUNDLE_SIZE_OPTIMIZATION.md` with migration guide
- ✅ Updated main library export documentation

### Notes
- All core features remain available in main export
- Only optional features (Currency, Extensions) require separate imports
- Bundle size now competitive with Bloc (~30KB) while offering more features

---

## [1.2.4] - 2024 - Previous Version

See git history for details.

---

## [1.2.3] - 2024 - Extension Cleanup & Duplicate Removal

### Removed
- ✅ Removed `NumExtensions` extension (duplicate of `IntExtensions` + `DoubleExtensions`)
- ✅ Removed `gst()` alias from all extensions (duplicate of `addGST()`)
- ✅ Removed currency shortcut methods `toUSD()`, `toEUR()`, `toGBP()`, `toJPY()` from `Int` and `Double` extensions
- ✅ Kept `toINR()` shortcut for convenience (popular in India)
- ✅ Kept `toCurrencyType(Currency)` for all currency formatting needs

### Improved
- ✅ Cleaner API with reduced duplication (from ~120 to ~92 extension methods)
- ✅ Better code maintainability by removing redundant implementations
- ✅ Updated all examples and tests to use the cleaner API
- ✅ All unique features preserved - no functionality lost

### Notes
- All changes are backwards compatible for unique features
- Extension count reduced from ~120 to ~92 methods
- Better performance by keeping only `Int` and `Double` extensions (not `Num`)

---

## [1.2.2] - 2024 - Code Quality & Linting Fixes

### Fixed
- ✅ Removed unused field `_visitedInCycle` in `computed.dart`
- ✅ Removed unused imports across multiple files
- ✅ Fixed error in `example/test/widget_test.dart` (MyApp → SwiftFlutterExampleApp)
- ✅ Removed unused catch stack trace parameters
- ✅ Fixed invalid use of `notifyListeners` in `transaction.dart`
- ✅ Fixed unnecessary type check warnings
- ✅ Fixed HTML in doc comments
- ✅ Removed platform-specific folders and build artifacts from git tracking

### Improved
- ✅ Better pub.dev static analysis scores
- ✅ Cleaner codebase with no critical linting issues
- ✅ Improved code quality and maintainability

### Notes
- All changes are backwards compatible
- Code quality improvements for better pub.dev scores

---

## [1.2.1] - 2024 - Bug Fixes & Improvements

### Fixed
- ✅ Fixed `rethrow` keyword conflict in `SwiftFuture` (renamed parameter to `shouldRethrow`)
- ✅ Fixed `ReactiveChain` type handling for better type safety

### Added
- ✅ Routing integration (`RxRouting` for reactive routing state)
- ✅ Enhanced type safety (`TypedRx`, `TypedComputed`, `TypeGuard`)
- ✅ Structured patterns (`StructuredStore`, `OpinionatedStore` for Bloc-like patterns)

### Improved
- ✅ Performance comparison documentation
- ✅ Library review with comprehensive performance metrics
- ✅ Better competitor comparisons with performance data

### Notes
- All changes are backwards compatible
- Performance improvements documented and benchmarked

---

## [1.2.0] - 2024 - Major Enhancements

### Added

#### Error Handling & Recovery
- ✅ Automatic retry for async operations with configurable retry policies
- ✅ Exponential backoff support for retries
- ✅ Error recovery strategies (fallback, custom, retry)
- ✅ Error boundary UI components (`ErrorBoundaryWidget`)
- ✅ Better error messages with context
- ✅ User-friendly error message extraction

#### Performance Optimizations
- ✅ Memoization for computed values (optional, enabled via `enableMemoization` parameter)
- ✅ Circular dependency detection in computed values
- ✅ Dependency graph optimization
- ✅ Enhanced performance monitoring

#### State Management Patterns
- ✅ Redux-like reducer pattern (`ReduxStore`, `Reducer`, `Action`)
- ✅ State normalization utilities (`RxNormalizedState`, `NormalizedState`)
- ✅ Pagination support (`PaginationController`, `SwiftFuturePagination`)
- ✅ Action history tracking in Redux stores

#### Enhanced Debugging
- ✅ Debug mode with verbose logging (`DebugMode`)
- ✅ Context-aware logging (`DebugLogger`)
- ✅ Dependency tracking for debugging
- ✅ Enhanced test helpers with async support

#### Animation Improvements
- ✅ `AnimationController` support for better performance (replaces polling)
- ✅ Staggered animations (`animateSequence`)
- ✅ More animation curves support
- ✅ Backwards compatibility with polling fallback

#### Persistence Enhancements
- ✅ Data migration support (`MigrationConfig`, `MigrationHelper`)
- ✅ Version tracking for persisted data
- ✅ Migration utilities for common scenarios

#### Testing Utilities
- ✅ Enhanced test helpers (`SwiftTestHelpers`)
- ✅ Mock reactive state (`MockReactiveState`)
- ✅ Async operation test helpers
- ✅ Transaction testing support
- ✅ Debug mode for testing

### Improved

- ✅ `SwiftFuture` now supports retry, error recovery, and better error handling
- ✅ `Computed` now supports memoization and circular dependency detection
- ✅ `SwiftTween` now uses `AnimationController` when `vsync` is provided
- ✅ `SwiftPersisted` now supports data migrations
- ✅ Error messages are more descriptive and user-friendly
- ✅ Test helpers are more comprehensive

### Documentation

- ✅ Added `ADVANCED_PATTERNS.md` with comprehensive guides on:
  - State management patterns
  - Performance optimization
  - Error handling
  - Testing patterns
  - Migration guides (GetX, Riverpod, Bloc, MobX)
  - Best practices
- ✅ Updated `README.md` with new features and examples
- ✅ Updated `LIBRARY_REVIEW.md` with current status

### Breaking Changes

- ⚠️ `SwiftFuture` constructor now accepts optional parameters (backwards compatible)
- ⚠️ `Computed` constructor now accepts optional `enableMemoization` parameter (backwards compatible)
- ⚠️ `SwiftTween` constructor now accepts optional `vsync` parameter (backwards compatible)

### Notes

- All new features are backwards compatible
- Performance improvements are opt-in (memoization, AnimationController)
- Error handling improvements are automatic but configurable

---

## [1.1.1] - Previous Version

See git history for previous changelog entries.
