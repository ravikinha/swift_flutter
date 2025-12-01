/// A reactive state management library for Flutter with automatic dependency tracking.
///
/// This library provides a comprehensive set of tools for managing state in Flutter
/// applications, inspired by MobX and Vue's reactivity system.
///
/// ## Features
///
/// - **Reactive State (SwiftValue)**: Automatic dependency tracking with [SwiftValue] and [swift]
/// - **Two Patterns**: Direct state management OR Controller pattern with enforced separation
/// - **Swift-like Extensions**: 80+ convenient methods (toggle, add, sub, mul, div, etc.)
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
/// // Pattern 1: Direct state management (for view-local state)
/// final counter = swift(0);
/// Swift(
///   builder: (context) => Text('Count: ${counter.value}'),
/// )
/// counter.value = 10; // Direct modification
///
/// // Pattern 2: Controller pattern (for business logic)
/// class CounterController extends SwiftController {
///   final counter = swift(0);
///   void increment() => counter.value++;
/// }
/// ```
///
/// See the [README](https://github.com/ravikinha/swift_flutter) for more examples.
library;

// Core
// ignore: deprecated_member_use_from_same_package
export 'core/rx.dart' show SwiftValue, Rx, swift;
export 'core/computed.dart';
export 'core/rx_future.dart';
export 'core/rx_field.dart';
export 'core/transaction.dart';
export 'core/tween.dart';
export 'core/logger.dart';
export 'core/lifecycle.dart';
export 'core/persistence.dart';
export 'core/controller.dart' show SwiftController, ReadOnlyRx;
export 'core/performance_monitor.dart';
export 'core/error_boundary.dart';
export 'core/test_helpers.dart';
export 'core/scope.dart';
export 'core/lazy_rx.dart';
export 'core/reducers.dart' show ReduxStore, Reducer, combineReducers, applyMiddleware, ReduxMiddleware;
export 'core/normalization.dart';
export 'core/pagination.dart';
export 'core/debug.dart';
export 'core/routing.dart';
export 'core/type_safety.dart';
export 'core/structured_patterns.dart';
export 'core/devtools.dart';
export 'core/swift_flutter_init.dart';
export 'core/network_interceptor.dart';
export 'core/log_interceptor.dart' show LogInterceptor, InterceptedLogEntry, LogType, swiftPrint;
export 'core/view_interceptor.dart';
export 'core/http_helper.dart';
// export 'core/http_client_wrapper.dart'; // Not ready for production use
export 'core/websocket_interceptor.dart';

// Store
export 'store/store.dart';
export 'store/middleware.dart' show Middleware, LoggingMiddleware, ExampleAction;

// UI
export 'ui/mark.dart';
export 'ui/rx_builder.dart';
export 'ui/debug_page.dart';
export 'ui/debug_floating_button.dart';
