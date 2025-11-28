/// A reactive state management library for Flutter with automatic dependency tracking.
///
/// This is the main entry point for the swift_flutter package.
/// Import this library to access all core features.
///
/// For optional features (Currency, Extensions), import them separately:
/// ```dart
/// import 'package:swift_flutter/swift_flutter.dart';
/// import 'package:swift_flutter/core/currency.dart'; // Optional
/// import 'package:swift_flutter/core/extensions.dart'; // Optional
/// ```
///
/// For enterprise features, import them as needed:
/// ```dart
/// import 'package:swift_flutter/core/error_tracking.dart'; // Error tracking
/// import 'package:swift_flutter/core/encryption.dart'; // Encryption
/// import 'package:swift_flutter/core/audit_logging.dart'; // Audit logging
/// import 'package:swift_flutter/core/multi_tenant.dart'; // Multi-tenant
/// import 'package:swift_flutter/core/caching.dart'; // Advanced caching
/// import 'package:swift_flutter/core/offline.dart'; // Offline-first
/// import 'package:swift_flutter/core/analytics.dart'; // Analytics
/// import 'package:swift_flutter/core/ab_testing.dart'; // A/B testing
/// import 'package:swift_flutter/core/realtime_sync.dart'; // Real-time sync
/// ```
library;

// Core
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

// Enterprise Features (import separately as needed)
// export 'core/error_tracking.dart';
// export 'core/encryption.dart';
// export 'core/audit_logging.dart';
// export 'core/multi_tenant.dart';
// export 'core/caching.dart';
// export 'core/offline.dart';
// export 'core/analytics.dart';
// export 'core/ab_testing.dart';
// export 'core/realtime_sync.dart';

// Extensions and Currency are optional - import separately if needed
// export 'core/extensions.dart';
// export 'core/currency.dart';

// Store
export 'store/store.dart';
export 'store/middleware.dart' hide Action; // Hide middleware Action to avoid conflict with reducers Action
export 'core/reducers.dart' show ReduxStore, Reducer, Action, combineReducers, applyMiddleware, ReduxMiddleware;

// UI
export 'ui/mark.dart';
export 'ui/rx_builder.dart';
