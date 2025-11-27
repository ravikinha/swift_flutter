import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

/// Registry for tracking active Mark widgets (stack-based for nested support)
class MarkRegistry {
  static final List<_MarkState> _stack = [];

  static _MarkState? get current => 
    _stack.isNotEmpty ? _stack.last : null;

  static void push(_MarkState mark) => _stack.add(mark);
  static void pop() => _stack.removeLast();
}

/// Widget that automatically rebuilds when its reactive dependencies change
class Mark extends StatefulWidget {
  final Widget Function(BuildContext) builder;
  
  const Mark({super.key, required this.builder});

  @override
  State<Mark> createState() => _MarkState();
}

class _MarkState extends State<Mark> {
  final Set<ChangeNotifier> dependencies = {};

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

