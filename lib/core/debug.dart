import 'rx.dart';
import 'computed.dart';
import 'logger.dart';

/// Debug mode configuration
class DebugMode {
  static bool _enabled = false;
  static bool _verboseLogging = false;
  static bool _trackDependencies = false;
  static final Map<String, dynamic> _debugInfo = {};

  /// Enable debug mode
  static void enable({bool verboseLogging = false, bool trackDependencies = false}) {
    _enabled = true;
    _verboseLogging = verboseLogging;
    _trackDependencies = trackDependencies;
    Logger.setEnabled(true);
    Logger.setLevel(verboseLogging ? LogLevel.debug : LogLevel.info);
  }

  /// Disable debug mode
  static void disable() {
    _enabled = false;
    _verboseLogging = false;
    _trackDependencies = false;
    Logger.setEnabled(false);
  }

  /// Check if debug mode is enabled
  static bool get isEnabled => _enabled;

  /// Check if verbose logging is enabled
  static bool get isVerboseLogging => _verboseLogging;

  /// Check if dependency tracking is enabled
  static bool get isTrackingDependencies => _trackDependencies;

  /// Set debug info
  static void setInfo(String key, dynamic value) {
    _debugInfo[key] = value;
  }

  /// Get debug info
  static dynamic getInfo(String key) => _debugInfo[key];

  /// Get all debug info
  static Map<String, dynamic> getAllInfo() => Map.unmodifiable(_debugInfo);

  /// Clear debug info
  static void clearInfo() {
    _debugInfo.clear();
  }

  /// Get dependency graph for debugging
  static Map<String, dynamic> getDependencyGraph() {
    if (!_trackDependencies) {
      return {'error': 'Dependency tracking is disabled'};
    }

    // Note: Accessing private members is not possible
    // This would require exposing public APIs in MarkRegistry and ComputedTrackerRegistry
    // For now, return basic info
    return {
      'note': 'Full dependency graph requires public APIs in MarkRegistry and ComputedTrackerRegistry',
      'trackingEnabled': _trackDependencies,
    };
  }
}

/// Enhanced logger with context
class DebugLogger {
  /// Log with context
  static void logWithContext(
    String message, {
    Object? data,
    Map<String, dynamic>? context,
    LogLevel level = LogLevel.debug,
  }) {
    if (!DebugMode.isEnabled) return;

    final fullMessage = context != null
        ? '$message | Context: $context'
        : message;

    switch (level) {
      case LogLevel.debug:
        Logger.debug(fullMessage, data);
      case LogLevel.info:
        Logger.info(fullMessage, data);
      case LogLevel.warning:
        Logger.warning(fullMessage, data);
      case LogLevel.error:
        Logger.error(fullMessage, data);
    }
  }

  /// Log Rx value change
  static void logRxChange<T>(SwiftValue<T> rx, T oldValue, T newValue) {
    if (!DebugMode.isVerboseLogging) return;
    logWithContext(
      'Rx value changed',
      data: {'old': oldValue, 'new': newValue},
      context: {'type': rx.runtimeType.toString()},
    );
  }

  /// Log computed recomputation
  static void logComputedRecompute<T>(Computed<T> computed) {
    if (!DebugMode.isVerboseLogging) return;
    logWithContext(
      'Computed value recomputed',
      context: {'type': computed.runtimeType.toString()},
    );
  }

  /// Log dependency registration
  static void logDependencyRegistration(
    String dependent,
    String dependency,
  ) {
    if (!DebugMode.isTrackingDependencies) return;
    logWithContext(
      'Dependency registered',
      context: {
        'dependent': dependent,
        'dependency': dependency,
      },
    );
  }
}

