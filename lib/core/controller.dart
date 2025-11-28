import 'package:flutter/foundation.dart';
import 'rx.dart';
import '../ui/mark.dart';
import 'computed.dart';
import 'devtools.dart' show SwiftDevTools;

/// Registry to track the current controller context
class ControllerRegistry {
  static final List<SwiftController> _stack = [];
  
  static SwiftController? get current => 
    _stack.isNotEmpty ? _stack.last : null;
  
  static void push(SwiftController controller) => _stack.add(controller);
  static void pop() => _stack.removeLast();
  
  static bool isInController(SwiftController? controller) {
    if (controller == null) return false;
    return _stack.contains(controller);
  }
}

/// Special SwiftValue type for controllers that automatically becomes read-only from views
class ControllerRx<T> extends SwiftValue<T> {
  final SwiftController _controller;
  
  ControllerRx(super.value, this._controller, {super.name}) {
    // Register with controller for automatic disposal
    _controller.registerRx(this);
  }
  
  /// Getter - works everywhere (read access is always allowed)
  @override
  T get value => super.value;
  
  /// Setter that only works inside controller
  /// Throws error if called from outside the controller
  @override
  set value(T newValue) {
    final currentController = ControllerRegistry.current;
    if (currentController != _controller) {
      throw StateError(
        'Cannot modify ControllerRx from outside its controller. '
        'Use controller methods to update state.\n'
        'Example: controller.increment() instead of controller.counter.value = 10'
      );
    }
    super.value = newValue;
  }
}

/// Read-only wrapper for Rx that prevents direct state mutation from views.
/// 
/// Views can only read state values. Only controllers can modify state.
/// 
/// Example:
/// ```dart
/// class CounterController extends SwiftController {
///   // ✅ Just use swift() - automatically read-only from views!
///   final count = swift(0);
///   
///   void increment() => count.value++;
/// }
/// ```
class ReadOnlyRx<T> extends ChangeNotifier {
  final SwiftValue<T> _swift;
  
  ReadOnlyRx(this._swift) {
    // Forward notifications from the underlying SwiftValue
    _swift.addListener(notifyListeners);
  }
  
  /// Gets the current value and registers this as a dependency
  /// Views can only read, not modify
  T get value {
    // Check for computed tracker first
    final computedTracker = ComputedTrackerRegistry.current;
    if (computedTracker != null) {
      computedTracker.dependencies.add(_swift);
    }
    
    // Then check for mark widget
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(_swift);
    }
    
    return _swift.value;
  }
  
  /// Gets the value without registering as dependency (for internal use)
  T get rawValue => _swift.rawValue;
  
  @override
  void dispose() {
    _swift.removeListener(notifyListeners);
    super.dispose();
  }
  
  @override
  String toString() => _swift.toString();
}

/// Base class for controllers that manage state.
/// 
/// Controllers are the only place where state can be modified.
/// Views can only read state - values are automatically read-only from views.
/// 
/// Example:
/// ```dart
/// class CounterController extends SwiftController {
///   // Just use swift() - automatically read-only from views!
///   final counter = swift(0);
///   final name = swift('Hello');
///   
///   // Only controllers can modify state
///   void increment() => counter.value++;
///   void updateName(String n) => name.value = n;
/// }
/// 
/// // In view:
/// class MyView extends StatefulWidget {
///   @override
///   Widget build(BuildContext context) {
///     final controller = CounterController();
///     return Swift(
///       builder: (context) => Text('${controller.counter.value}'),
///     );
///     // ✅ Can read: controller.counter.value
///     // ✅ Can call: controller.increment()
///     // ❌ Cannot modify: controller.counter.value = 10 (runtime error)
///   }
/// }
/// ```
abstract class SwiftController extends ChangeNotifier {
  final Set<SwiftValue<dynamic>> _managedSwift = {};
  final Set<ReadOnlyRx<dynamic>> _readOnlyRx = {};
  bool _disposed = false;
  
  /// Constructor
  SwiftController() {
    ControllerRegistry.push(this);
    if (SwiftDevTools.isEnabled) {
      SwiftDevTools.trackControllerCreation(this);
    }
  }
  
  /// Create a swift value that's automatically read-only from views
  /// Use this instead of the global swift() function in controllers
  ControllerRx<T> swift<T>(T value, {String? name}) {
    return ControllerRx<T>(value, this, name: name);
  }
  
  /// Register a SwiftValue to be automatically disposed
  /// This is optional - you can manage disposal manually if preferred
  @protected
  void registerRx<T>(SwiftValue<T> swift) {
    if (_disposed) {
      throw StateError('Cannot register SwiftValue in disposed controller');
    }
    _managedSwift.add(swift);
  }
  
  /// Register a ReadOnlyRx to be automatically disposed
  @protected
  void registerReadOnlyRx<T>(ReadOnlyRx<T> readOnlyRx) {
    if (_disposed) {
      throw StateError('Cannot register ReadOnlyRx in disposed controller');
    }
    _readOnlyRx.add(readOnlyRx);
  }
  
  /// Create a read-only wrapper for a SwiftValue
  /// This is a convenience method that also registers it for disposal
  @protected
  ReadOnlyRx<T> readOnly<T>(SwiftValue<T> swift) {
    final readOnly = ReadOnlyRx(swift);
    registerReadOnlyRx(readOnly);
    return readOnly;
  }
  
  @override
  void dispose() {
    if (_disposed) return;
    _disposed = true;
    
    // Remove from registry
    ControllerRegistry._stack.remove(this);
    
    // Dispose all ReadOnlyRx wrappers
    for (var readOnly in _readOnlyRx) {
      readOnly.dispose();
    }
    _readOnlyRx.clear();
    
    // Dispose all managed SwiftValue instances
    for (var swift in _managedSwift) {
      swift.dispose();
    }
    _managedSwift.clear();
    
    if (SwiftDevTools.isEnabled) {
      SwiftDevTools.trackControllerDisposal(this);
    }
    
    super.dispose();
  }
  
  /// Check if controller is disposed
  bool get isDisposed => _disposed;
}

