import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Reactive State (Rx) Example - Using Controller Pattern
class RxExample extends StatefulWidget {
  const RxExample({super.key});

  @override
  State<RxExample> createState() => _RxExampleState();
}

/// Controller for managing reactive state
/// ✅ No ReadOnlyRx getters needed! Just use swift() directly.
class RxExampleController extends SwiftController {
  // ✅ Just use swift() - automatically read-only from views!
  final counter = swift(0);  // Automatically inferred as ControllerRx<int>
  final name = swift('Swift Flutter');  // Automatically inferred as ControllerRx<String>
  
  // Or use explicit typing if you prefer:
  // final counter = swift<int>(0);
  // final name = swift<String>('Swift Flutter');
  
  // Methods to update state - only controllers can modify
  void decrement() => counter.value--;
  void increment() => counter.value++;
  void updateName() => name.value = 'Updated: ${DateTime.now().second}';
}

class _RxExampleState extends State<RxExample> {
  late final RxExampleController controller;

  @override
  void initState() {
    super.initState();
    controller = RxExampleController();
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
          'Reactive State Example (with Controller Pattern)',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Note: SwiftFuture, SwiftField, SwiftTween, SwiftPersisted are specialized classes',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
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
        const SizedBox(height: 16),
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
              onPressed: controller.updateName,
              child: const Text('Update Name'),
            ),
          ],
        ),
      ],
    );
  }
}

