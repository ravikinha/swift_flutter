import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Computed (Derived State) Example - Using Controller Pattern
class ComputedExample extends StatefulWidget {
  const ComputedExample({super.key});

  @override
  State<ComputedExample> createState() => _ComputedExampleState();
}

/// Controller for computed example
/// ✅ No ReadOnlyRx getters needed! Just use swift() directly.
class ComputedExampleController extends SwiftController {
  // ✅ Just use swift() - automatically read-only from views!
  final price = swift(100.0);  // Automatically inferred as ControllerRx<double>
  final quantity = swift(2);  // Automatically inferred as ControllerRx<int>
  
  // Or use explicit typing:
  // final price = swift<double>(100.0);
  // final quantity = swift<int>(2);
  
  late final Computed<double> total;
  late final Computed<String> summary;
  
  ComputedExampleController() {
    total = Computed(() => price.value * quantity.value);
    summary = Computed(() => 'Total: \$${total.value.toStringAsFixed(2)}');
  }
  
  // Methods to update state
  void setPrice(double value) => price.value = value;
  void setQuantity(int value) => quantity.value = value;
}

class _ComputedExampleState extends State<ComputedExample> {
  late final ComputedExampleController controller;

  @override
  void initState() {
    super.initState();
    controller = ComputedExampleController();
  }

  @override
  void dispose() {
    controller.total.dispose();
    controller.summary.dispose();
    controller.dispose();
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
                  Swift(
                    builder: (context) => Slider(
                      value: controller.price.value,
                      min: 0,
                      max: 200,
                      onChanged: controller.setPrice,
                    ),
                  ),
                  Swift(
                    builder: (context) => Text('\$${controller.price.value.toStringAsFixed(2)}'),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  const Text('Quantity:'),
                  Swift(
                    builder: (context) => Slider(
                      value: controller.quantity.value.toDouble(),
                      min: 0,
                      max: 10,
                      divisions: 10,
                      onChanged: (v) => controller.setQuantity(v.toInt()),
                    ),
                  ),
                  Swift(
                    builder: (context) => Text('${controller.quantity.value}'),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Swift(
          builder: (context) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              controller.summary.value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

