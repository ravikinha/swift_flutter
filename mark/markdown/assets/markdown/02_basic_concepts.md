# Core Concepts

Understanding the fundamental concepts of swift_flutter is crucial for building effective applications. Let's explore the key ideas that power this library.

## What is Reactive State Management?

Reactive state management means that when your data changes, the UI automatically updates to reflect those changes. You don't need to manually call `setState()` or manage widget rebuilds.

### Traditional Approach

```dart
class CounterWidget extends StatefulWidget {
  @override
  State<CounterWidget> createState() => _CounterWidgetState();
}

class _CounterWidgetState extends State<CounterWidget> {
  int _counter = 0;

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Text('Count: $_counter');
  }
}
```

### swift_flutter Approach

```dart
class CounterWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final counter = swift(0);
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Count: ${counter.value}'),
          ElevatedButton(
            onPressed: () => counter.value++,
            child: Text('Increment'),
          ),
        ],
      ),
    );
  }
}
```

Notice how much simpler the swift_flutter version is!

## Key Concepts

### 1. SwiftValue

A `SwiftValue` is a reactive container that holds a value and automatically tracks which widgets depend on it.

```dart
final counter = swift(0);  // Creates a SwiftValue<int>
```

### 2. Swift Widget

The `Swift` widget is a special widget that automatically rebuilds when any `SwiftValue` it depends on changes.

```dart
Swift(
  builder: (context) => Text('Count: ${counter.value}'),
)
```

### 3. Automatic Dependency Tracking

When you access `.value` inside a `Swift` widget's builder, swift_flutter automatically tracks that dependency. When the value changes, the widget rebuilds.

### 4. Two Patterns

swift_flutter supports two patterns:

#### Pattern 1: Direct State Management
- State is created directly in widgets
- Simple and flexible
- Perfect for local state

#### Pattern 2: Controller Pattern
- State is managed in controller classes
- Enforced separation of concerns
- Perfect for shared state and business logic

## Understanding Reactivity

### How It Works

1. You create a `SwiftValue` using `swift()`
2. You wrap your UI in a `Swift` widget
3. When you access `.value` in the builder, a dependency is tracked
4. When you change the value, all dependent widgets rebuild automatically

### Example: Multiple Dependencies

```dart
final name = swift('John');
final age = swift(25);
final city = swift('New York');

Swift(
  builder: (context) => Column(
    children: [
      Text('Name: ${name.value}'),
      Text('Age: ${age.value}'),
      Text('City: ${city.value}'),
    ],
  ),
)

// Changing any value will rebuild the widget
name.value = 'Jane';  // Widget rebuilds
age.value = 26;       // Widget rebuilds
city.value = 'Boston'; // Widget rebuilds
```

## Benefits of This Approach

### 1. Less Boilerplate
No need for `StatefulWidget`, `setState()`, or manual state management.

### 2. Automatic Updates
The UI automatically stays in sync with your data.

### 3. Performance
Only widgets that depend on changed values rebuild.

### 4. Readability
Code is more declarative and easier to understand.

### 5. Testability
State logic is separated and easy to test.

## Common Patterns

### Pattern: Counter

```dart
final count = swift(0);

Swift(
  builder: (context) => Text('Count: ${count.value}'),
)

// Increment
count.value++;

// Decrement
count.value--;

// Reset
count.value = 0;
```

### Pattern: Toggle

```dart
final isVisible = swift(true);

Swift(
  builder: (context) => isVisible.value
    ? Text('Visible!')
    : SizedBox.shrink(),
)

// Toggle
isVisible.value = !isVisible.value;
// Or use extension
isVisible.toggle();
```

### Pattern: List Management

```dart
final items = swift<List<String>>([]);

Swift(
  builder: (context) => ListView.builder(
    itemCount: items.value.length,
    itemBuilder: (context, index) => 
      ListTile(title: Text(items.value[index])),
  ),
)

// Add item
items.value = [...items.value, 'New Item'];

// Remove item
items.value = items.value.where((item) => item != 'Item').toList();
```

## Best Practices

1. **Use `Swift` widget** for any UI that depends on reactive state
2. **Access `.value`** only inside `Swift` builder for automatic tracking
3. **Keep state close** to where it's used for simple cases
4. **Use controllers** for complex state or shared state
5. **Don't modify state** outside of `Swift` builders without proper setup

## Next Steps

Now that you understand the core concepts, let's dive deeper into reactive state management with SwiftValue.

---

**Previous**: [Getting Started ←](01_getting_started.md) | **Next**: [Reactive State →](03_reactive_state.md)

