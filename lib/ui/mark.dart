import 'package:flutter/material.dart';

/// Internal state interface for Mark widget
abstract class MarkState {
  /// Register a ChangeNotifier as a dependency
  void register(ChangeNotifier controller);
}

/// Registry for tracking active Mark widgets (stack-based for nested support)
class MarkRegistry {
  static final List<MarkState> _stack = [];

  static MarkState? get current => 
    _stack.isNotEmpty ? _stack.last : null;

  static void push(MarkState mark) => _stack.add(mark);
  static void pop() => _stack.removeLast();
}

/// Widget that automatically rebuilds when its reactive dependencies change.
///
/// Wrap any widget that depends on reactive state (Rx, Computed, etc.) with Mark
/// to enable automatic rebuilds when dependencies change.
///
/// Example:
/// ```dart
/// final counter = swift(0);
///
/// Mark(
///   builder: (context) => Text('Count: ${counter.value}'),
/// )
/// ```
class Mark extends StatefulWidget {
  /// Builder function that creates the widget
  final Widget Function(BuildContext) builder;
  
  /// Creates a Mark widget
  const Mark({super.key, required this.builder});

  @override
  State<Mark> createState() => _MarkState();
}

class _MarkState extends State<Mark> implements MarkState {
  final Set<ChangeNotifier> dependencies = {};

  @override
  void register(ChangeNotifier controller) {
    if (!dependencies.contains(controller)) {
      dependencies.add(controller);
      controller.addListener(_rebuild);
    }
  }

  void _rebuild() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (var c in dependencies) {
      c.removeListener(_rebuild);
    }
    dependencies.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Clear previous dependencies
    for (var c in dependencies) {
      c.removeListener(_rebuild);
    }
    dependencies.clear();

    // Push this mark onto the stack
    MarkRegistry.push(this);

    try {
      return widget.builder(context);
    } finally {
      // Pop this mark from the stack
      MarkRegistry.pop();
    }
  }
}
