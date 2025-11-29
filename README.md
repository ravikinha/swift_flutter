# swift_flutter

[![pub package](https://img.shields.io/pub/v/swift_flutter.svg)](https://pub.dev/packages/swift_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A reactive state management library for Flutter with automatic dependency tracking. Inspired by MobX and Vue's reactivity system, but built specifically for Flutter with Swift-like extensions and two flexible patterns.

## ✨ Features

✅ **Two Flexible Patterns** - Direct state management OR Controller pattern with enforced separation  
✅ **Reactive State (SwiftValue)** - Automatic dependency tracking with `swift()`  
✅ **Swift Widget** - Auto-rebuild when dependencies change  
✅ **Computed (Derived State)** - Automatically computed values with nested dependency support  
✅ **SwiftFuture / Async State** - Loading/error/success states with automatic retry and error recovery  
✅ **SwiftField / Form Validation** - Field validation with built-in validators  
✅ **SwiftPersisted / Persistence** - Automatic save/load with migration support  
✅ **SwiftController** - Enforced separation of concerns (views read-only, controllers modify)  
✅ **Swift-like Extensions** - Toggle, add, sub, mul, div, and 80+ convenient methods  
✅ **Middleware / Interceptors** - Action interception and logging  
✅ **Batch Update Transactions** - Prevent unnecessary rebuilds  
✅ **Debug Logger** - Configurable logging with history  
✅ **SwiftTween / Animation Tween** - Reactive animation values with AnimationController  
✅ **SwiftUI-like Declarative Animations** - Zero boilerplate animations (no controllers, no mixins!)  
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
✅ **DevTools Integration** - Full Flutter DevTools support with zero overhead  

## 📦 Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  swift_flutter: ^2.2.0
```

Then run:

```bash
flutter pub get
```

## 🚀 Quick Start

### Pattern 1: Direct State Management (Simple & Flexible)

Perfect for view-local state, simple UI, and quick prototypes.

```dart
import 'package:swift_flutter/swift_flutter.dart';

class MyWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    // ✅ Create reactive state directly in views
    final counter = swift(0);
    final name = swift('Hello');
    final isExpanded = swift(false);
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Count: ${counter.value}'),
          Text('Name: ${name.value}'),
          ElevatedButton(
            onPressed: () => counter.value++, // ✅ Direct modification
            child: Text('Increment'),
          ),
          ElevatedButton(
            onPressed: () => isExpanded.toggle(), // ✅ Use extensions
            child: Text('Toggle'),
          ),
        ],
      ),
    );
  }
}
```

**When to use:**
- View-local state (toggles, local counters)
- Simple UI state
- Quick prototypes
- Single view usage

---

### Pattern 2: Controller Pattern (Enforced Separation)

Perfect for business logic, shared state, and team projects.

```dart
import 'package:swift_flutter/swift_flutter.dart';

// ✅ Controller - only place where state can be modified
class CounterController extends SwiftController {
  // Just use swift() - automatically read-only from views!
  final counter = swift(0);
  final name = swift('Hello');
  
  void increment() => counter.value++;  // ✅ Works inside controller
  void updateName(String n) => name.value = n;
}

// ✅ View - can only read state and call controller methods
class MyView extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final controller = CounterController();
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Count: ${controller.counter.value}'), // ✅ Can read
          Text('Name: ${controller.name.value}'),
          ElevatedButton(
            onPressed: controller.increment, // ✅ Can call methods
            child: Text('Increment'),
          ),
        ],
      ),
    );
    // ❌ controller.counter.value = 10; // Runtime error - cannot modify
  }
}
```

**When to use:**
- Business logic & validation
- Shared state across multiple views
- Complex state management
- Team projects (enforced separation)

---

## 📚 Core Features

### 1. Reactive State with `swift()`

```dart
// Automatic type inference
final counter = swift(0);        // SwiftValue<int>
final name = swift('Hello');     // SwiftValue<String>
final flag = swift(true);         // SwiftValue<bool>
final price = swift(99.99);       // SwiftValue<double>

// Explicit typing for custom types
final user = swift<User>(User('John'));
final list = swift<List<String>>(['a', 'b']);

// Use in widget - automatically rebuilds
Swift(
  builder: (context) => Text('Count: ${counter.value}'),
)

// Update value - widget rebuilds automatically!
counter.value = 10;
```

### 2. Computed Values (Derived State)

```dart
final price = swift(100.0);
final quantity = swift(2);

// Computed value - automatically updates when dependencies change
final total = Computed(() => price.value * quantity.value);
final summary = Computed(() => 'Total: \$${total.value.toStringAsFixed(2)}');

// Use in UI
Swift(
  builder: (context) => Text(summary.value),
)
```

### 3. Async State Management (SwiftFuture)

```dart
final dataFuture = SwiftFuture<String>();

// Execute async operation
await dataFuture.execute(() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded!';
});

// Display state in UI
Swift(
  builder: (context) => dataFuture.value.when(
    idle: () => Text('Click to load'),
    loading: () => CircularProgressIndicator(),
    success: (data) => Text(data),
    error: (error, stack) => Text('Error: $error'),
  ),
)
```

### 4. Form Validation (SwiftField)

```dart
final emailField = SwiftField<String>('');

// Add validators
emailField.addValidator(Validators.required());
emailField.addValidator(Validators.email());

// Use in TextField
TextField(
  onChanged: (value) => emailField.value = value,
  decoration: InputDecoration(
    errorText: emailField.error, // Shows validation error
  ),
)

// Check validation
if (emailField.isValid) {
  // Proceed with form submission
}
```

### 5. Swift-like Extensions

**Bool Extensions:**
```dart
bool flag = true;
flag = flag.toggle(); // false
```

**Int/Double Extensions:**
```dart
int count = 10;
count = count.add(5);      // 15
count = count.sub(3);      // 12
count = count.mul(2);      // 24
double result = count.div(3); // 8.0

// Percentage operations
double price = 100.0;
price = price.applyPercent(20);  // 120.0 (add 20%)
price = price.discount(10);       // 108.0 (subtract 10%)
price = price.tax(5);             // 113.4 (add 5% tax)
price = price.addGST(10);         // 124.74 (add 10% GST)

// Range operations
count = count.clamped(min: 0, max: 100); // Clamp between 0-100
bool inRange = count.isBetween(0, 100);   // Check if in range

// Formatting
String formatted = count.toCurrency();     // '$10.00'
String readable = 1500.toReadable();       // '1.5K'
String inr = 10000.toINR();               // '₹10,000'
```

**String Extensions:**
```dart
String name = 'hello';
name = name.capitalized;        // 'Hello'
name = name.add(' world');      // 'Hello world'
name = name.dropFirst();        // 'ello world'
name = name.dropLast();         // 'ello worl'
bool isEmpty = name.isEmpty;    // false
bool isNotEmpty = name.isNotEmpty; // true
```

**List Extensions:**
```dart
List<int> numbers = [1, 2, 3, 4, 5];
numbers = numbers.dropFirst();  // [2, 3, 4, 5]
numbers = numbers.dropLast();   // [2, 3, 4]
bool found = numbers.containsWhere((n) => n > 3); // true
```

**Reactive Extensions (on SwiftValue):**
```dart
// All extensions work on SwiftValue too!
final counter = swift(10);
counter.add(5);    // counter.value is now 15
counter.sub(3);    // counter.value is now 12
counter.mul(2);    // counter.value is now 24

final price = swift(100.0);
price.applyPercent(20);  // price.value is now 120.0
price.discount(10);      // price.value is now 108.0
price.tax(5);            // price.value is now 113.4

final name = swift('hello');
name.add(' world');      // name.value is now 'hello world'
name.capitalized;        // Returns 'Hello world' (read-only)
name.dropFirst();        // Returns 'ello world' (read-only)

final flag = swift(true);
flag.toggle();           // flag.value is now false

final numbers = swift<List<int>>([1, 2, 3]);
numbers.dropFirst();     // Returns [2, 3] (read-only)
```

**📦 Import Extensions:**
```dart
import 'package:swift_flutter/swift_flutter.dart';
import 'package:swift_flutter/core/extensions.dart'; // Optional - for extensions
```

**Available Extensions (80+ methods):**
- **Bool**: `toggle()`
- **Int/Double**: `add()`, `sub()`, `mul()`, `div()`, `percent()`, `applyPercent()`, `discount()`, `tax()`, `addGST()`, `removeGST()`, `clamped()`, `isBetween()`, `lerp()`, `mapRange()`, `toCurrency()`, `toINR()`, `toReadable()`, `toOrdinal()`, and more
- **String**: `capitalized`, `add()`, `dropFirst()`, `dropLast()`, `isEmpty`, `isNotEmpty`, and more
- **List**: `dropFirst()`, `dropLast()`, `containsWhere()`, and more
- **Iterable**: `containsWhere()`, and more
- **SwiftValue**: All above methods work on reactive values too!

### 6. Batch Updates (Transactions)

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
```

### 7. Reactive Animations (SwiftTween)

```dart
late final SwiftTween<double> sizeTween;

@override
void initState() {
  super.initState();
  sizeTween = SwiftTween<double>(
    Tween(begin: 50.0, end: 200.0),
    vsync: this, // Use AnimationController for better performance
  );
}

// Animate to target value
await sizeTween.animateTo(1.0, duration: Duration(seconds: 1));

// Use in UI
Swift(
  builder: (context) => Container(
    width: sizeTween.value,
    height: sizeTween.value,
  ),
)
```

### 8. Persistence (SwiftPersisted)

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
Swift(
  builder: (context) => Text('Counter: ${counter.value}'),
)
```

### 9. Global Store / Dependency Injection

```dart
// Register a service
class UserService {
  String getUser() => 'John Doe';
}

store.register<UserService>(UserService());

// Register reactive state
final globalCounter = swift(0);
store.registerState('counter', globalCounter);

// Retrieve service
final userService = store.get<UserService>();
print(userService.getUser()); // 'John Doe'

// Retrieve state
final counter = store.getState<int>('counter');
print(counter.value); // 0
```

### 10. Redux-like State Management

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
Swift(
  builder: (context) => Text('Count: ${counterStore.value}'),
)

// Dispatch actions
counterStore.dispatch(IncrementAction());
```

## 🎯 Complete Examples

### Example 1: Direct Pattern with Extensions

```dart
class CounterWidget extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final counter = swift(0);
    final isExpanded = swift(false);
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Count: ${counter.value}'),
          ElevatedButton(
            onPressed: () => counter.add(1), // ✅ Use extension
            child: Text('Add'),
          ),
          ElevatedButton(
            onPressed: () => counter.sub(1), // ✅ Use extension
            child: Text('Subtract'),
          ),
          ElevatedButton(
            onPressed: () => isExpanded.toggle(), // ✅ Use extension
            child: Text(isExpanded.value ? 'Collapse' : 'Expand'),
          ),
        ],
      ),
    );
  }
}
```

### Example 2: Controller Pattern

```dart
class ShoppingCartController extends SwiftController {
  final items = swift<List<Item>>([]);
  final total = swift(0.0);
  
  late final Computed<double> tax;
  late final Computed<double> grandTotal;
  
  ShoppingCartController() {
    tax = Computed(() => total.value * 0.1);
    grandTotal = Computed(() => total.value + tax.value);
  }
  
  void addItem(Item item) {
    items.value = [...items.value, item];
    total.value = items.value.fold(0.0, (sum, item) => sum + item.price);
  }
  
  void removeItem(String itemId) {
    items.value = items.value.where((item) => item.id != itemId).toList();
    total.value = items.value.fold(0.0, (sum, item) => sum + item.price);
  }
}

class ShoppingCartView extends StatefulWidget {
  @override
  Widget build(BuildContext context) {
    final controller = ShoppingCartController();
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Items: ${controller.items.value.length}'),
          Text('Total: \$${controller.total.value.toStringAsFixed(2)}'),
          Text('Tax: \$${controller.tax.value.toStringAsFixed(2)}'),
          Text('Grand Total: \$${controller.grandTotal.value.toStringAsFixed(2)}'),
          ElevatedButton(
            onPressed: () => controller.addItem(Item(id: '1', price: 10.0)),
            child: Text('Add Item'),
          ),
        ],
      ),
    );
  }
}
```

## 🎬 SwiftUI-like Declarative Animations

**Zero boilerplate - no controllers, no ticker providers needed!**

Create smooth, professional animations with a simple chaining API. Works with just `StatefulWidget` and `StatelessWidget` - no mixins required!

### Basic Usage

```dart
import 'package:swift_flutter/swift_flutter.dart';

Container(
  width: 100,
  height: 100,
  color: Colors.blue,
)
  .animate()
  .scale(1.2)
  .fadeIn()
  .duration(500.ms)  // Shorthand: 500.ms or "500ms" or Duration(milliseconds: 500)
  .repeat(reverse: true)
```

### Available Animations

**Transformations:**
- `.scale(value)` - Scale uniformly
- `.scaleX(value)` - Scale on X axis
- `.scaleY(value)` - Scale on Y axis
- `.rotate(degrees)` - Rotate by degrees

**Opacity:**
- `.fadeIn()` - Fade from 0 to 1
- `.fadeOut()` - Fade from 1 to 0
- `.opacity(value)` - Custom opacity (0.0 to 1.0)

**Slides:**
- `.slideX(value)` - Slide on X axis
- `.slideY(value)` - Slide on Y axis
- `.slideInTop()` - Slide in from top
- `.slideInBottom()` - Slide in from bottom
- `.slideInLeft()` - Slide in from left
- `.slideInRight()` - Slide in from right

**Special Effects:**
- `.bounce()` - Bounce animation curve
- `.pulse()` - Pulse animation curve
- `.fadeInScale(value)` - Combined fade and scale

**Configuration:**
- `.duration(value)` - Animation duration (supports `.500ms`, `0.5.s`, `5.m`, or `Duration`)
- `.delay(value)` - Animation delay
- `.curve(curve)` - Custom animation curve
- `.repeat(reverse: bool)` - Infinite repeat
- `.repeatCount(count, reverse: bool)` - Repeat specific times
- `.persist()` - Keep animation state on rebuild

### Shorthand Duration Examples

```dart
// String format
.animate().duration(".500ms")
.animate().duration("0.5s")
.animate().duration("5m")

// Number extensions (recommended)
.animate().duration(500.ms)
.animate().duration(0.5.s)
.animate().duration(5.m)

// Traditional Duration
.animate().duration(const Duration(seconds: 5))
```

### Complex Example

```dart
Container(
  width: 120,
  height: 120,
  decoration: BoxDecoration(
    color: Colors.purple,
    borderRadius: BorderRadius.circular(20),
  ),
)
  .animate()
  .fadeIn()
  .scale(1.2)
  .slideInBottom()
  .rotate(180)
  .duration(1.5.s)
  .curve(Curves.easeInOut)
  .repeat(reverse: true)
```

### Why Mixin-Free?

Traditional Flutter animations require `SingleTickerProviderStateMixin` or `TickerProviderStateMixin` in your widget class. With swift_flutter animations:

- ✅ **No mixins needed** - Just use `StatefulWidget` or `StatelessWidget`
- ✅ **Zero boilerplate** - No controller setup or disposal
- ✅ **Clean API** - Simple chaining like SwiftUI
- ✅ **Automatic management** - All ticker providers handled internally

The library uses `TickerProviderStateMixin` internally, but you never see it - it's completely hidden from your code!

## 📖 Documentation

- [Full API Documentation](https://pub.dev/documentation/swift_flutter)
- [Architecture Review](ARCHITECTURE_REVIEW.md)
- [Advanced Patterns & Best Practices](ADVANCED_PATTERNS.md)
- [Library Review](LIBRARY_REVIEW.md)
- [DevTools Integration](DEVTOOLS.md)

## 🧪 Testing

All features include comprehensive test coverage:

```bash
flutter test
```

**80+ tests passing** ✅

## 📝 Example App

See the [example](example/) directory for a complete Flutter app demonstrating all features with interactive examples.

Run the example:

```bash
cd example
flutter run
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👤 Author

[ravikinha](https://github.com/ravikinha)

## ⭐ Support

If you find this package useful, please consider giving it a ⭐ on [pub.dev](https://pub.dev/packages/swift_flutter) and [GitHub](https://github.com/ravikinha/swift_flutter)!
