# Changelog

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
