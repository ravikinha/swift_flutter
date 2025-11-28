# Controller Pattern

The Controller pattern provides enforced separation of concerns. Views can only read state, and only controllers can modify it. This is perfect for business logic, shared state, and team projects.

## Why Use Controllers?

### Benefits

1. **Enforced Separation** - Views can't accidentally modify state
2. **Business Logic** - Centralize logic in controllers
3. **Shared State** - Easy to share state across multiple views
4. **Team Collaboration** - Clear boundaries between UI and logic
5. **Testing** - Easy to test business logic separately

## Creating a Controller

### Basic Controller

```dart
class CounterController extends SwiftController {
  final counter = swift(0);
  
  void increment() => counter.value++;
  void decrement() => counter.value--;
  void reset() => counter.value = 0;
}
```

### Using the Controller

```dart
class CounterView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = CounterController();
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Count: ${controller.counter.value}'),
          ElevatedButton(
            onPressed: controller.increment,
            child: Text('Increment'),
          ),
          ElevatedButton(
            onPressed: controller.decrement,
            child: Text('Decrement'),
          ),
          ElevatedButton(
            onPressed: controller.reset,
            child: Text('Reset'),
          ),
        ],
      ),
    );
  }
}
```

## Enforced Read-Only in Views

### ✅ Allowed in Views

```dart
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = CounterController();
    
    // ✅ Reading values
    final count = controller.counter.value;
    
    // ✅ Calling controller methods
    controller.increment();
    
    return Swift(
      builder: (context) => Text('${controller.counter.value}'),
    );
  }
}
```

### ❌ Not Allowed in Views

```dart
class MyView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = CounterController();
    
    // ❌ This will throw a runtime error!
    controller.counter.value = 10;  // Cannot modify from view
    
    return Container();
  }
}
```

## Controller with Multiple State

```dart
class UserController extends SwiftController {
  final name = swift('');
  final email = swift('');
  final age = swift(0);
  final isActive = swift(false);
  
  late final Computed<String> displayName;
  late final Computed<bool> isValid;
  
  UserController() {
    displayName = Computed(() => 
      name.value.isEmpty ? email.value : name.value
    );
    
    isValid = Computed(() => 
      name.value.isNotEmpty && 
      email.value.contains('@') && 
      age.value > 0
    );
  }
  
  void updateName(String newName) => name.value = newName;
  void updateEmail(String newEmail) => email.value = newEmail;
  void updateAge(int newAge) => age.value = newAge;
  void toggleActive() => isActive.toggle();
  
  void reset() {
    name.value = '';
    email.value = '';
    age.value = 0;
    isActive.value = false;
  }
}
```

## Complex Example: Shopping Cart

```dart
class CartItem {
  final String id;
  final String name;
  final double price;
  final int quantity;
  
  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
  });
}

class ShoppingCartController extends SwiftController {
  final items = swift<List<CartItem>>([]);
  
  late final Computed<int> itemCount;
  late final Computed<double> subtotal;
  late final Computed<double> tax;
  late final Computed<double> total;
  late final Computed<bool> isEmpty;
  
  ShoppingCartController() {
    itemCount = Computed(() => items.value.length);
    
    subtotal = Computed(() => 
      items.value.fold(0.0, (sum, item) => sum + item.price * item.quantity)
    );
    
    tax = Computed(() => subtotal.value * 0.1);
    
    total = Computed(() => subtotal.value + tax.value);
    
    isEmpty = Computed(() => items.value.isEmpty);
  }
  
  void addItem(CartItem item) {
    final existingIndex = items.value.indexWhere((i) => i.id == item.id);
    
    if (existingIndex >= 0) {
      // Update quantity
      final existing = items.value[existingIndex];
      final updated = CartItem(
        id: existing.id,
        name: existing.name,
        price: existing.price,
        quantity: existing.quantity + item.quantity,
      );
      items.value = [
        ...items.value.sublist(0, existingIndex),
        updated,
        ...items.value.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      items.value = [...items.value, item];
    }
  }
  
  void removeItem(String itemId) {
    items.value = items.value.where((item) => item.id != itemId).toList();
  }
  
  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    
    final index = items.value.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      final item = items.value[index];
      final updated = CartItem(
        id: item.id,
        name: item.name,
        price: item.price,
        quantity: quantity,
      );
      items.value = [
        ...items.value.sublist(0, index),
        updated,
        ...items.value.sublist(index + 1),
      ];
    }
  }
  
  void clear() {
    items.value = [];
  }
}
```

## Sharing Controllers

### Using Provider Pattern

```dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cartController = ShoppingCartController();
    
    return MaterialApp(
      home: CartProvider(
        controller: cartController,
        child: HomePage(),
      ),
    );
  }
}

class CartProvider extends InheritedWidget {
  final ShoppingCartController controller;
  
  CartProvider({
    required this.controller,
    required Widget child,
  }) : super(child: child);
  
  static ShoppingCartController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CartProvider>()!.controller;
  }
  
  @override
  bool updateShouldNotify(CartProvider oldWidget) => false;
}

// Usage
class CartView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = CartProvider.of(context);
    
    return Swift(
      builder: (context) => Column(
        children: [
          Text('Items: ${controller.itemCount.value}'),
          Text('Total: \$${controller.total.value.toStringAsFixed(2)}'),
        ],
      ),
    );
  }
}
```

## Controller Lifecycle

```dart
class MyController extends SwiftController {
  final data = swift<String?>(null);
  
  @override
  void init() {
    super.init();
    // Called when controller is created
    loadData();
  }
  
  @override
  void dispose() {
    // Clean up resources
    super.dispose();
  }
  
  Future<void> loadData() async {
    // Load data
  }
}
```

## Best Practices

1. **One controller per feature** - Keep controllers focused
2. **Business logic in controllers** - Keep views simple
3. **Use computed values** - For derived state
4. **Initialize in constructor** - Set up computed values
5. **Clear method names** - Make intent obvious
6. **Handle errors** - Use try-catch in controller methods

## Testing Controllers

```dart
void main() {
  test('CounterController increments correctly', () {
    final controller = CounterController();
    expect(controller.counter.value, 0);
    
    controller.increment();
    expect(controller.counter.value, 1);
    
    controller.increment();
    expect(controller.counter.value, 2);
  });
  
  test('ShoppingCartController calculates total correctly', () {
    final controller = ShoppingCartController();
    
    controller.addItem(CartItem(
      id: '1',
      name: 'Item 1',
      price: 10.0,
      quantity: 2,
    ));
    
    expect(controller.subtotal.value, 20.0);
    expect(controller.tax.value, 2.0);
    expect(controller.total.value, 22.0);
  });
}
```

## Next Steps

Now that you understand controllers, let's learn about handling asynchronous operations with SwiftFuture.

---

**Previous**: [Computed Values ←](04_computed_values.md) | **Next**: [Async State →](06_async_state.md)

