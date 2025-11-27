import 'package:flutter/foundation.dart';
import '../ui/mark.dart';
import 'computed.dart';
import 'transaction.dart';

/// Reactive state container that automatically tracks dependencies
class Rx<T> extends ChangeNotifier {
  T _value;
  
  /// Constructor - type is automatically inferred from the value
  Rx(this._value);
  
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
    }
    
    // Then check for mark widget
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(this);
    }
    return _value;
  }

  /// Sets a new value and notifies listeners if changed
  set value(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListenersTransaction();
  }

  /// Updates the value and notifies listeners if changed
  void update(T newValue) {
    if (_value == newValue) return;
    _value = newValue;
    notifyListenersTransaction();
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
Rx<T> swift<T>(T value) => Rx<T>(value);

