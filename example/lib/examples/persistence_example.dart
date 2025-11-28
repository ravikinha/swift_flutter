import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Persistence Example
class PersistenceExample extends StatefulWidget {
  const PersistenceExample({super.key});

  @override
  State<PersistenceExample> createState() => _PersistenceExampleState();
}

class _PersistenceExampleState extends State<PersistenceExample> {
  // SwiftPersisted is a specialized class that extends Rx<T>
  // It automatically saves/loads values from storage
  late final SwiftPersisted<int> counter;
  final storage = MemoryStorage();

  @override
  void initState() {
    super.initState();
    // SwiftPersisted needs explicit type and storage configuration
    counter = SwiftPersisted<int>(0, 'example_counter', storage);
  }

  @override
  void dispose() {
    counter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Swift(
          builder: (context) => Text(
            'Persisted Counter: ${counter.value}',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'This value persists across app restarts (in memory for this example)',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => counter.value--,
              child: const Text('-'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => counter.value++,
              child: const Text('+'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => counter.clear(),
              child: const Text('Clear'),
            ),
          ],
        ),
      ],
    );
  }
}

