/// A reactive state management library for Flutter with automatic dependency tracking.
///
/// This library provides a comprehensive set of tools for managing state in Flutter
/// applications, inspired by MobX and Vue's reactivity system.
///
/// ## Features
///
/// - **Reactive State (Rx)**: Automatic dependency tracking with [Rx] and [swift]
/// - **Mark Widget**: Auto-rebuild widget that tracks dependencies automatically
/// - **Computed Values**: Derived state that automatically updates when dependencies change
/// - **Async State**: [SwiftFuture] for managing loading/error/success states
/// - **Form Validation**: [SwiftField] with built-in validators
/// - **Persistence**: [SwiftPersisted] for automatic save/load of reactive values
/// - **Middleware/Interceptors**: Action interception and logging system
/// - **Batch Transactions**: Prevent unnecessary rebuilds with [Transaction]
/// - **Debug Logging**: Configurable logging with history via [Logger]
/// - **Animation Tween**: Reactive animation values with [SwiftTween]
/// - **Lifecycle Controller**: Widget lifecycle state management
/// - **Global Store/DI**: Dependency injection and global state management
///
/// ## Quick Start
///
/// ```dart
/// import 'package:swift_flutter/swift_flutter.dart';
///
/// // Create reactive state
/// final counter = swift(0);
///
/// // Use in widget
/// Mark(
///   builder: (context) => Text('Count: ${counter.value}'),
/// )
///
/// // Update value - widget rebuilds automatically!
/// counter.value = 10;
/// ```
///
/// See the [README](https://github.com/ravikinha/swift_flutter) for more examples.
library swift_flutter;

// Core
export 'core/rx.dart' show Rx, swift;
export 'core/computed.dart';
export 'core/rx_future.dart';
export 'core/rx_field.dart';
export 'core/transaction.dart';
export 'core/tween.dart';
export 'core/logger.dart';
export 'core/lifecycle.dart';
export 'core/persistence.dart';
export 'core/performance_monitor.dart';
export 'core/error_boundary.dart';
export 'core/test_helpers.dart';
export 'core/scope.dart';
export 'core/lazy_rx.dart';
export 'core/reducers.dart';
export 'core/normalization.dart';
export 'core/pagination.dart';
export 'core/debug.dart';
export 'core/routing.dart';
export 'core/type_safety.dart';
export 'core/structured_patterns.dart';

// Store
export 'store/store.dart';
export 'store/middleware.dart';

// UI
export 'ui/mark.dart';
export 'ui/rx_builder.dart';
