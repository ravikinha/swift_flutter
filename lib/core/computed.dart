import 'package:flutter/foundation.dart';
import 'rx.dart';
import '../ui/mark.dart';
import 'logger.dart';

/// Computed value that automatically updates when dependencies change
class Computed<T> extends ChangeNotifier {
  T? _value;
  final T Function() _compute;
  final Set<Rx<dynamic>> _dependencies = {};
  final Set<Computed<dynamic>> _computedDependencies = {};
  bool _isDirty = true;
  bool _enableMemoization = false;
  Object? _lastMemoKey;
  final Set<Computed<dynamic>> _visitedInCycle = {};
  static final Set<Computed<dynamic>> _computingStack = {};

  /// Create a computed value
  /// 
  /// [enableMemoization] - If true, caches results when inputs haven't changed
  Computed(this._compute, {bool enableMemoization = false}) {
    _enableMemoization = enableMemoization;
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
    // Check for circular dependencies
    if (_computingStack.contains(this)) {
      final cycle = _computingStack.toList();
      cycle.add(this);
      Logger.error(
        'Circular dependency detected in Computed',
        'Cycle: ${cycle.map((c) => c.runtimeType).join(" -> ")}',
      );
      throw StateError(
        'Circular dependency detected in Computed. Cycle: ${cycle.map((c) => c.runtimeType).join(" -> ")}',
      );
    }

    // Clear old listeners
    for (var dep in _dependencies) {
      dep.removeListener(_markDirty);
    }
    _dependencies.clear();

    // Track dependencies during computation
    final tracker = ComputedTracker();
    ComputedTrackerRegistry.push(tracker);
    _computingStack.add(this);

    try {
      // Check memoization if enabled
      if (_enableMemoization) {
        final memoKey = _computeMemoKey();
        if (memoKey != null && memoKey == _lastMemoKey && !_isDirty) {
          // Value hasn't changed, skip recomputation
          _computingStack.remove(this);
          return;
        }
        _lastMemoKey = memoKey;
      }

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
      _computingStack.remove(this);
      ComputedTrackerRegistry.pop();
    }

    // Add listeners to new Rx dependencies
    for (var dep in _dependencies) {
      dep.addListener(_markDirty);
    }
    _isDirty = false;
  }

  /// Compute memoization key based on dependency values
  Object? _computeMemoKey() {
    if (_dependencies.isEmpty && _computedDependencies.isEmpty) {
      return null;
    }
    
    final keys = <Object?>[];
    for (var dep in _dependencies) {
      keys.add(dep.rawValue);
    }
    for (var computedDep in _computedDependencies) {
      keys.add(computedDep._value);
    }
    return keys;
  }

  void _markDirty() {
    if (!_isDirty) {
      _isDirty = true;
      // Invalidate memoization key
      if (_enableMemoization) {
        _lastMemoKey = null;
      }
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
class ComputedTracker {
  final Set<Rx<dynamic>> rxDependencies = {};
  final Set<Computed<dynamic>> computedDependencies = {};
  
  Set<Rx<dynamic>> get dependencies => rxDependencies;
}

/// Registry for computed trackers (stack-based)
class ComputedTrackerRegistry {
  static final List<ComputedTracker> _stack = [];

  static ComputedTracker? get current => 
    _stack.isNotEmpty ? _stack.last : null;

  static void push(ComputedTracker tracker) => _stack.add(tracker);
  static void pop() => _stack.removeLast();
}


