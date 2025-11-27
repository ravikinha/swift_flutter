import 'package:flutter/foundation.dart';
import 'rx.dart';
import '../ui/mark.dart';

/// Computed value that automatically updates when dependencies change
class Computed<T> extends ChangeNotifier {
  T? _value;
  final T Function() _compute;
  final Set<Rx<dynamic>> _dependencies = {};
  final Set<Computed<dynamic>> _computedDependencies = {};
  bool _isDirty = true;

  Computed(this._compute) {
    _updateDependencies();
  }

  /// Gets the computed value
  T get value {
    if (_isDirty) {
      _recompute();
    }
    // Register with ComputedTracker if we're inside another Computed
    final computedTracker = ComputedTrackerRegistry.current;
    if (computedTracker != null) {
      computedTracker.computedDependencies.add(this);
    }
    
    // Register with Mark widget if active
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(this);
    }
    return _value as T;
  }

  void _updateDependencies() {
    // Clear old listeners
    for (var dep in _dependencies) {
      dep.removeListener(_markDirty);
    }
    _dependencies.clear();

    // Track dependencies during computation
    final tracker = ComputedTracker();
    ComputedTrackerRegistry.push(tracker);

    try {
      _value = _compute();
      _dependencies.addAll(tracker.rxDependencies);
      
      // Clear old computed dependencies
      for (var computedDep in _computedDependencies) {
        computedDep.removeListener(_markDirty);
      }
      _computedDependencies.clear();
      
      // Track new Computed dependencies
      _computedDependencies.addAll(tracker.computedDependencies);
      for (var computedDep in _computedDependencies) {
        computedDep.addListener(_markDirty);
      }
    } finally {
      ComputedTrackerRegistry.pop();
    }

    // Add listeners to new Rx dependencies
    for (var dep in _dependencies) {
      dep.addListener(_markDirty);
    }
    _isDirty = false;
  }

  void _markDirty() {
    if (!_isDirty) {
      _isDirty = true;
      notifyListeners();
    }
  }

  void _recompute() {
    _updateDependencies();
  }

  @override
  void dispose() {
    if (_isDirty && _dependencies.isEmpty && _computedDependencies.isEmpty) {
      // Already disposed
      return;
    }
    for (var dep in _dependencies) {
      dep.removeListener(_markDirty);
    }
    for (var computedDep in _computedDependencies) {
      computedDep.removeListener(_markDirty);
    }
    _dependencies.clear();
    _computedDependencies.clear();
    _isDirty = true;
    super.dispose();
  }
}

/// Tracker for computed dependencies
class _ComputedTracker {
  final Set<Rx<dynamic>> rxDependencies = {};
  final Set<Computed<dynamic>> computedDependencies = {};
  
  Set<Rx<dynamic>> get dependencies => rxDependencies;
}

/// Registry for computed trackers (stack-based)
class ComputedTrackerRegistry {
  static final List<_ComputedTracker> _stack = [];

  static _ComputedTracker? get current => 
    _stack.isNotEmpty ? _stack.last : null;

  static void push(_ComputedTracker tracker) => _stack.add(tracker);
  static void pop() => _stack.removeLast();
}


