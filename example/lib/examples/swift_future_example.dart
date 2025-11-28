import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// SwiftFuture (Async State) Example
class SwiftFutureExample extends StatefulWidget {
  const SwiftFutureExample({super.key});

  @override
  State<SwiftFutureExample> createState() => _SwiftFutureExampleState();
}

class _SwiftFutureExampleState extends State<SwiftFutureExample> {
  // SwiftFuture is a specialized class for async operations
  // It's different from Rx<T> - it manages loading/error/success states
  final swiftFuture = SwiftFuture<String>();

  Future<String> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    // Always return success for demo
    return 'Success! Data loaded at ${DateTime.now().toString().substring(11, 19)}';
  }
  
  Future<String> _fetchDataWithError() async {
    await Future.delayed(const Duration(seconds: 2));
    throw Exception('Simulated error for testing');
  }

  @override
  void dispose() {
    swiftFuture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Swift(
          builder: (context) => swiftFuture.value.when(
            idle: () => const Text('Click to load data', style: TextStyle(fontSize: 16)),
            loading: () => const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text('Loading...', style: TextStyle(fontSize: 16)),
              ],
            ),
            success: (data) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(data, style: const TextStyle(fontSize: 16)),
            ),
            error: (error, stack) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Error: $error', style: const TextStyle(fontSize: 16)),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => swiftFuture.execute(_fetchData),
              child: const Text('Load Data'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => swiftFuture.execute(_fetchDataWithError),
              child: const Text('Test Error'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => swiftFuture.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

