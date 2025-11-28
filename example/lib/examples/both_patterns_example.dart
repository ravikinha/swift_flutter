import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

/// Example showing BOTH patterns - Use the right one for your needs:
/// 
/// 1. DIRECT PATTERN: Use swift() directly in views for view-local state
///    - Simple UI state (toggle, local counter, etc.)
///    - View-only variables that don't need business logic
///    - Quick prototypes
/// 
/// 2. CONTROLLER PATTERN: Use SwiftController for business logic
///    - Shared state across multiple views
///    - Complex state management
///    - Business logic and validation
///    - Team projects (enforced separation)

class BothPatternsExample extends StatefulWidget {
  const BothPatternsExample({super.key});

  @override
  State<BothPatternsExample> createState() => _BothPatternsExampleState();
}

// ============================================
// PATTERN 1: DIRECT - Use for view-local state
// ============================================
class _DirectPatternExample extends StatefulWidget {
  const _DirectPatternExample();

  @override
  State<_DirectPatternExample> createState() => _DirectPatternExampleState();
}

class _DirectPatternExampleState extends State<_DirectPatternExample> {
  // ✅ Use swift() directly in views for view-local state
  // Perfect for: UI toggles, local counters, form inputs, etc.
  final counter = swift(0);
  final name = swift('Direct Pattern');

  @override
  void dispose() {
    counter.dispose();
    name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ DIRECT PATTERN (View-Local State)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use for: View-local state, simple UI, quick prototypes',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Swift(
              builder: (context) => Text(
                'Counter: ${counter.value}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Swift(
              builder: (context) => Text(
                'Name: ${name.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () => counter.value--, // ✅ Direct modification
                  child: const Text('-'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => counter.value++, // ✅ Direct modification
                  child: const Text('+'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => name.value = 'Updated: ${DateTime.now().second}', // ✅ Direct modification
                  child: const Text('Update'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// PATTERN 2: CONTROLLER - Use for business logic & shared state
// ============================================
class _ControllerPatternExample extends StatefulWidget {
  const _ControllerPatternExample();

  @override
  State<_ControllerPatternExample> createState() => _ControllerPatternExampleState();
}

/// Controller - Use for business logic, shared state, complex state management
/// ✅ No ReadOnlyRx getters needed! Just use swift() directly.
class ControllerPatternController extends SwiftController {
  // ✅ Just use swift() - automatically read-only from views!
  // Perfect for: Business logic, shared state, validation, team projects
  final counter = swift(0);
  final name = swift('Controller Pattern');
  
  void decrement() => counter.value--;
  void increment() => counter.value++;
  void updateName() => name.value = 'Updated: ${DateTime.now().second}';
}

class _ControllerPatternExampleState extends State<_ControllerPatternExample> {
  late final ControllerPatternController controller;

  @override
  void initState() {
    super.initState();
    controller = ControllerPatternController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '✅ CONTROLLER PATTERN (Business Logic)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use for: Business logic, shared state, team projects',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            Swift(
              builder: (context) => Text(
                'Counter: ${controller.counter.value}',
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 8),
            Swift(
              builder: (context) => Text(
                'Name: ${controller.name.value}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: controller.decrement, // ✅ Call controller method
                  child: const Text('-'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.increment, // ✅ Call controller method
                  child: const Text('+'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: controller.updateName, // ✅ Call controller method
                  child: const Text('Update'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              '❌ controller.counter.value = 10; // Runtime error - cannot modify from view',
              style: TextStyle(fontSize: 10, color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// MAIN WIDGET - Shows both patterns
// ============================================
class _BothPatternsExampleState extends State<BothPatternsExample> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Both Patterns Available - Choose the Right One!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Use the pattern that fits your use case:',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📱 DIRECT PATTERN (swift() in views)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• View-local state (toggles, local counters)', style: TextStyle(fontSize: 12)),
              Text('• Simple UI state', style: TextStyle(fontSize: 12)),
              Text('• Quick prototypes', style: TextStyle(fontSize: 12)),
              Text('• Single view usage', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '🎯 CONTROLLER PATTERN (SwiftController)',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text('• Business logic & validation', style: TextStyle(fontSize: 12)),
              Text('• Shared state across views', style: TextStyle(fontSize: 12)),
              Text('• Complex state management', style: TextStyle(fontSize: 12)),
              Text('• Team projects (enforced separation)', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const _DirectPatternExample(),
        const SizedBox(height: 16),
        const _ControllerPatternExample(),
      ],
    );
  }
}

