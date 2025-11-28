import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Lifecycle Controller Example
class LifecycleExample extends StatefulWidget {
  const LifecycleExample({super.key});

  @override
  State<LifecycleExample> createState() => _LifecycleExampleState();
}

class _LifecycleExampleState extends State<LifecycleExample> with LifecycleMixin {
  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForState(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'State: ${lifecycle.state.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Initialized: ${lifecycle.isInitialized}'),
                Text('Active: ${lifecycle.isActive}'),
                Text('Disposed: ${lifecycle.isDisposed}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => lifecycle.activate(),
                child: const Text('Activate'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => lifecycle.pause(),
                child: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => lifecycle.resume(),
                child: const Text('Resume'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForState() {
    switch (lifecycle.state) {
      case LifecycleState.initializing:
        return Colors.grey.shade300;
      case LifecycleState.initialized:
        return Colors.blue.shade100;
      case LifecycleState.active:
        return Colors.green.shade100;
      case LifecycleState.paused:
        return Colors.orange.shade100;
      default:
        return Colors.red.shade100;
    }
  }
}

