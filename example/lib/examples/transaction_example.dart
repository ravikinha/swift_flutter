import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Transaction (Batch Updates) Example
class TransactionExample extends StatefulWidget {
  const TransactionExample({super.key});

  @override
  State<TransactionExample> createState() => _TransactionExampleState();
}

class _TransactionExampleState extends State<TransactionExample> {
  // Automatic type inference
  final x = swift(0);
  final y = swift(0);
  final z = swift(0);
  int rebuildCount = 0;

  @override
  void initState() {
    super.initState();
    x.addListener(() => rebuildCount++);
    y.addListener(() => rebuildCount++);
    z.addListener(() => rebuildCount++);
  }

  @override
  void dispose() {
    x.dispose();
    y.dispose();
    z.dispose();
    super.dispose();
  }

  void _updateWithoutTransaction() {
    rebuildCount = 0;
    x.value = 10;
    y.value = 20;
    z.value = 30;
  }

  void _updateWithTransaction() {
    rebuildCount = 0;
    Transaction.run(() {
      x.value = 10;
      y.value = 20;
      z.value = 30;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mark(
          builder: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('X: ${x.value}'),
              Text('Y: ${y.value}'),
              Text('Z: ${z.value}'),
              const SizedBox(height: 8),
              Text(
                'Rebuilds: $rebuildCount',
                style: TextStyle(
                  color: rebuildCount > 1 ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            ElevatedButton(
              onPressed: _updateWithoutTransaction,
              child: const Text('Update (No Transaction)'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: _updateWithTransaction,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text('Update (With Transaction)'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Notice: Transaction batches updates into a single rebuild',
          style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
        ),
      ],
    );
  }
}

