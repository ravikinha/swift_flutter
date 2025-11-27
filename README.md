# swift_flutter

[![pub package](https://img.shields.io/pub/v/swift_flutter.svg)](https://pub.dev/packages/swift_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A reactive state management library for Flutter with automatic dependency tracking. Inspired by MobX and Vue's reactivity system, but built specifically for Flutter.

## Features

✅ **Reactive State (Rx)** - Automatic dependency tracking  
✅ **Mark Widget** - Auto-rebuild when dependencies change  
✅ **Computed (Derived State)** - Automatically computed values with nested dependency support  
✅ **SwiftFuture / Async State** - Loading/error/success states with automatic retry and error recovery  
✅ **SwiftField / Form Validation** - Field validation with built-in validators  
✅ **SwiftPersisted / Persistence** - Automatic save/load with migration support  
✅ **Middleware / Interceptors** - Action interception and logging  
✅ **Batch Update Transactions** - Prevent unnecessary rebuilds  
✅ **Debug Logger** - Configurable logging with history  
✅ **SwiftTween / Animation Tween** - Reactive animation values with AnimationController  
✅ **Lifecycle Controller** - Widget lifecycle management  
✅ **Global Store / Dependency Injection** - Service registration and state management  
✅ **Redux-like Reducers** - Predictable state updates with action/reducer pattern  
✅ **State Normalization** - Efficient collection management  
✅ **Pagination** - Built-in pagination support  
✅ **Error Boundaries** - Error handling with UI components  
✅ **Performance Monitoring** - Built-in performance tracking  
✅ **Circular Dependency Detection** - Automatic detection of circular dependencies  
✅ **Memoization** - Performance optimization for computed values  
✅ **Enhanced Testing Utilities** - Comprehensive test helpers  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  swift_flutter: ^1.1.1
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Reactive State

```dart
import 'package:swift_flutter/swift_flutter.dart';

// Create reactive state with automatic type inference
// The swift() function automatically infers the type from the value
final counter = swift(0);        // Creates Rx<int> automatically
final name = swift('Hello');     // Creates Rx<String> automatically
final flag = swift(true);        // Creates Rx<bool> automatically
final price = swift(99.99);      // Creates Rx<double> automatically

// For custom models or complex types, use explicit type annotation
// This ensures type safety and better IDE support
final counter = swift<int>(0);                    // Explicitly typed as Rx<int>
final user = swift<User>(User('John'));           // Required for custom classes
final list = swift<List<String>>(['a', 'b']);    // Required for generic types
final nullable = swift<String?>(null);            // Required for nullable types

// Alternative: Use Rx constructor directly (still supported)
final explicit = Rx<int>(0);

// Wrap your widget with Mark to enable automatic rebuilds
// Mark automatically tracks dependencies and rebuilds when values change
Mark(
  builder: (context) => Text('Count: ${counter.value}'),
)

// Simply update the value - the widget rebuilds automatically!
// No need to call setState() or manage listeners manually
counter.value = 10;
```

### Computed Values (Derived State)

```dart
// Create reactive state variables
// These will be tracked as dependencies for computed values
final price = swift(100.0);  // Reactive price value
final quantity = swift(2);   // Reactive quantity value

// Or use explicit typing for better type safety
final price = swift<double>(100.0);
final quantity = swift<int>(2);

// Create a computed value that automatically updates
// when its dependencies (price or quantity) change
// The computation function is only called when dependencies change
final total = Computed(() => price.value * quantity.value);

// Use the computed value in your UI
// It will automatically update when price or quantity changes
Mark(
  builder: (context) => Text('Total: \$${total.value}'),
)
```

### Async State Management

```dart
// Create a SwiftFuture to manage async operations
// It automatically tracks loading, success, and error states
final swiftFuture = SwiftFuture<String>();

// Execute an async operation
// The state automatically transitions: idle → loading → success/error
swiftFuture.execute(() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded!';
});

// Display different UI based on the current async state
// The when() method provides a type-safe way to handle all states
Mark(
  builder: (context) => swiftFuture.value.when(
    idle: () => Text('Click to load'),              // Initial state
    loading: () => CircularProgressIndicator(),     // Loading indicator
    success: (data) => Text(data),                  // Success with data
    error: (error, stack) => Text('Error: $error'), // Error handling
  ),
)
```

### Form Validation

```dart
// Create a reactive form field with validation support
// SwiftField extends Rx<T> and adds validation capabilities
final emailField = SwiftField<String>('');

// Add validation rules
// Validators are checked automatically when the value changes
emailField.addValidator(Validators.required());  // Field must not be empty
emailField.addValidator(Validators.email());      // Must be a valid email format

// Use the field in a TextField
// The error message is automatically displayed when validation fails
TextField(
  onChanged: (value) => emailField.value = value,  // Update field value
  decoration: InputDecoration(
    errorText: emailField.error,  // Shows validation error if any
  ),
)

// Check validation status programmatically
if (emailField.isValid) {
  // Proceed with form submission
}
```

## Use Cases & Examples

### 1. Reactive State (Rx)

Create reactive state that automatically updates UI when values change.

```dart
// Create reactive state with automatic type inference
final counter = swift(0);
final name = swift('Swift Flutter');

// Use in widget - automatically rebuilds when value changes
Mark(
  builder: (context) => Column(
    children: [
      Text('Count: ${counter.value}'),
      Text('Name: ${name.value}'),
      ElevatedButton(
        onPressed: () => counter.value++,
        child: const Text('Increment'),
      ),
    ],
  ),
)
```

### 2. Computed Values (Derived State)

Create computed values that automatically update when dependencies change.

```dart
// Base reactive values
final price = swift(100.0);
final quantity = swift(2);

// Computed value - automatically recalculates when price or quantity changes
final total = Computed(() => price.value * quantity.value);
final summary = Computed(() => 'Total: \$${total.value.toStringAsFixed(2)}');

// Use in UI
Mark(
  builder: (context) => Text(summary.value),
)
```

### 3. Async State Management (SwiftFuture)

Handle async operations with automatic loading, success, and error states.

```dart
final dataFuture = SwiftFuture<String>();

// Execute async operation
Future<void> loadData() async {
  await dataFuture.execute(() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Data loaded successfully!';
  });
}

// Display state in UI
Mark(
  builder: (context) => dataFuture.value.when(
    idle: () => ElevatedButton(
      onPressed: loadData,
      child: Text('Load Data'),
    ),
    loading: () => CircularProgressIndicator(),
    success: (data) => Text('Success: $data'),
    error: (error, stack) => Text('Error: $error'),
  ),
)
```

### 4. Form Validation (SwiftField)

Create form fields with built-in validation and error handling.

```dart
final emailField = SwiftField<String>('');
final passwordField = SwiftField<String>('');

// Add validators
emailField.addValidator(Validators.required());
emailField.addValidator(Validators.email());
passwordField.addValidator(Validators.required());
passwordField.addValidator(Validators.minLength(8));

// Use in form
Column(
  children: [
    TextField(
      onChanged: (value) => emailField.value = value,
      decoration: InputDecoration(
        labelText: 'Email',
        errorText: emailField.error,
      ),
    ),
    TextField(
      onChanged: (value) => passwordField.value = value,
      obscureText: true,
      decoration: InputDecoration(
        labelText: 'Password',
        errorText: passwordField.error,
      ),
    ),
    ElevatedButton(
      onPressed: emailField.isValid && passwordField.isValid
          ? () => print('Form is valid!')
          : null,
      child: Text('Submit'),
    ),
  ],
)
```

### 5. Batch Updates (Transactions)

Batch multiple updates to prevent unnecessary rebuilds.

```dart
final x = swift(0);
final y = swift(0);
final z = swift(0);

// Batch multiple updates - only one rebuild occurs
Transaction.run(() {
  x.value = 10;
  y.value = 20;
  z.value = 30;
});

// All three values update, but widget rebuilds only once
Mark(
  builder: (context) => Text('x: ${x.value}, y: ${y.value}, z: ${z.value}'),
)
```

### 6. Reactive Animations (SwiftTween)

Create reactive animations that respond to state changes.

```dart
late final SwiftTween<double> sizeTween;
late final SwiftTween<Color?> colorTween;

@override
void initState() {
  super.initState();
  sizeTween = TweenHelper.doubleTween(begin: 50.0, end: 200.0);
  colorTween = TweenHelper.colorTween(
    begin: Colors.blue,
    end: Colors.red,
  );
}

// Animate to target value
Future<void> animate() async {
  await sizeTween.animateTo(1.0, duration: Duration(seconds: 1));
}

// Use in UI
Mark(
  builder: (context) => Container(
    width: sizeTween.value,
    height: sizeTween.value,
    color: colorTween.value,
  ),
)
```

### 7. Widget Lifecycle Management

Track and manage widget lifecycle states.

```dart
class MyWidget extends StatefulWidget {
  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with LifecycleMixin {
  @override
  void onInitialized() {
    super.onInitialized();
    // Called when widget is initialized
    print('Widget initialized');
  }

  @override
  void onActivated() {
    super.onActivated();
    // Called when widget becomes active
    print('Widget activated');
  }

  @override
  void onDeactivated() {
    super.onDeactivated();
    // Called when widget becomes inactive
    print('Widget deactivated');
  }

  @override
  Widget build(BuildContext context) {
    return Text('Lifecycle: ${lifecycleState}');
  }
}
```

### 8. Persistent Storage (SwiftPersisted)

Automatically save and load reactive values from storage.

```dart
final storage = MemoryStorage(); // Use SharedPreferences in production
late final SwiftPersisted<int> counter;

@override
void initState() {
  super.initState();
  counter = SwiftPersisted<int>(0, 'counter_key', storage);
}

// Value is automatically saved when changed
counter.value = 42; // Saved automatically

// Value is automatically loaded on initialization
Mark(
  builder: (context) => Text('Counter: ${counter.value}'),
)
```

### 9. Global Store / Dependency Injection

Register and retrieve services and state globally.

```dart
// Register a service
class UserService {
  String getUser() => 'John Doe';
}

store.registerService<UserService>(UserService());

// Register reactive state
final globalCounter = swift(0);
store.registerState('counter', globalCounter);

// Retrieve service
final userService = store.getService<UserService>();
print(userService.getUser()); // 'John Doe'

// Retrieve state
final counter = store.getState<Rx<int>>('counter');
print(counter.value); // 0
```

### 10. Debug Logging

Configure logging with different levels and history.

```dart
// Enable and configure logger
Logger.setEnabled(true);
Logger.setLevel(LogLevel.debug);

// Log messages
Logger.debug('Debug message');
Logger.info('Info message');
Logger.warning('Warning message');
Logger.error('Error message');

// Get log history
final history = Logger.getHistory();
for (final entry in history) {
  print('${entry.level}: ${entry.message}');
}

// Clear history
Logger.clearHistory();
```

### 11. Middleware / Interceptors

Intercept and modify actions in the global store.

```dart
class LoggingMiddleware extends Middleware {
  @override
  Future<Action?> before(Action action) async {
    print('Before action: ${action.runtimeType}');
    return action;
  }

  @override
  Future<void> after(Action action, dynamic result) async {
    print('After action: ${action.runtimeType}, result: $result');
  }
}

// Register middleware
store.addMiddleware(LoggingMiddleware());

// Dispatch action - middleware intercepts it
store.dispatch(MyAction());
```

### 12. Async State with Retry and Error Recovery

Handle async operations with automatic retry and error recovery:

```dart
// Create SwiftFuture with retry configuration
final dataFuture = SwiftFuture<String>(
  retryConfig: RetryConfig(
    maxAttempts: 3,
    delay: Duration(seconds: 1),
    backoffMultiplier: 2.0, // Exponential backoff
    shouldRetry: (error) => error is NetworkException,
  ),
  recoveryStrategy: ErrorRecoveryStrategy.fallback,
  fallbackValue: 'Default value',
);

// Execute with automatic retry
await dataFuture.execute(() async {
  return await fetchData();
});

// Use in UI
Mark(
  builder: (context) => dataFuture.value.when(
    idle: () => Text('Click to load'),
    loading: () => Text('Loading... (attempt ${dataFuture.currentAttempt + 1})'),
    success: (data) => Text(data),
    error: (error, stack) => Column(
      children: [
        Text('Error: ${dataFuture.errorMessage}'),
        ElevatedButton(
          onPressed: () => dataFuture.retry(),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

### 13. Redux-like State Management

Use Redux-like pattern for predictable state updates:

```dart
// Define actions
class IncrementAction implements Action {
  @override
  String get type => 'INCREMENT';
}

// Define reducer
final counterReducer = (int state, Action action) {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1;
    default:
      return state;
  }
};

// Create store
final counterStore = ReduxStore<int>(0, counterReducer);

// Use in widget
Mark(
  builder: (context) => Text('Count: ${counterStore.value}'),
)

// Dispatch actions
counterStore.dispatch(IncrementAction());
```

### 14. State Normalization

Efficiently manage collections with normalized state:

```dart
final usersState = RxNormalizedState<User>();

// Add users
usersState.upsert('user1', User(id: 'user1', name: 'John'));
usersState.upsertMany({
  'user2': User(id: 'user2', name: 'Jane'),
  'user3': User(id: 'user3', name: 'Bob'),
});

// Get by ID
final user = usersState.getById('user1');

// Use in widget
Mark(
  builder: (context) => ListView(
    children: usersState.ids.map((id) {
      final user = usersState.getById(id);
      return ListTile(title: Text(user?.name ?? ''));
    }).toList(),
  ),
)
```

### 15. Pagination

Handle paginated data easily:

```dart
final paginationController = PaginationController<User>(
  loadPage: (page, pageSize) async {
    final response = await api.getUsers(page: page, pageSize: pageSize);
    return response.users;
  },
  pageSize: 20,
);

// Load initial page
await paginationController.loadInitial();

// Use in widget
Mark(
  builder: (context) => ListView(
    children: [
      ...paginationController.items.map((user) => UserTile(user: user)),
      if (paginationController.hasMore)
        ElevatedButton(
          onPressed: () => paginationController.loadNext(),
          child: Text('Load More'),
        ),
    ],
  ),
)
```

### 16. Error Boundary

Catch and handle errors gracefully:

```dart
ErrorBoundaryWidget(
  errorBuilder: (context, error, stackTrace) {
    return ErrorWidget(
      error: error,
      onRetry: () {
        // Retry logic
      },
    );
  },
  child: MyWidget(),
)
```

### 17. Performance Optimization

Enable memoization for expensive computed values:

```dart
final expensiveComputation = Computed<int>(
  () {
    // Expensive computation
    return heavyCalculation();
  },
  enableMemoization: true, // Enable memoization
);
```

### 18. Debug Mode

Enable debug mode for development:

```dart
DebugMode.enable(
  verboseLogging: true,
  trackDependencies: true,
);

// Use debug logger
DebugLogger.logWithContext(
  'State updated',
  context: {'counter': counter.value},
);
```

### 19. Persistence with Migration

Handle data migrations when schema changes:

```dart
final persistedCounter = SwiftPersisted<int>(
  0,
  'counter_key',
  storage,
  currentVersion: 2,
  migrations: [
    MigrationHelper.simpleMigration<int>(
      fromVersion: 1,
      toVersion: 2,
      transform: (data) => data['value'] as int? ?? 0,
    ),
  ],
);
```

### 20. Enhanced Animations

Use AnimationController for better performance:

```dart
class _MyWidgetState extends State<MyWidget> with SingleTickerProviderStateMixin {
  late final SwiftTween<double> sizeTween;

  @override
  void initState() {
    super.initState();
    sizeTween = SwiftTween<double>(
      Tween(begin: 50.0, end: 200.0),
      vsync: this, // Use AnimationController
    );
  }

  // Animate with staggered sequence
  Future<void> animate() async {
    await sizeTween.animateSequence(
      [0.0, 0.5, 1.0],
      stagger: Duration(milliseconds: 100),
    );
  }
}
```

### 21. Complete Example App

See the [example](example/) directory for a complete Flutter app demonstrating all features with interactive examples.

## Documentation

- [Full API Documentation](https://pub.dev/documentation/swift_flutter)
- [Architecture Review](ARCHITECTURE_REVIEW.md)
- [Advanced Patterns & Best Practices](ADVANCED_PATTERNS.md)
- [Library Review](LIBRARY_REVIEW.md)

## Example

See the [example](example/) directory for a complete example app demonstrating all features.

Run the example:

```bash
cd example
flutter run
```

## Testing

All features include comprehensive test coverage:

```bash
flutter test
```

**67+ tests passing** ✅

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Author

[ravikinha](https://github.com/ravikinha)

## Support

If you find this package useful, please consider giving it a ⭐ on [pub.dev](https://pub.dev/packages/swift_flutter) and [GitHub](https://github.com/ravikinha/swift_flutter)!
