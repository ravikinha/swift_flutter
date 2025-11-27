import 'package:flutter/material.dart';
import 'package:swift_flutter/main.dart';


void main() {
  // Enable logger for debugging
  Logger.setEnabled(true);
  Logger.setLevel(LogLevel.debug);
  
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
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
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
            '3. RxFuture (Async State)',
            const RxFutureExample(),
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

// =======================================================
// 1. REACTIVE STATE (Rx) EXAMPLE
// =======================================================

class RxExample extends StatefulWidget {
  const RxExample({super.key});

  @override
  State<RxExample> createState() => _RxExampleState();
}

class _RxExampleState extends State<RxExample> {
  final counter = Rx<int>(0);
  final name = Rx<String>('Swift Flutter');

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

// =======================================================
// 2. COMPUTED (DERIVED STATE) EXAMPLE
// =======================================================

class ComputedExample extends StatefulWidget {
  const ComputedExample({super.key});

  @override
  State<ComputedExample> createState() => _ComputedExampleState();
}

class _ComputedExampleState extends State<ComputedExample> {
  final price = Rx<double>(100.0);
  final quantity = Rx<int>(2);
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

// =======================================================
// 3. RXFUTURE (ASYNC STATE) EXAMPLE
// =======================================================

class RxFutureExample extends StatefulWidget {
  const RxFutureExample({super.key});

  @override
  State<RxFutureExample> createState() => _RxFutureExampleState();
}

class _RxFutureExampleState extends State<RxFutureExample> {
  final rxFuture = RxFuture<String>();

  Future<String> _fetchData() async {
    await Future.delayed(const Duration(seconds: 2));
    if (DateTime.now().second % 2 == 0) {
      return 'Success! Data loaded at ${DateTime.now().toString().substring(11, 19)}';
    } else {
      throw Exception('Simulated error');
    }
  }

  @override
  void dispose() {
    rxFuture.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mark(
          builder: (context) => rxFuture.value.when(
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
              onPressed: () => rxFuture.execute(_fetchData),
              child: const Text('Load Data'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () => rxFuture.reset(),
              child: const Text('Reset'),
            ),
          ],
        ),
      ],
    );
  }
}

// =======================================================
// 4. FORM VALIDATION EXAMPLE
// =======================================================

class FormValidationExample extends StatefulWidget {
  const FormValidationExample({super.key});

  @override
  State<FormValidationExample> createState() => _FormValidationExampleState();
}

class _FormValidationExampleState extends State<FormValidationExample> {
  final emailField = RxField<String>('');
  final passwordField = RxField<String>('');

  @override
  void initState() {
    super.initState();
    emailField.addValidator(Validators.required('Email is required'));
    emailField.addValidator(Validators.email('Invalid email format'));
    passwordField.addValidator(Validators.required('Password is required'));
    passwordField.addValidator(Validators.minLength(6, 'Password must be at least 6 characters'));
  }

  @override
  void dispose() {
    emailField.dispose();
    passwordField.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Email',
            errorText: emailField.error,
            border: const OutlineInputBorder(),
          ),
          onChanged: (value) {
            emailField.value = value;
            if (emailField.touched) {
              emailField.validate();
            }
          },
          onTap: () => emailField.markAsTouched(),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Password',
            errorText: passwordField.error,
            border: const OutlineInputBorder(),
          ),
          obscureText: true,
          onChanged: (value) {
            passwordField.value = value;
            if (passwordField.touched) {
              passwordField.validate();
            }
          },
          onTap: () => passwordField.markAsTouched(),
        ),
        const SizedBox(height: 16),
        Mark(
          builder: (context) => ElevatedButton(
            onPressed: emailField.isValid && passwordField.isValid
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Form is valid!')),
                    );
                  }
                : null,
            child: const Text('Submit'),
          ),
        ),
      ],
    );
  }
}

// =======================================================
// 5. TRANSACTION (BATCH UPDATES) EXAMPLE
// =======================================================

class TransactionExample extends StatefulWidget {
  const TransactionExample({super.key});

  @override
  State<TransactionExample> createState() => _TransactionExampleState();
}

class _TransactionExampleState extends State<TransactionExample> {
  final x = Rx<int>(0);
  final y = Rx<int>(0);
  final z = Rx<int>(0);
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

// =======================================================
// 6. ANIMATION TWEEN EXAMPLE
// =======================================================

class TweenExample extends StatefulWidget {
  const TweenExample({super.key});

  @override
  State<TweenExample> createState() => _TweenExampleState();
}

class _TweenExampleState extends State<TweenExample> {
  late final RxTween<double> sizeTween;
  late final RxTween<Color?> colorTween;

  @override
  void initState() {
    super.initState();
    sizeTween = TweenHelper.doubleTween(begin: 50.0, end: 200.0);
    colorTween = TweenHelper.colorTween(
      begin: Colors.blue,
      end: Colors.purple,
    );
  }

  @override
  void dispose() {
    sizeTween.dispose();
    colorTween.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Mark(
          builder: (context) => Center(
            child: Container(
              width: sizeTween.value,
              height: sizeTween.value,
              decoration: BoxDecoration(
                color: colorTween.value,
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () => sizeTween.animateTo(1.0),
              child: const Text('Animate Size'),
            ),
            ElevatedButton(
              onPressed: () => colorTween.animateTo(1.0),
              child: const Text('Animate Color'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Mark(
          builder: (context) => Slider(
            value: sizeTween.progress,
            min: 0.0,
            max: 1.0,
            onChanged: (v) => sizeTween.progress = v,
          ),
        ),
        Mark(
          builder: (context) => Text('Progress: ${(sizeTween.progress * 100).toStringAsFixed(0)}%'),
        ),
      ],
    );
  }
}

// =======================================================
// 7. LIFECYCLE CONTROLLER EXAMPLE
// =======================================================

class LifecycleExample extends StatefulWidget {
  const LifecycleExample({super.key});

  @override
  State<LifecycleExample> createState() => _LifecycleExampleState();
}

class _LifecycleExampleState extends State<LifecycleExample> with LifecycleMixin {
  @override
  Widget build(BuildContext context) {
    return Mark(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getColorForState(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'State: ${lifecycle.state.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Initialized: ${lifecycle.isInitialized}'),
                Text('Active: ${lifecycle.isActive}'),
                Text('Disposed: ${lifecycle.isDisposed}'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton(
                onPressed: () => lifecycle.activate(),
                child: const Text('Activate'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => lifecycle.pause(),
                child: const Text('Pause'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () => lifecycle.resume(),
                child: const Text('Resume'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getColorForState() {
    switch (lifecycle.state) {
      case LifecycleState.initializing:
        return Colors.grey.shade300;
      case LifecycleState.initialized:
        return Colors.blue.shade100;
      case LifecycleState.active:
        return Colors.green.shade100;
      case LifecycleState.paused:
        return Colors.orange.shade100;
      default:
        return Colors.red.shade100;
    }
  }
}

// =======================================================
// 8. PERSISTENCE EXAMPLE
// =======================================================

class PersistenceExample extends StatefulWidget {
  const PersistenceExample({super.key});

  @override
  State<PersistenceExample> createState() => _PersistenceExampleState();
}

class _PersistenceExampleState extends State<PersistenceExample> {
  late final RxPersisted<int> counter;
  final storage = MemoryStorage();

  @override
  void initState() {
    super.initState();
    counter = RxPersisted(0, 'example_counter', storage);
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
        Mark(
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

// =======================================================
// 9. GLOBAL STORE / DEPENDENCY INJECTION EXAMPLE
// =======================================================

class StoreExample extends StatefulWidget {
  const StoreExample({super.key});

  @override
  State<StoreExample> createState() => _StoreExampleState();
}

class _StoreExampleState extends State<StoreExample> {
  @override
  void initState() {
    super.initState();
    // Register services
    store.register<UserService>(UserService());
    store.registerState('userCount', Rx<int>(0));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () {
            final userService = store.get<UserService>();
            final count = store.getState<int>('userCount');
            count.value = userService.getUserCount();
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('User count: ${count.value}')),
            );
          },
          child: const Text('Get User Count from Store'),
        ),
        const SizedBox(height: 16),
        Mark(
          builder: (context) => Text(
            'User Count: ${store.getState<int>('userCount').value}',
            style: const TextStyle(fontSize: 18),
          ),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: () async {
            final action = ExampleAction(
              'increment',
              {},
              () async => store.getState<int>('userCount').value++,
            );
            await store.dispatch(action);
          },
          child: const Text('Dispatch Action (with Middleware)'),
        ),
      ],
    );
  }
}

class UserService {
  int getUserCount() => 42;
}

// =======================================================
// 10. LOGGER EXAMPLE
// =======================================================

class LoggerExample extends StatefulWidget {
  const LoggerExample({super.key});

  @override
  State<LoggerExample> createState() => _LoggerExampleState();
}

class _LoggerExampleState extends State<LoggerExample> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: () {
                Logger.debug('Debug message');
                _showLogs(context);
              },
              child: const Text('Debug'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.info('Info message');
                _showLogs(context);
              },
              child: const Text('Info'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.warning('Warning message');
                _showLogs(context);
              },
              child: const Text('Warning'),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              onPressed: () {
                Logger.error('Error message');
                _showLogs(context);
              },
              child: const Text('Error'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Logger.clear();
            _showLogs(context);
          },
          child: const Text('Clear Logs'),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          height: 150,
          child: SingleChildScrollView(
            child: Text(
              Logger.history.map((e) => e.toString()).join('\n'),
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
          ),
        ),
      ],
    );
  }

  void _showLogs(BuildContext context) {
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Log history: ${Logger.history.length} entries'),
        duration: const Duration(seconds: 1),
      ),
    );
  }
}

