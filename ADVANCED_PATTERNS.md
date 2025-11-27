# Advanced Patterns & Best Practices

This guide covers advanced patterns and best practices for using Swift Flutter state management library.

## Table of Contents

1. [State Management Patterns](#state-management-patterns)
2. [Performance Optimization](#performance-optimization)
3. [Error Handling](#error-handling)
4. [Testing Patterns](#testing-patterns)
5. [Migration Guides](#migration-guides)

---

## State Management Patterns

### Redux-like Pattern with Reducers

Use `ReduxStore` for predictable state updates:

```dart
// Define actions
class IncrementAction implements Action {
  @override
  String get type => 'INCREMENT';
  
  @override
  Map<String, dynamic>? get payload => {'amount': 1};
}

class DecrementAction implements Action {
  @override
  String get type => 'DECREMENT';
  
  @override
  Map<String, dynamic>? get payload => {'amount': 1};
}

// Define reducer
Reducer<int> counterReducer = (int state, Action action) {
  switch (action.type) {
    case 'INCREMENT':
      return state + (action.payload?['amount'] as int? ?? 1);
    case 'DECREMENT':
      return state - (action.payload?['amount'] as int? ?? 1);
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

### State Normalization

Use `RxNormalizedState` for managing collections efficiently:

```dart
// Define entity with ID
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// Create normalized state
final usersState = RxNormalizedState<User>();

// Add users
usersState.upsert('user1', User(id: 'user1', name: 'John', email: 'john@example.com'));
usersState.upsert('user2', User(id: 'user2', name: 'Jane', email: 'jane@example.com'));

// Get user by ID
final user = usersState.getById('user1');

// Get multiple users
final selectedUsers = usersState.getByIds(['user1', 'user2']);

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

### Pagination

Use `PaginationController` for paginated data:

```dart
// Create pagination controller
final paginationController = PaginationController<User>(
  loadPage: (page, pageSize) async {
    // Load data from API
    final response = await api.getUsers(page: page, pageSize: pageSize);
    return response.users;
  },
  pageSize: 20,
);

// Load initial page
await paginationController.loadInitial();

// Load next page
await paginationController.loadNext();

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

---

## Performance Optimization

### Memoization for Computed Values

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

### Circular Dependency Detection

The library automatically detects circular dependencies:

```dart
final a = Rx<int>(1);
final b = Computed<int>(() => a.value + 1);
final c = Computed<int>(() => b.value + 1);
// This will throw an error if 'a' depends on 'c' creating a cycle
```

### Batch Updates with Transactions

Use `Transaction.run()` to batch multiple updates:

```dart
Transaction.run(() {
  counter1.value = 10;
  counter2.value = 20;
  counter3.value = 30;
  // Only one rebuild occurs
});
```

### Lazy Loading

Use `LazyRx` for values that should only load when accessed:

```dart
final lazyData = LazyRx<Data>(
  () => loadExpensiveData(),
  Data.empty(),
);

// Data is only loaded when first accessed
final data = lazyData.value; // Triggers load
```

---

## Error Handling

### Automatic Retry

Configure retry for async operations:

```dart
final dataFuture = SwiftFuture<String>(
  retryConfig: RetryConfig(
    maxAttempts: 3,
    delay: Duration(seconds: 1),
    backoffMultiplier: 2.0, // Exponential backoff
    shouldRetry: (error) => error is NetworkException,
  ),
);

await dataFuture.execute(() => fetchData());
```

### Error Recovery Strategies

Use error recovery strategies:

```dart
final dataFuture = SwiftFuture<String>(
  recoveryStrategy: ErrorRecoveryStrategy.fallback,
  fallbackValue: 'Default value',
);

// Or use custom recovery
final dataFuture = SwiftFuture<String>(
  recoveryStrategy: ErrorRecoveryStrategy.custom,
  recoveryFunction: () async {
    // Custom recovery logic
    return await fetchFromCache();
  },
);
```

### Error Boundary Widget

Wrap widgets with error boundary:

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

---

## Testing Patterns

### Mock Reactive State

Use `MockReactiveState` for testing:

```dart
final mockState = MockReactiveState();
final counter = mockState.state<int>('counter', 0);

// Test
counter.value = 10;
expect(counter.value, 10);
```

### Async Testing

Use test helpers for async operations:

```dart
test('should load data', () async {
  final future = SwiftFuture<String>();
  
  future.execute(() => Future.value('data'));
  
  await SwiftTestHelpers.waitForSwiftFutureSuccess(future);
  
  expect(future.data, 'data');
});
```

### Transaction Testing

Test transactions:

```dart
test('should batch updates', () {
  final x = swift(0);
  final y = swift(0);
  
  SwiftTestHelpers.runInTransaction(() {
    x.value = 10;
    y.value = 20;
  });
  
  expect(x.value, 10);
  expect(y.value, 20);
});
```

---

## Migration Guides

### From GetX

**GetX:**
```dart
final count = 0.obs;
Obx(() => Text('Count: $count'));
count.value++;
```

**Swift Flutter:**
```dart
final count = swift(0);
Mark(builder: (context) => Text('Count: ${count.value}'));
count.value++;
```

### From Riverpod

**Riverpod:**
```dart
final counterProvider = StateProvider((ref) => 0);
Consumer(builder: (context, ref, child) {
  final count = ref.watch(counterProvider);
  return Text('Count: $count');
});
ref.read(counterProvider.notifier).state++;
```

**Swift Flutter:**
```dart
final counter = swift(0);
Mark(builder: (context) => Text('Count: ${counter.value}'));
counter.value++;
```

### From Bloc

**Bloc:**
```dart
class CounterBloc extends Bloc<CounterEvent, int> {
  CounterBloc() : super(0) {
    on<Increment>((event, emit) => emit(state + 1));
  }
}

BlocBuilder<CounterBloc, int>(
  builder: (context, count) => Text('Count: $count'),
)
```

**Swift Flutter:**
```dart
final counter = swift(0);
Mark(builder: (context) => Text('Count: ${counter.value}'));
counter.value++;
```

### From MobX

**MobX:**
```dart
class Counter = _Counter with _$Counter;
abstract class _Counter with Store {
  @observable
  int count = 0;
  
  @action
  void increment() => count++;
}

Observer(builder: (_) => Text('Count: ${counter.count}'));
```

**Swift Flutter:**
```dart
final counter = swift(0);
Mark(builder: (context) => Text('Count: ${counter.value}'));
counter.value++;
```

---

## Best Practices

### 1. Use Transactions for Multiple Updates

```dart
// ❌ Bad - multiple rebuilds
counter1.value = 10;
counter2.value = 20;
counter3.value = 30;

// ✅ Good - single rebuild
Transaction.run(() {
  counter1.value = 10;
  counter2.value = 20;
  counter3.value = 30;
});
```

### 2. Enable Memoization for Expensive Computations

```dart
// ✅ Good
final expensive = Computed<int>(
  () => heavyCalculation(),
  enableMemoization: true,
);
```

### 3. Use Error Boundaries

```dart
// ✅ Good
ErrorBoundaryWidget(
  child: MyWidget(),
)
```

### 4. Configure Retry for Network Operations

```dart
// ✅ Good
final dataFuture = SwiftFuture<String>(
  retryConfig: RetryConfig(
    maxAttempts: 3,
    delay: Duration(seconds: 1),
  ),
);
```

### 5. Normalize Collections

```dart
// ✅ Good - use normalized state for collections
final usersState = RxNormalizedState<User>();
usersState.upsertMany(usersMap);
```

---

## Performance Tuning

### Enable Performance Monitoring

```dart
PerformanceMonitor.setEnabled(true);

// Get performance report
final report = PerformanceMonitor.getReport();
print('Total rebuilds: ${report['totalRebuilds']}');
```

### Use Debug Mode

```dart
DebugMode.enable(
  verboseLogging: true,
  trackDependencies: true,
);
```

### Optimize Computed Values

```dart
// Use memoization for expensive computations
final computed = Computed<int>(
  () => expensiveOperation(),
  enableMemoization: true,
);
```

---

For more examples, see the [example](example/) directory.

