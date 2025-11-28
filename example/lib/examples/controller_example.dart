import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// SwiftController Example - Enforcing separation of concerns
///
/// This example demonstrates the controller pattern where:
/// - Controllers extend SwiftController and manage state
/// - Views can only read state (through ReadOnlyRx) and call controller methods
/// - State can only be modified within controllers, not from views
class ControllerExample extends StatefulWidget {
  const ControllerExample({super.key});

  @override
  State<ControllerExample> createState() => _ControllerExampleState();
}

/// Counter Controller - Only controllers can modify state
/// 
/// ✅ No need for ReadOnlyRx getters! Just use swift() directly.
class CounterController extends SwiftController {
  // ✅ Just use swift() - automatically read-only from views!
  final counter = swift(0);
  final name = swift('Swift Flutter');

  /// Update value - only controllers can call this
  void valueUpdateOfA() {
    counter.value = 10;
  }

  /// Increment value
  void increment() {
    counter.value++;
  }

  /// Decrement value
  void decrement() {
    counter.value--;
  }

  /// Update name
  void updateName(String newName) {
    name.value = newName;
  }

  /// Reset to initial values
  void reset() {
    counter.value = 0;
    name.value = 'Swift Flutter';
  }
}

/// View - Can only read state and call controller methods
class _ControllerExampleState extends State<ControllerExample> {
  late final CounterController controller;

  @override
  void initState() {
    super.initState();
    controller = CounterController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Controller Pattern Example',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Views can only read state and call controller methods.',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 8),
        const Text(
          'State can only be modified within controllers.',
          style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 24),
        // ✅ Views can read state directly - no getters needed!
        Swift(
          builder: (context) => Text(
            'Counter: ${controller.counter.value}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Swift(
          builder: (context) => Text(
            'Name: ${controller.name.value}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 24),
        // ✅ Views can call controller methods
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: controller.decrement,
              child: const Text('-'),
            ),
            ElevatedButton(
              onPressed: controller.increment,
              child: const Text('+'),
            ),
            ElevatedButton(
              onPressed: controller.valueUpdateOfA,
              child: const Text('Set to 10'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () =>
                  controller.updateName('Updated: ${DateTime.now().second}'),
              child: const Text('Update Name'),
            ),
            ElevatedButton(
              onPressed: controller.reset,
              child: const Text('Reset'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Note: The following would cause a runtime error:',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 4),
        const Text(
          '// controller.counter.value = 10;  ❌ Runtime error - cannot modify from view',
          style: TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }
}
