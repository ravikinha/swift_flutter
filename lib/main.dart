// swift_flutter - A reactive state management library for Flutter
//
// This library provides:
// - Reactive state (Rx)
// - Automatic dependency tracking (Mark)
// - Global store / Dependency injection
// - Lifecycle management
// - Computed values
// - Async state (RxFuture)
// - Form validation
// - Persistence
// - Middleware / Interceptors
// - Batch transactions
// - Debug logging
// - Animation tweens

library swift_flutter;

// Core
export 'core/rx.dart';
export 'core/computed.dart';
export 'core/rx_future.dart';
export 'core/rx_field.dart';
export 'core/transaction.dart';
export 'core/tween.dart';
export 'core/logger.dart';
export 'core/lifecycle.dart';
export 'core/persistence.dart';

// Store
export 'store/store.dart';
export 'store/middleware.dart';

// UI
export 'ui/mark.dart';
export 'ui/rx_builder.dart';
