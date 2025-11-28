# Reactive State with SwiftValue

`SwiftValue` is the heart of swift_flutter. It's a reactive container that holds a value and automatically tracks dependencies. Let's learn how to use it effectively.

## Creating SwiftValue

### Basic Creation

Use the `swift()` function to create a `SwiftValue`:

```dart
final counter = swift(0);           // SwiftValue<int>
final name = swift('John');         // SwiftValue<String>
final isActive = swift(true);       // SwiftValue<bool>
final price = swift(99.99);        // SwiftValue<double>
```

### Type Inference

Dart automatically infers the type from the initial value:

```dart
final count = swift(0);        // Type: SwiftValue<int>
final text = swift('Hello');   // Type: SwiftValue<String>
```

### Explicit Typing

For custom types or when type inference isn't clear:

```dart
final user = swift<User>(User(name: 'John'));
final list = swift<List<String>>([]);
final nullable = swift<String?>(null);
```

## Reading Values

### Inside Swift Widget

Access `.value` inside a `Swift` widget's builder:

```dart
final counter = swift(0);

Swift(
  builder: (context) => Text('Count: ${counter.value}'),
)
```

### Outside Swift Widget

You can read values outside, but changes won't trigger rebuilds:

```dart
final counter = swift(0);
print(counter.value);  // Works, but won't track dependencies
```

## Updating Values

### Direct Assignment

Simply assign a new value:

```dart
counter.value = 10;
name.value = 'Jane';
isActive.value = false;
```

### Using Operators

```dart
counter.value++;           // Increment
counter.value--;           // Decrement
counter.value += 5;        // Add
counter.value -= 2;        // Subtract
```

### Using Extensions

swift_flutter provides convenient extensions:

```dart
counter.add(5);           // counter.value += 5
counter.sub(3);           // counter.value -= 3
counter.mul(2);           // counter.value *= 2
isActive.toggle();        // isActive.value = !isActive.value
```

## Working with Different Types

### Numbers

```dart
final count = swift(0);
final price = swift(99.99);

// Operations
count.value++;
price.value *= 1.1;  // 10% increase

// Using extensions
count.add(5);
price.applyPercent(20);  // Add 20%
price.discount(10);      // Subtract 10%
```

### Strings

```dart
final message = swift('Hello');

// Direct assignment
message.value = 'Hello World';

// Using extensions
message.add(' World');        // message.value += ' World'
message.capitalized;          // Returns capitalized version
```

### Booleans

```dart
final isVisible = swift(false);

// Toggle
isVisible.value = !isVisible.value;
// Or use extension
isVisible.toggle();
```

### Lists

```dart
final items = swift<List<String>>([]);

// Add item
items.value = [...items.value, 'New Item'];

// Remove item
items.value = items.value.where((item) => item != 'Item').toList();

// Clear
items.value = [];
```

### Custom Objects

```dart
class User {
  final String name;
  final int age;
  
  User({required this.name, required this.age});
  
  User copyWith({String? name, int? age}) {
    return User(
      name: name ?? this.name,
      age: age ?? this.age,
    );
  }
}

final user = swift<User>(User(name: 'John', age: 25));

// Update
user.value = user.value.copyWith(name: 'Jane');
```

## Multiple SwiftValues

### Independent Values

```dart
final firstName = swift('John');
final lastName = swift('Doe');
final age = swift(25);

Swift(
  builder: (context) => Column(
    children: [
      Text('Name: ${firstName.value} ${lastName.value}'),
      Text('Age: ${age.value}'),
    ],
  ),
)
```

### Related Values

```dart
final price = swift(100.0);
final quantity = swift(2);

Swift(
  builder: (context) => Column(
    children: [
      Text('Price: \$${price.value}'),
      Text('Quantity: ${quantity.value}'),
      Text('Total: \$${price.value * quantity.value}'),
    ],
  ),
)
```

## Conditional Rendering

### Simple Conditions

```dart
final isLoggedIn = swift(false);

Swift(
  builder: (context) => isLoggedIn.value
    ? Text('Welcome!')
    : Text('Please login'),
)
```

### Complex Conditions

```dart
final userRole = swift('guest');

Swift(
  builder: (context) {
    if (userRole.value == 'admin') {
      return AdminPanel();
    } else if (userRole.value == 'user') {
      return UserDashboard();
    } else {
      return LoginScreen();
    }
  },
)
```

## Performance Considerations

### Batch Updates

Use `Transaction` to batch multiple updates:

```dart
final x = swift(0);
final y = swift(0);
final z = swift(0);

// Without transaction - 3 rebuilds
x.value = 10;
y.value = 20;
z.value = 30;

// With transaction - 1 rebuild
Transaction.run(() {
  x.value = 10;
  y.value = 20;
  z.value = 30;
});
```

### Avoiding Unnecessary Rebuilds

Only access `.value` for values you actually need:

```dart
// ❌ Bad - accesses all values
Swift(
  builder: (context) => Text('${a.value} ${b.value} ${c.value}'),
)

// ✅ Good - only accesses needed values
Swift(
  builder: (context) => Text('${a.value}'),
)
```

## Common Patterns

### Pattern: Form Fields

```dart
final email = swift('');
final password = swift('');
final rememberMe = swift(false);

Swift(
  builder: (context) => Column(
    children: [
      TextField(
        onChanged: (value) => email.value = value,
        decoration: InputDecoration(labelText: 'Email'),
      ),
      TextField(
        onChanged: (value) => password.value = value,
        obscureText: true,
        decoration: InputDecoration(labelText: 'Password'),
      ),
      Checkbox(
        value: rememberMe.value,
        onChanged: (value) => rememberMe.value = value ?? false,
      ),
    ],
  ),
)
```

### Pattern: Loading States

```dart
final isLoading = swift(false);
final data = swift<String?>(null);

Future<void> loadData() async {
  isLoading.value = true;
  try {
    data.value = await fetchData();
  } finally {
    isLoading.value = false;
  }
}

Swift(
  builder: (context) {
    if (isLoading.value) {
      return CircularProgressIndicator();
    }
    return Text(data.value ?? 'No data');
  },
)
```

## Next Steps

Now that you understand SwiftValue, let's learn about computed values that automatically derive from other values.

---

**Previous**: [Core Concepts ←](02_basic_concepts.md) | **Next**: [Computed Values →](04_computed_values.md)

