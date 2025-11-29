import 'package:flutter/material.dart';
import 'package:swift_flutter/main.dart';
import 'package:swift_flutter/swift_flutter.dart';
import 'examples/rx_example.dart';
import 'examples/computed_example.dart';
import 'examples/swift_future_example.dart';
import 'examples/form_validation_example.dart';
import 'examples/transaction_example.dart';
import 'examples/tween_example.dart';
import 'examples/lifecycle_example.dart';
import 'examples/persistence_example.dart';
import 'examples/store_example.dart';
import 'examples/logger_example.dart';
import 'examples/extensions_example.dart';
import 'examples/currency_example.dart';
import 'examples/devtools_example.dart';
import 'examples/controller_example.dart';
import 'examples/both_patterns_example.dart';
import 'examples/animate_example.dart';

void main() {
  // Enable logger for debugging
  Logger.setEnabled(true);
  Logger.setLevel(LogLevel.debug);

  // Enable DevTools for visual debugging
  SwiftDevTools.enable(
    trackDependencies: true,
    trackStateHistory: true,
    trackPerformance: true,
  );

  // Register middleware
  store.addMiddleware(LoggingMiddleware());

  runApp(const SwiftFlutterExampleApp());
}

class SwiftFlutterExampleApp extends StatelessWidget {
  const SwiftFlutterExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Swift Flutter Examples',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const ExampleHomePage(),
    );
  }
}

class ExampleHomePage extends StatelessWidget {
  const ExampleHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swift Flutter - All Features'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            tooltip: 'Open DevTools',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SwiftDevToolsUI(),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // DevTools UI Card - Prominent placement
          Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 6,
            color: Colors.blue.shade50,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SwiftDevToolsUI(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bug_report,
                        color: Colors.white,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '🔧 Visual DevTools UI',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Open comprehensive visual debugging tools',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.blue,
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildFeatureCard(
            context,
            '1. Reactive State (Rx)',
            const RxExample(),
            Colors.blue,
          ),
          _buildFeatureCard(
            context,
            '2. Computed (Derived State)',
            const ComputedExample(),
            Colors.green,
          ),
          _buildFeatureCard(
            context,
            '3. SwiftFuture (Async State)',
            const SwiftFutureExample(),
            Colors.orange,
          ),
          _buildFeatureCard(
            context,
            '4. Form Validation',
            const FormValidationExample(),
            Colors.purple,
          ),
          _buildFeatureCard(
            context,
            '5. Transactions (Batch Updates)',
            const TransactionExample(),
            Colors.red,
          ),
          _buildFeatureCard(
            context,
            '6. Animation Tween',
            const TweenExample(),
            Colors.pink,
          ),
          _buildFeatureCard(
            context,
            '7. Lifecycle Controller',
            const LifecycleExample(),
            Colors.teal,
          ),
          _buildFeatureCard(
            context,
            '8. Persistence',
            const PersistenceExample(),
            Colors.indigo,
          ),
          _buildFeatureCard(
            context,
            '9. Global Store / DI',
            const StoreExample(),
            Colors.amber,
          ),
          _buildFeatureCard(
            context,
            '10. Logger',
            const LoggerExample(),
            Colors.cyan,
          ),
          _buildFeatureCard(
            context,
            '11. Swift-like Extensions',
            const ExtensionsExample(),
            Colors.deepPurple,
          ),
          _buildFeatureCard(
            context,
            '12. Currency Extensions',
            const CurrencyExample(),
            Colors.brown,
          ),
          _buildFeatureCard(
            context,
            '13. DevTools Integration',
            const DevToolsExample(),
            Colors.deepOrange,
          ),
          _buildFeatureCard(
            context,
            '14. Controller Pattern (Read-Only Views)',
            const ControllerExample(),
            Colors.lime,
          ),
          _buildFeatureCard(
            context,
            '15. Both Patterns Comparison',
            const BothPatternsExample(),
            Colors.amber,
          ),
          _buildFeatureCard(
            context,
            '16. SwiftUI-like Animations',
            const AnimateExample(),
            Colors.deepPurple,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    String title,
    Widget example,
    Color color,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: example,
          ),
        ],
      ),
    );
  }
}
