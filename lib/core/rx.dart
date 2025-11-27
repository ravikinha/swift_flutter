import 'package:flutter/foundation.dart';
import '../ui/mark.dart';
import 'computed.dart';
import 'transaction.dart';
import 'performance_monitor.dart';
import 'devtools.dart' show SwiftDevTools;

/// Reactive state container that automatically tracks dependencies
class Rx<T> extends ChangeNotifier {
  T _value;
  String? _devToolsName;
  
  /// Constructor - type is automatically inferred from the value
  Rx(this._value, {String? name}) : _devToolsName = name {
    // Zero overhead: only track if DevTools is enabled
    if (SwiftDevTools.isEnabled) {
      SwiftDevTools.trackRxCreation(this, _devToolsName);
    }
  }
  
  /// Factory constructor for automatic type inference.
  ///
  /// Usage: `Rx.of(0)` instead of `Rx<int>(0)`.
  factory Rx.of(T value) => Rx<T>(value);

  /// Gets the current value and registers this Rx as a dependency
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
          SwiftDevTools.getRxId(this),
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
        SwiftDevTools.getRxId(this),
        oldValue,
        newValue,
      );
      if (SwiftDevTools.isTrackingPerformance) {
        SwiftDevTools.trackPerformanceEvent(
          _devToolsName ?? runtimeType.toString(),
          stopwatch.elapsed,
          {'type': 'RxUpdate'},
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

/// Creates an Rx with optional type inference.
///
/// Usage with automatic inference: `swift(0)` creates `Rx<int>`.
/// Usage with explicit type: `swift<int>(0)` creates `Rx<int>`.
/// Usage for models: `swift<MyModel>(myModel)` creates `Rx<MyModel>`.
///
/// Example:
/// ```dart
/// final counter = swift(0);        // Automatically Rx<int>
/// final name = swift('Hello');     // Automatically Rx<String>
/// final user = swift<User>(user);  // Explicit type for models
/// ```
Rx<T> swift<T>(T value, {String? name}) => Rx<T>(value, name: name);

