# Advanced Patterns

Now that you understand the basics, let's explore advanced patterns and techniques for building complex applications with swift_flutter.

## Batch Updates with Transactions

When you need to update multiple values, use `Transaction` to batch updates and prevent unnecessary rebuilds:

```dart
final x = swift(0);
final y = swift(0);
final z = swift(0);

// Without transaction - causes 3 rebuilds
x.value = 10;
y.value = 20;
z.value = 30;

// With transaction - causes 1 rebuild
Transaction.run(() {
  x.value = 10;
  y.value = 20;
  z.value = 30;
});
```

### Example: Form Reset

```dart
class FormController extends SwiftController {
  final name = swift('');
  final email = swift('');
  final phone = swift('');
  
  void reset() {
    Transaction.run(() {
      name.value = '';
      email.value = '';
      phone.value = '';
    });
  }
}
```

## State Normalization

For complex data structures, normalize your state:

```dart
class AppState {
  final users = swift<Map<String, User>>({});
  final posts = swift<Map<String, Post>>({});
  final selectedUserId = swift<String?>(null);
  
  late final Computed<User?> selectedUser;
  late final Computed<List<Post>> userPosts;
  
  AppState() {
    selectedUser = Computed(() {
      final userId = selectedUserId.value;
      return userId != null ? users.value[userId] : null;
    });
    
    userPosts = Computed(() {
      final userId = selectedUserId.value;
      if (userId == null) return [];
      return posts.value.values
          .where((post) => post.userId == userId)
          .toList();
    });
  }
  
  void addUser(User user) {
    users.value = {...users.value, user.id: user};
  }
  
  void addPost(Post post) {
    posts.value = {...posts.value, post.id: post};
  }
}
```

## Middleware and Interceptors

Use middleware to intercept actions and add cross-cutting concerns:

```dart
class LoggingMiddleware extends Middleware {
  @override
  void onAction(Action action) {
    print('Action: ${action.type}');
    print('Timestamp: ${DateTime.now()}');
  }
}

// Usage
final store = Store();
store.addMiddleware(LoggingMiddleware());
```

## Error Boundaries

Handle errors gracefully with error boundaries:

```dart
class ErrorBoundary extends StatelessWidget {
  final Widget child;
  
  const ErrorBoundary({required this.child});
  
  @override
  Widget build(BuildContext context) {
    return SwiftErrorBoundary(
      child: child,
      onError: (error, stack) {
        return ErrorWidget(
          error: error,
          stack: stack,
        );
      },
    );
  }
}
```

## Performance Optimization

### Memoization

Computed values are automatically memoized, but you can optimize further:

```dart
final expensiveComputation = Computed.memoized(() {
  // Expensive calculation
  return heavyCalculation();
});
```

### Lazy Loading

Load data only when needed:

```dart
class LazyDataController extends SwiftController {
  final dataFuture = SwiftFuture<List<Item>>();
  final isExpanded = swift(false);
  
  void toggleExpanded() {
    isExpanded.toggle();
    
    if (isExpanded.value && dataFuture.value.isIdle) {
      loadData();
    }
  }
  
  Future<void> loadData() async {
    await dataFuture.execute(() => fetchItems());
  }
}
```

## Pagination

Implement pagination easily:

```dart
class PaginatedListController extends SwiftController {
  final items = swift<List<Item>>([]);
  final currentPage = swift(1);
  final isLoading = swift(false);
  final hasMore = swift(true);
  
  Future<void> loadPage(int page) async {
    if (isLoading.value || !hasMore.value) return;
    
    isLoading.value = true;
    try {
      final newItems = await fetchPage(page);
      
      if (newItems.isEmpty) {
        hasMore.value = false;
      } else {
        items.value = [...items.value, ...newItems];
        currentPage.value = page;
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadNextPage() {
    return loadPage(currentPage.value + 1);
  }
  
  void reset() {
    items.value = [];
    currentPage.value = 1;
    hasMore.value = true;
  }
}
```

## Global State Management

Use the global store for app-wide state:

```dart
// Register services
class UserService {
  User? currentUser;
}

store.register<UserService>(UserService());

// Register state
final appTheme = swift(ThemeMode.light);
store.registerState('theme', appTheme);

// Use anywhere
final theme = store.getState<ThemeMode>('theme');
final userService = store.get<UserService>();
```

## Redux-like Pattern

Use reducers for predictable state updates:

```dart
// Actions
class IncrementAction implements Action {
  @override
  String get type => 'INCREMENT';
}

class DecrementAction implements Action {
  @override
  String get type => 'DECREMENT';
}

// Reducer
final counterReducer = (int state, Action action) {
  switch (action.type) {
    case 'INCREMENT':
      return state + 1;
    case 'DECREMENT':
      return state - 1;
    default:
      return state;
  }
};

// Store
final counterStore = ReduxStore<int>(0, counterReducer);

// Usage
Swift(
  builder: (context) => Text('Count: ${counterStore.value}'),
)

// Dispatch
counterStore.dispatch(IncrementAction());
```

## Testing Patterns

### Testing Controllers

```dart
void main() {
  group('CounterController', () {
    test('increments counter', () {
      final controller = CounterController();
      expect(controller.counter.value, 0);
      
      controller.increment();
      expect(controller.counter.value, 1);
    });
    
    test('resets counter', () {
      final controller = CounterController();
      controller.increment();
      controller.increment();
      
      controller.reset();
      expect(controller.counter.value, 0);
    });
  });
}
```

### Testing Computed Values

```dart
void main() {
  test('computed value updates when dependency changes', () {
    final price = swift(100.0);
    final quantity = swift(2);
    final total = Computed(() => price.value * quantity.value);
    
    expect(total.value, 200.0);
    
    price.value = 150.0;
    expect(total.value, 300.0);
    
    quantity.value = 3;
    expect(total.value, 450.0);
  });
}
```

## Architecture Patterns

### Feature-Based Architecture

```
lib/
├── features/
│   ├── auth/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── models/
│   ├── products/
│   │   ├── controllers/
│   │   ├── views/
│   │   └── models/
│   └── cart/
│       ├── controllers/
│       ├── views/
│       └── models/
├── shared/
│   ├── widgets/
│   └── services/
└── main.dart
```

### MVVM Pattern

```dart
// Model
class User {
  final String name;
  final String email;
  User({required this.name, required this.email});
}

// ViewModel (Controller)
class UserViewModel extends SwiftController {
  final userFuture = SwiftFuture<User>();
  
  Future<void> loadUser(String id) async {
    await userFuture.execute(() => fetchUser(id));
  }
}

// View
class UserView extends StatelessWidget {
  final viewModel = UserViewModel();
  
  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => viewModel.userFuture.value.when(
        loading: () => CircularProgressIndicator(),
        success: (user) => UserCard(user: user),
        error: (error, stack) => ErrorWidget(error: error),
        idle: () => SizedBox(),
      ),
    );
  }
}
```

## Best Practices Summary

1. **Use transactions** for batch updates
2. **Normalize complex state** for better performance
3. **Use middleware** for cross-cutting concerns
4. **Implement error boundaries** for graceful error handling
5. **Optimize with memoization** when needed
6. **Test your controllers** and computed values
7. **Follow consistent architecture** patterns
8. **Keep controllers focused** on single responsibilities

## Next Steps

Now that you understand advanced patterns, let's learn about best practices for production applications.

---

**Previous**: [Extensions ←](08_extensions.md) | **Next**: [Best Practices →](10_best_practices.md)

