import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Reactive State (Rx) Example
class RxExample extends StatefulWidget {
  const RxExample({super.key});

  @override
  State<RxExample> createState() => _RxExampleState();
}

class _RxExampleState extends State<RxExample> {
  // Using swift() helper for automatic type inference
  // swift() creates Rx<T> instances - cleaner than Rx<int>(0)
  final counter = swift(0);  // Automatically inferred as Rx<int>
  final name = swift('Swift Flutter');  // Automatically inferred as Rx<String>
  
  // Or use explicit typing if you prefer:
  // final counter = swift<int>(0);
  // final name = swift<String>('Swift Flutter');
  
  // Note: SwiftFuture, SwiftField, SwiftTween, SwiftPersisted are different classes
  // They are specialized wrappers, not Rx<T> instances
  // They use the Swift prefix to match the library naming convention

  @override
  void dispose() {
    counter.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mark(
          builder: (context) => Text(
            'Counter: ${counter.value}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8),
        Mark(
          builder: (context) => Text(
            'Name: ${name.value}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => counter.value--,
              child: const Text('-'),
            ),
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('+'),
            ),
            ElevatedButton(
              onPressed: () => name.value = 'Updated: ${DateTime.now().second}',
              child: const Text('Update Name'),
            ),
          ],
        ),
      ],
    );
  }
}

