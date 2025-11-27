/// A reactive state management library for Flutter with automatic dependency tracking.
///
/// This is the main entry point for the swift_flutter package.
/// Import this library to access all features.
///
/// ```dart
/// import 'package:swift_flutter/swift_flutter.dart';
/// ```
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
export 'core/extensions.dart';
export 'core/currency.dart';

// Store
export 'store/store.dart';
export 'store/middleware.dart';

// UI
export 'ui/mark.dart';
export 'ui/rx_builder.dart';
