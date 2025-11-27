import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';
import '../helpers/services.dart';

/// Global Store / Dependency Injection Example
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

