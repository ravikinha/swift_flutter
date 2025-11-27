import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Computed (Derived State) Example
class ComputedExample extends StatefulWidget {
  const ComputedExample({super.key});

  @override
  State<ComputedExample> createState() => _ComputedExampleState();
}

class _ComputedExampleState extends State<ComputedExample> {
  // Automatic type inference
  final price = swift(100.0);  // Automatically inferred as Rx<double>
  final quantity = swift(2);  // Automatically inferred as Rx<int>
  
  // Or use explicit typing:
  // final price = swift<double>(100.0);
  // final quantity = swift<int>(2);
  late final Computed<double> total;
  late final Computed<String> summary;

  @override
  void initState() {
    super.initState();
    total = Computed(() => price.value * quantity.value);
    summary = Computed(() => 'Total: \$${total.value.toStringAsFixed(2)}');
  }

  @override
  void dispose() {
    total.dispose();
    summary.dispose();
    price.dispose();
    quantity.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                children: [
                  const Text('Price:'),
                  Mark(
                    builder: (context) => Slider(
                      value: price.value,
                      min: 0,
                      max: 200,
                      onChanged: (v) => price.value = v,
                    ),
                  ),
                  Mark(
                    builder: (context) => Text('\$${price.value.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Quantity:'),
                  Mark(
                    builder: (context) => Slider(
                      value: quantity.value.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (v) => quantity.value = v.toInt(),
                    ),
                  ),
                  Mark(
                    builder: (context) => Text('${quantity.value}'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Mark(
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              summary.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

