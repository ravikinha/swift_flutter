# Async State with SwiftFuture

Handling asynchronous operations is a common requirement in Flutter apps. `SwiftFuture` makes it easy to manage loading, success, and error states automatically.

## What is SwiftFuture?

`SwiftFuture` is a reactive wrapper around `Future` that automatically tracks loading, success, and error states. It eliminates the need for manual state management of async operations.

### Traditional Approach

```dart
class DataWidget extends StatefulWidget {
  @override
  State<DataWidget> createState() => _DataWidgetState();
}

class _DataWidgetState extends State<DataWidget> {
  String? _data;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    try {
      final data = await fetchData();
      setState(() {
        _data = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return CircularProgressIndicator();
    if (_error != null) return Text('Error: $_error');
    return Text(_data ?? 'No data');
  }
}
```

### swift_flutter Approach

```dart
class DataWidget extends StatelessWidget {
  final dataFuture = SwiftFuture<String>();

  @override
  Widget build(BuildContext context) {
    // Load data on first build
    if (dataFuture.value.isIdle) {
      dataFuture.execute(() => fetchData());
    }

    return Swift(
      builder: (context) => dataFuture.value.when(
        idle: () => Text('Click to load'),
        loading: () => CircularProgressIndicator(),
        success: (data) => Text(data),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }
}
```

Much simpler!

## Creating SwiftFuture

### Basic Creation

```dart
final dataFuture = SwiftFuture<String>();
```

### With Initial Value

```dart
final dataFuture = SwiftFuture<String>.success('Initial data');
```

## Executing Async Operations

### Basic Execution

```dart
final dataFuture = SwiftFuture<String>();

Future<void> loadData() async {
  await dataFuture.execute(() async {
    await Future.delayed(Duration(seconds: 2));
    return 'Data loaded!';
  });
}
```

### With Error Handling

```dart
final dataFuture = SwiftFuture<String>();

Future<void> loadData() async {
  await dataFuture.execute(() async {
    final response = await http.get(Uri.parse('https://api.example.com/data'));
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to load data');
    }
  });
}
```

## Reading State

### Using .when()

The `.when()` method provides a clean way to handle all states:

```dart
Swift(
  builder: (context) => dataFuture.value.when(
    idle: () => ElevatedButton(
      onPressed: () => dataFuture.execute(() => fetchData()),
      child: Text('Load Data'),
    ),
    loading: () => CircularProgressIndicator(),
    success: (data) => Text('Data: $data'),
    error: (error, stack) => Column(
      children: [
        Text('Error: $error'),
        ElevatedButton(
          onPressed: () => dataFuture.execute(() => fetchData()),
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

### Checking State Directly

```dart
Swift(
  builder: (context) {
    final state = dataFuture.value;
    
    if (state.isIdle) return Text('Idle');
    if (state.isLoading) return CircularProgressIndicator();
    if (state.isSuccess) return Text('Data: ${state.data}');
    if (state.isError) return Text('Error: ${state.error}');
    
    return SizedBox.shrink();
  },
)
```

## Common Patterns

### Pattern: Data Loading

```dart
class UserProfileController extends SwiftController {
  final userFuture = SwiftFuture<User>();
  
  void loadUser(String userId) {
    userFuture.execute(() async {
      final response = await api.getUser(userId);
      return User.fromJson(response);
    });
  }
}

// Usage
class UserProfileView extends StatelessWidget {
  final controller = UserProfileController();
  
  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => controller.userFuture.value.when(
        idle: () => ElevatedButton(
          onPressed: () => controller.loadUser('123'),
          child: Text('Load User'),
        ),
        loading: () => CircularProgressIndicator(),
        success: (user) => UserCard(user: user),
        error: (error, stack) => ErrorWidget(error: error),
      ),
    );
  }
}
```

### Pattern: Form Submission

```dart
class LoginController extends SwiftController {
  final email = swift('');
  final password = swift('');
  final submitFuture = SwiftFuture<AuthResult>();
  
  Future<void> submit() async {
    await submitFuture.execute(() async {
      return await authService.login(
        email: email.value,
        password: password.value,
      );
    });
  }
}

// Usage
class LoginView extends StatelessWidget {
  final controller = LoginController();
  
  @override
  Widget build(BuildContext context) {
    return Swift(
      builder: (context) => Column(
        children: [
          TextField(
            onChanged: (value) => controller.email.value = value,
            decoration: InputDecoration(labelText: 'Email'),
          ),
          TextField(
            onChanged: (value) => controller.password.value = value,
            obscureText: true,
            decoration: InputDecoration(labelText: 'Password'),
          ),
          ElevatedButton(
            onPressed: controller.submitFuture.value.isLoading 
              ? null 
              : controller.submit,
            child: controller.submitFuture.value.isLoading
              ? CircularProgressIndicator()
              : Text('Login'),
          ),
          if (controller.submitFuture.value.isSuccess)
            Text('Login successful!', style: TextStyle(color: Colors.green)),
          if (controller.submitFuture.value.isError)
            Text('Login failed: ${controller.submitFuture.value.error}'),
        ],
      ),
    );
  }
}
```

### Pattern: Retry Logic

```dart
class DataController extends SwiftController {
  final dataFuture = SwiftFuture<List<Item>>();
  
  Future<void> loadData() async {
    await dataFuture.execute(() => fetchItems());
  }
  
  Future<void> retry() async {
    await loadData();
  }
}

// Usage with retry button
Swift(
  builder: (context) => controller.dataFuture.value.when(
    idle: () => ElevatedButton(
      onPressed: controller.loadData,
      child: Text('Load'),
    ),
    loading: () => CircularProgressIndicator(),
    success: (items) => ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) => ItemTile(item: items[index]),
    ),
    error: (error, stack) => Column(
      children: [
        Text('Error: $error'),
        ElevatedButton(
          onPressed: controller.retry,
          child: Text('Retry'),
        ),
      ],
    ),
  ),
)
```

## Advanced Features

### Automatic Retry

```dart
final dataFuture = SwiftFuture<String>();

Future<void> loadData() async {
  await dataFuture.execute(
    () => fetchData(),
    retryCount: 3,
    retryDelay: Duration(seconds: 2),
  );
}
```

### Error Recovery

```dart
final dataFuture = SwiftFuture<String>();

Future<void> loadData() async {
  await dataFuture.execute(
    () => fetchData(),
    onError: (error) {
      // Handle error and return fallback
      return 'Fallback data';
    },
  );
}
```

### Multiple Async Operations

```dart
class DashboardController extends SwiftController {
  final userFuture = SwiftFuture<User>();
  final postsFuture = SwiftFuture<List<Post>>();
  final statsFuture = SwiftFuture<Stats>();
  
  Future<void> loadAll() async {
    await Future.wait([
      userFuture.execute(() => fetchUser()),
      postsFuture.execute(() => fetchPosts()),
      statsFuture.execute(() => fetchStats()),
    ]);
  }
}

// Usage
Swift(
  builder: (context) {
    final allLoaded = controller.userFuture.value.isSuccess &&
                     controller.postsFuture.value.isSuccess &&
                     controller.statsFuture.value.isSuccess;
    
    if (!allLoaded) return CircularProgressIndicator();
    
    return Dashboard(
      user: controller.userFuture.value.data!,
      posts: controller.postsFuture.value.data!,
      stats: controller.statsFuture.value.data!,
    );
  },
)
```

## Best Practices

1. **Use SwiftFuture for async operations** - Don't manage loading/error states manually
2. **Handle all states** - Use `.when()` to handle idle, loading, success, and error
3. **Provide retry options** - Let users retry failed operations
4. **Show loading indicators** - Give users feedback during async operations
5. **Handle errors gracefully** - Show user-friendly error messages

## Next Steps

Now that you understand async state, let's learn about form validation with SwiftField.

---

**Previous**: [Controllers ←](05_controllers.md) | **Next**: [Form Validation →](07_form_validation.md)

