# Changelog

## [2.3.3] - 2025-01-XX - Network Image Loading Fix

### Fixed
- ✅ **Network Image Loading** - Fixed `NoSuchMethodError` when loading network images
  - Added missing `compressionState` getter to `_StreamedHttpClientResponse` and `_ReplayedHttpClientResponse` wrapper classes
  - Fixes issue where Flutter's `consolidateHttpClientResponseBytes` couldn't access `compressionState` property
  - Network images now load correctly without errors when using AutoInjector for HTTP interception

### Technical Details
- `compressionState` getter now properly delegates to the original `HttpClientResponse`
- Both response wrapper classes now fully implement all required `HttpClientResponse` properties
- Zero breaking changes - all changes are internal fixes

### Notes
- Fixes crash when loading images from network URLs (e.g., `NetworkImage`)
- All network interception features continue to work as expected
- Backward compatible with all existing code

---

## [2.3.2] - 2024-12-XX - Reactive State Improvements & Build Phase Fixes

### Fixed
- ✅ **UI Reactivity** - Improved immediate UI updates when clearing data
  - All debug tool tabs (HTTP, WebSocket, Logs, Curl) now update immediately when data is cleared
  - No longer requires hot reload to see cleared data
  - Reactive state management ensures UI stays in sync with interceptor data

### Improved
- ✅ **Reactive State Architecture** - Converted interceptor data to use SwiftValue directly
  - `NetworkInterceptor._requests` is now `SwiftValue<List<NetworkRequest>>`
  - `LogInterceptor._logs` is now `SwiftValue<List<InterceptedLogEntry>>`
  - `WebSocketInterceptor._connections` is now `SwiftValue<Map<String, WebSocketConnection>>`
  - More idiomatic Swift Flutter architecture - data is reactive, not separate triggers
- ✅ **Better Type Safety** - `updateTrigger` now returns the actual reactive list/map instead of a separate int trigger
- ✅ **Performance** - Eliminated unnecessary trigger updates by using reactive values directly
- ✅ **Code Quality** - Cleaner, more maintainable code following Swift Flutter patterns

### Technical Details
- All `SwiftValue` updates in interceptors are now wrapped in `Future.microtask()` to defer execution
- This ensures updates happen after the current build phase completes
- UI widgets observe the reactive values directly, ensuring automatic rebuilds when data changes
- Zero breaking changes - all changes are internal improvements

### Notes
- All changes are backward compatible
- Debug tool now works reliably even when logs are captured during build phase
- Improved developer experience with immediate UI feedback

---

## [2.3.1] - 2024-12-XX - SwiftDebugFloatingButton Documentation

### Improved
- ✅ **Documentation Update** - Added clear instructions for using `SwiftDebugFloatingButton`
- ✅ **README Enhancement** - Explicitly mentions that `SwiftDebugFloatingButton` must be added to Scaffold to access debug inspector
- ✅ **Usage Examples** - Updated code examples to show proper integration of debug floating button

### Notes
- Users must add `SwiftDebugFloatingButton` to their Scaffold's `floatingActionButton` property
- The button automatically appears when debug tool is enabled via `SwiftFlutter.init(debugtool: true)`
- This update clarifies the setup process for accessing the debug inspector page

---

## [2.3.0] - 2024-12-XX - Debug Tool & Network Interception

### Added
- ✅ **Debug Tool** - Comprehensive debugging interface for network requests, logs, and WebSocket connections
  - Single initialization: `SwiftFlutter.init(debugtool: true)` enables all debug features
  - Floating action button for easy access to debug tool
  - Modern, responsive UI that works on mobile, tablet, and desktop
- ✅ **Network Interceptor** - Automatic HTTP request/response capture
  - Captures all HTTP requests made with `http` and `dio` packages
  - Tracks request method, URL, headers, body, and response data
  - Generates curl commands for easy API testing
  - Shows request duration and status codes
  - Color-coded status indicators (green for success, red for errors)
- ✅ **WebSocket Interceptor** - Real-time WebSocket connection tracking
  - Captures WebSocket connections and disconnections
  - Tracks messages sent and received
  - Monitors connection errors
  - Shows connection status and event history
- ✅ **Log Interceptor** - Capture and view all print statements
  - Intercepts `swiftPrint()` calls and standard print statements
  - Categorizes logs by type (print, debug, info, warning, error)
  - Color-coded log entries with icons
  - Searchable log history
- ✅ **Debug Page UI** - Beautiful, modern interface
  - 4 tabs: HTTP, WebSocket, Logs, and Curl
  - Responsive design for mobile and desktop
  - Request/response details with syntax highlighting
  - Copy-to-clipboard functionality for curl commands
  - Empty states with helpful messages
- ✅ **HTTP Helper** - Easy integration with `http` package
  - `SwiftHttpHelper.intercept()` wraps HTTP calls for automatic interception
  - Supports GET, POST, PUT, PATCH, DELETE methods
  - Automatic JSON parsing and error handling
- ✅ **View Interceptor** - Navigation management for debug page
  - `SwiftViewInterceptor` manages debug page navigation
  - Floating action button appears when debug tool is enabled
- ✅ **Comprehensive Test Coverage**
  - 35+ tests for network interceptor, log interceptor, HTTP helper, and view interceptor
  - All tests passing with full coverage

### Improved
- ✅ **Developer Experience** - Single initialization call enables all debug features
- ✅ **Zero Dependencies** - Debug tool works without external packages
- ✅ **Performance** - Efficient request/event limiting to prevent memory issues
- ✅ **Mobile Support** - Fully responsive design with mobile-optimized layouts

### Documentation
- ✅ Updated README with debug tool features
- ✅ Added network example demonstrating HTTP and WebSocket interception
- ✅ Comprehensive API documentation

### Notes
- Debug tool is opt-in and disabled by default (zero overhead)
- All network interception is conditional and only active when enabled
- Perfect for debugging API calls and network issues in development
- Works seamlessly with existing `http` and `dio` packages

---

## [2.2.1] - 2024-12-XX - Pub.dev Validation Fixes & Test Fixes

### Fixed
- ✅ **Pub.dev Validation** - Fixed package description length (shortened from 310 to 126 characters, within 60-180 range)
- ✅ **Static Analysis** - Removed unused import `devtools/devtools_tabs.dart`
- ✅ **Deprecated APIs** - Fixed all deprecated API usage:
  - `Matrix4.scale()` → `Matrix4.diagonal3Values()` for proper scaling
  - `withOpacity()` → `withValues(alpha:)` for color opacity
  - Fixed `sort_child_properties_last` warnings in `AnimatedWidgetBuilder`
- ✅ **Rx Deprecation Warnings** - Added appropriate ignore comments for backward-compatible deprecated `Rx` usage
- ✅ **Test Failures** - Fixed `SwiftDevTools.clear()` method to properly clear `_swiftRegistry` and `_swiftRefs` instead of deprecated getters
- ✅ **DevTools Tests** - All DevTools tests now passing (375 tests total)

### Improved
- ✅ **Pub.dev Compliance** - Package now meets all pub.dev validation requirements
- ✅ **Code Quality** - Reduced static analysis issues from 125 to 47 (mostly internal deprecated usage)
- ✅ **Test Coverage** - Fixed failing tests in devtools_test.dart

### Notes
- All changes are backward compatible
- Package description optimized for search engines (60-180 character range)
- Ready for pub.dev publication with improved static analysis score

---

## [2.2.0] - 2024-12-XX - SwiftUI-like Declarative Animations

### Added
- ✅ **SwiftUI-like Declarative Animations** - Zero boilerplate animation system
  - No controllers, no ticker providers required in user code
  - Works with just `StatefulWidget` and `StatelessWidget` - no mixins needed!
  - Clean chaining API: `.animate().scale(1.2).fadeIn().repeat(reverse: true)`
  - All animation management handled internally
- ✅ **Comprehensive Animation Methods**
  - `.scale()`, `.scaleX()`, `.scaleY()` - Scale transformations
  - `.fadeIn()`, `.fadeOut()`, `.opacity()` - Opacity animations
  - `.slideX()`, `.slideY()` - Slide animations
  - `.slideInTop()`, `.slideInBottom()`, `.slideInLeft()`, `.slideInRight()` - Directional slide-ins
  - `.rotate()` - Rotation animations
  - `.fadeInScale()` - Combined fade and scale
  - `.bounce()`, `.pulse()` - Special effect animations
- ✅ **Animation Configuration**
  - `.duration()` - Custom duration (supports Duration, string shorthand, or number extensions)
  - `.delay()` - Animation delay
  - `.curve()` - Custom animation curves
  - `.repeat(reverse: bool)` - Infinite repeat with optional reverse
  - `.repeatCount(int, reverse: bool)` - Repeat specific number of times
  - `.persist()` - Keep animation state on rebuild
- ✅ **Shorthand Duration Support**
  - String format: `.duration(".500ms")`, `.duration("0.5s")`, `.duration("5m")`
  - Number extensions: `.duration(500.ms)`, `.duration(0.5.s)`, `.duration(5.m)`
  - Traditional: `.duration(const Duration(seconds: 5))`
  - Same support for `.delay()` method
- ✅ **Mixin-Free Architecture**
  - Uses `TickerProviderStateMixin` internally (hidden from users)
  - User widgets don't need any mixins - just `StatefulWidget` or `StatelessWidget`
  - Zero boilerplate - just chain methods and it works!
- ✅ **Comprehensive Examples**
  - 8 sections demonstrating all animation features
  - Interactive examples with user interaction
  - Real-world use cases
- ✅ **Full Test Coverage**
  - 39+ test cases covering all animation functionality
  - Tests for string shorthand, number extensions, and all animation methods
  - Widget integration tests

### Improved
- ✅ **Better Developer Experience** - Animations are now as simple as SwiftUI
- ✅ **Performance** - Internal ticker management is optimized
- ✅ **Type Safety** - Full type checking for all animation parameters
- ✅ **Documentation** - Comprehensive guides and examples

### Documentation
- ✅ Added animation chapter to learning guide
- ✅ Interactive animation guide with live examples
- ✅ Updated README with animation examples
- ✅ Comprehensive API documentation

### Notes
- All animation features are backward compatible
- No breaking changes to existing code
- Animations work seamlessly with existing swift_flutter patterns
- Perfect for creating smooth, professional animations with minimal code

---

## [2.1.0] - 2024-12-XX - Controller Pattern & Swift Naming

### Added
- ✅ **SwiftController Pattern** - Enforced separation of concerns with read-only views
  - Controllers can modify state, views can only read
  - Automatic read-only enforcement from views
  - No need for manual `ReadOnlyRx` getters - just use `swift()` directly
- ✅ **ControllerRx** - Special reactive type that automatically becomes read-only from views
- ✅ **Both Patterns Support** - Direct pattern (for view-local state) and Controller pattern (for business logic)
- ✅ **Comprehensive Examples** - Updated all examples to demonstrate both patterns

### Changed
- ✅ **Renamed Rx to SwiftValue** - All internal references now use `SwiftValue<T>` instead of `Rx<T>`
  - `Rx<T>` is now a deprecated type alias (backward compatible)
  - `swift()` function returns `SwiftValue<T>`
  - All DevTools methods renamed: `trackSwiftCreation()`, `getSwiftId()`, etc.
- ✅ **Updated Documentation** - README now clearly explains both patterns and when to use each
- ✅ **Extension Methods** - Documented all 80+ Swift-like extension methods (toggle, add, sub, mul, div, etc.)

### Improved
- ✅ **Better Separation of Concerns** - Controller pattern enforces clean architecture
- ✅ **Type Safety** - Runtime protection prevents views from modifying controller state
- ✅ **Developer Experience** - Simplified API - no need for manual `ReadOnlyRx` getters
- ✅ **Consistent Naming** - Project now uses Swift naming throughout (SwiftValue, SwiftController, etc.)

### Documentation
- ✅ Updated README with both patterns clearly explained
- ✅ Added examples showing when to use each pattern
- ✅ Documented all extension methods (Bool, Int, Double, String, List, SwiftValue)
- ✅ Updated CHANGELOG with all new features

### Notes
- All changes are backward compatible
- `Rx<T>` still works but is deprecated (use `SwiftValue<T>`)
- Direct pattern still works for simple use cases
- Controller pattern recommended for complex apps and teams

---

## [2.0.0] - 2024-11-27 - Code Quality & Linter Perfection

### Fixed
- ✅ **Fixed all 65 linter issues** - Achieved zero warnings, errors, and info messages
- ✅ Removed unused imports (`swift_flutter.dart`, `dart:typed_data`)
- ✅ Removed unused methods (`_updateAmount`, `_handleMessage`, `_isComputedDirty`)
- ✅ Removed unused variables across test files (5 in `devtools_test.dart`, 1 in `offline_test.dart`, 1 in `offline.dart`)
- ✅ Fixed unnecessary type checks in `rx_inference_test.dart` (13 instances - replaced `is Type` with `isA<Type>()`)
- ✅ Made fields final where appropriate (`_totalItems` in `pagination.dart`)
- ✅ Removed unnecessary `this.` qualifiers (12 instances in `extensions.dart`)
- ✅ Fixed HTML in documentation comments (4 instances - escaped angle brackets in `Rx<T>` references)
- ✅ Updated deprecated API calls (`withOpacity` → `withValues` in 3 locations)
- ✅ Fixed dangling library doc comments (replaced named libraries with anonymous `library;`)
- ✅ Replaced `print` with `stderr.writeln` in tool scripts

### Improved
- ✅ **Used super parameters** throughout codebase for cleaner constructors
  - `ReduxStore` constructor
  - `TypedComputed` constructor
- ✅ Better code maintainability with zero linter warnings
- ✅ Improved pub.dev static analysis score (perfect 130/130 expected)
- ✅ Cleaner, more modern Dart code following latest best practices

### Notes
- All changes are backwards compatible
- No breaking changes to public API
- Perfect static analysis score achieved
- Ready for pub.dev publication

---

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
