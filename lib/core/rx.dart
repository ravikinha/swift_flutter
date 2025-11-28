import 'package:flutter/foundation.dart';
import '../ui/mark.dart';
import 'computed.dart';
import 'transaction.dart';
import 'performance_monitor.dart';
import 'devtools.dart' show SwiftDevTools;

/// Reactive state container that automatically tracks dependencies
class SwiftValue<T> extends ChangeNotifier {
  T _value;
  String? _devToolsName;
  
  /// Constructor - type is automatically inferred from the value
  SwiftValue(this._value, {String? name}) : _devToolsName = name {
    // Zero overhead: only track if DevTools is enabled
    if (SwiftDevTools.isEnabled) {
      SwiftDevTools.trackSwiftCreation(this, _devToolsName);
    }
  }
  
  /// Factory constructor for automatic type inference.
  ///
  /// Usage: `SwiftValue.of(0)` instead of `SwiftValue<int>(0)`.
  factory SwiftValue.of(T value) => SwiftValue<T>(value);

  /// Gets the current value and registers this SwiftValue as a dependency
  T get value {
    // Check for computed tracker first
    final computedTracker = ComputedTrackerRegistry.current;
    if (computedTracker != null) {
      computedTracker.dependencies.add(this);
      // Zero overhead: only track if DevTools is enabled
      if (SwiftDevTools.isEnabled && SwiftDevTools.isTrackingDependencies) {
        // Note: ComputedTracker doesn't have ID, skip for now
        // DevTools extension can infer from stack
      }
    }
    
    // Then check for mark widget
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(this);
      // Zero overhead: only track if DevTools is enabled
      if (SwiftDevTools.isEnabled && SwiftDevTools.isTrackingDependencies) {
        SwiftDevTools.trackDependency(
          SwiftDevTools.getMarkId(mark),
          SwiftDevTools.getSwiftId(this),
        );
      }
    }
    return _value;
  }

  /// Sets a new value and notifies listeners if changed
  set value(T newValue) {
    if (_value == newValue) return;
    
    final oldValue = _value;
    final stopwatch = Stopwatch()..start();
    _value = newValue;
    notifyListenersTransaction();
    stopwatch.stop();
    
    // Zero overhead: only track if enabled
    if (PerformanceMonitor.isEnabled && stopwatch.elapsedMilliseconds > 0) {
      PerformanceMonitor.trackUpdate(
        runtimeType.toString(),
        stopwatch.elapsed,
      );
    }
    
    // Zero overhead: only track if DevTools is enabled
    if (SwiftDevTools.isEnabled) {
      SwiftDevTools.trackStateChange(
        SwiftDevTools.getSwiftId(this),
        oldValue,
        newValue,
      );
      if (SwiftDevTools.isTrackingPerformance) {
        SwiftDevTools.trackPerformanceEvent(
          _devToolsName ?? runtimeType.toString(),
          stopwatch.elapsed,
          {'type': 'SwiftUpdate'},
        );
      }
    }
  }

  /// Updates the value and notifies listeners if changed
  void update(T newValue) {
    if (_value == newValue) return;
    
    final stopwatch = Stopwatch()..start();
    _value = newValue;
    notifyListenersTransaction();
    stopwatch.stop();
    
    if (PerformanceMonitor.isEnabled && stopwatch.elapsedMilliseconds > 0) {
      PerformanceMonitor.trackUpdate(
        runtimeType.toString(),
        stopwatch.elapsed,
      );
    }
  }

  /// Gets the value without registering as dependency (for internal use)
  T get rawValue => _value;

  @override
  String toString() => _value.toString();
}

/// Creates a SwiftValue with optional type inference.
///
/// Usage with automatic inference: `swift(0)` creates `SwiftValue<int>`.
/// Usage with explicit type: `swift<int>(0)` creates `SwiftValue<int>`.
/// Usage for models: `swift<MyModel>(myModel)` creates `SwiftValue<MyModel>`.
///
/// Example:
/// ```dart
/// final counter = swift(0);        // Automatically SwiftValue<int>
/// final name = swift('Hello');     // Automatically SwiftValue<String>
/// final user = swift<User>(user);  // Explicit type for models
/// ```
SwiftValue<T> swift<T>(T value, {String? name}) => SwiftValue<T>(value, name: name);

/// Backward compatibility alias - Rx is now SwiftValue
@Deprecated('Use SwiftValue instead. Rx will be removed in a future version.')
typedef Rx<T> = SwiftValue<T>;

