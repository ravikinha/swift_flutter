# Computed Values

Computed values are derived values that automatically update when their dependencies change. They're perfect for calculations, transformations, and derived state.

## What are Computed Values?

A computed value is a value that's automatically calculated from other reactive values. When any dependency changes, the computed value automatically recalculates.

### Example

```dart
final price = swift(100.0);
final quantity = swift(2);

// Computed value - automatically updates when price or quantity changes
final total = Computed(() => price.value * quantity.value);

Swift(
  builder: (context) => Text('Total: \$${total.value}'),
)
```

When `price` or `quantity` changes, `total` automatically recalculates!

## Creating Computed Values

### Basic Syntax

```dart
final computed = Computed(() => /* calculation */);
```

### Simple Example

```dart
final firstName = swift('John');
final lastName = swift('Doe');

final fullName = Computed(() => '${firstName.value} ${lastName.value}');

Swift(
  builder: (context) => Text(fullName.value),
)
```

## Common Use Cases

### 1. Calculations

```dart
final price = swift(100.0);
final taxRate = swift(0.1);
final quantity = swift(2);

final subtotal = Computed(() => price.value * quantity.value);
final tax = Computed(() => subtotal.value * taxRate.value);
final total = Computed(() => subtotal.value + tax.value);

Swift(
  builder: (context) => Column(
    children: [
      Text('Subtotal: \$${subtotal.value.toStringAsFixed(2)}'),
      Text('Tax: \$${tax.value.toStringAsFixed(2)}'),
      Text('Total: \$${total.value.toStringAsFixed(2)}'),
    ],
  ),
)
```

### 2. String Formatting

```dart
final hours = swift(2);
final minutes = swift(30);

final timeString = Computed(() => 
  '${hours.value}h ${minutes.value}m'
);

Swift(
  builder: (context) => Text(timeString.value),
)
```

### 3. List Operations

```dart
final items = swift<List<Item>>([]);

final itemCount = Computed(() => items.value.length);
final totalPrice = Computed(() => 
  items.value.fold(0.0, (sum, item) => sum + item.price)
);
final isEmpty = Computed(() => items.value.isEmpty);

Swift(
  builder: (context) => Column(
    children: [
      Text('Items: ${itemCount.value}'),
      Text('Total: \$${totalPrice.value.toStringAsFixed(2)}'),
      if (isEmpty.value) Text('Cart is empty'),
    ],
  ),
)
```

### 4. Conditional Logic

```dart
final score = swift(85);
final maxScore = swift(100);

final percentage = Computed(() => 
  (score.value / maxScore.value) * 100
);
final grade = Computed(() {
  final pct = percentage.value;
  if (pct >= 90) return 'A';
  if (pct >= 80) return 'B';
  if (pct >= 70) return 'C';
  return 'F';
});

Swift(
  builder: (context) => Text('Grade: ${grade.value}'),
)
```

## Nested Computed Values

Computed values can depend on other computed values:

```dart
final basePrice = swift(100.0);
final discount = swift(0.1);

final discountedPrice = Computed(() => 
  basePrice.value * (1 - discount.value)
);

final tax = swift(0.05);
final finalPrice = Computed(() => 
  discountedPrice.value * (1 + tax.value)
);

Swift(
  builder: (context) => Text('Price: \$${finalPrice.value.toStringAsFixed(2)}'),
)
```

## Performance Benefits

### Automatic Memoization

Computed values are automatically memoized. They only recalculate when dependencies change:

```dart
final expensive = Computed(() {
  print('Calculating...');  // Only prints when dependencies change
  return heavyCalculation();
});
```

### Avoiding Unnecessary Recalculations

```dart
// ❌ Bad - recalculates on every build
Swift(
  builder: (context) => Text('Total: ${price.value * quantity.value}'),
)

// ✅ Good - only recalculates when dependencies change
final total = Computed(() => price.value * quantity.value);
Swift(
  builder: (context) => Text('Total: ${total.value}'),
)
```

## Complex Examples

### Shopping Cart

```dart
class CartController {
  final items = swift<List<CartItem>>([]);
  
  late final Computed<int> itemCount;
  late final Computed<double> subtotal;
  late final Computed<double> tax;
  late final Computed<double> total;
  late final Computed<bool> isEmpty;
  late final Computed<String> summary;
  
  CartController() {
    itemCount = Computed(() => items.value.length);
    
    subtotal = Computed(() => 
      items.value.fold(0.0, (sum, item) => sum + item.price * item.quantity)
    );
    
    tax = Computed(() => subtotal.value * 0.1);
    
    total = Computed(() => subtotal.value + tax.value);
    
    isEmpty = Computed(() => items.value.isEmpty);
    
    summary = Computed(() => 
      '${itemCount.value} items - \$${total.value.toStringAsFixed(2)}'
    );
  }
}
```

### User Profile

```dart
final firstName = swift('');
final lastName = swift('');
final email = swift('');

final fullName = Computed(() => 
  '${firstName.value} ${lastName.value}'.trim()
);

final displayName = Computed(() => 
  fullName.value.isEmpty ? email.value : fullName.value
);

final isComplete = Computed(() => 
  firstName.value.isNotEmpty && 
  lastName.value.isNotEmpty && 
  email.value.isNotEmpty
);

Swift(
  builder: (context) => Column(
    children: [
      Text('Name: ${displayName.value}'),
      if (isComplete.value) 
        Text('Profile complete!', style: TextStyle(color: Colors.green)),
    ],
  ),
)
```

## Best Practices

1. **Use Computed for derived values** - Don't use SwiftValue for values that can be computed
2. **Keep computations simple** - Move complex logic to methods
3. **Avoid side effects** - Computed should only calculate, not modify state
4. **Use for expensive calculations** - Memoization prevents unnecessary recalculations
5. **Name descriptively** - Make it clear what the computed value represents

## Common Patterns

### Pattern: Form Validation

```dart
final password = swift('');
final confirmPassword = swift('');

final passwordsMatch = Computed(() => 
  password.value == confirmPassword.value && password.value.isNotEmpty
);

final passwordStrength = Computed(() {
  if (password.value.length < 6) return 'Weak';
  if (password.value.length < 10) return 'Medium';
  return 'Strong';
});
```

### Pattern: Filtering

```dart
final searchQuery = swift('');
final allItems = swift<List<Item>>([]);

final filteredItems = Computed(() {
  if (searchQuery.value.isEmpty) return allItems.value;
  return allItems.value.where((item) => 
    item.name.toLowerCase().contains(searchQuery.value.toLowerCase())
  ).toList();
});
```

## Next Steps

Now that you understand computed values, let's learn about the Controller pattern for managing complex state.

---

**Previous**: [Reactive State ←](03_reactive_state.md) | **Next**: [Controllers →](05_controllers.md)

