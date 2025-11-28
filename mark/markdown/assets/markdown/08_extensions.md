# Swift-like Extensions

swift_flutter provides 80+ convenient extension methods that make your code more readable and expressive. These extensions work on both regular Dart types and SwiftValue.

## Why Extensions?

Extensions allow you to add methods to existing types, making your code more fluent and readable:

```dart
// Without extensions
counter.value = counter.value + 1;
isActive.value = !isActive.value;

// With extensions
counter.add(1);
isActive.toggle();
```

## Bool Extensions

### Toggle

```dart
bool flag = true;
flag = flag.toggle(); // false

// Works with SwiftValue too
final isVisible = swift(true);
isVisible.toggle(); // isVisible.value is now false
```

## Number Extensions

### Basic Operations

```dart
int count = 10;
count = count.add(5);      // 15
count = count.sub(3);      // 12
count = count.mul(2);      // 24
double result = count.div(3); // 8.0
```

### Percentage Operations

```dart
double price = 100.0;
price = price.applyPercent(20);  // 120.0 (add 20%)
price = price.discount(10);       // 108.0 (subtract 10%)
price = price.tax(5);             // 113.4 (add 5% tax)
price = price.addGST(10);         // 124.74 (add 10% GST)
price = price.removeGST(10);      // Back to 113.4
```

### Range Operations

```dart
int count = 150;
count = count.clamped(min: 0, max: 100); // 100
bool inRange = count.isBetween(0, 100);   // true
```

### Formatting

```dart
int amount = 1000;
String currency = amount.toCurrency();     // '$1,000.00'
String readable = 1500.toReadable();       // '1.5K'
String inr = 10000.toINR();               // '₹10,000'
```

### With SwiftValue

```dart
final counter = swift(10);
counter.add(5);    // counter.value is now 15
counter.sub(3);    // counter.value is now 12
counter.mul(2);    // counter.value is now 24

final price = swift(100.0);
price.applyPercent(20);  // price.value is now 120.0
price.discount(10);      // price.value is now 108.0
```

## String Extensions

### Basic Operations

```dart
String name = 'hello';
name = name.capitalized;        // 'Hello'
name = name.add(' world');      // 'Hello world'
name = name.dropFirst();        // 'ello world'
name = name.dropLast();         // 'ello worl'
```

### Checks

```dart
String text = 'Hello';
bool isEmpty = text.isEmpty;        // false
bool isNotEmpty = text.isNotEmpty;  // true
```

### With SwiftValue

```dart
final name = swift('hello');
name.add(' world');      // name.value is now 'hello world'
name.capitalized;        // Returns 'Hello world' (read-only)
name.dropFirst();        // Returns 'ello world' (read-only)
```

## List Extensions

### Basic Operations

```dart
List<int> numbers = [1, 2, 3, 4, 5];
numbers = numbers.dropFirst();  // [2, 3, 4, 5]
numbers = numbers.dropLast();   // [2, 3, 4]
bool found = numbers.containsWhere((n) => n > 3); // true
```

### With SwiftValue

```dart
final numbers = swift<List<int>>([1, 2, 3]);
numbers.dropFirst();     // Returns [2, 3] (read-only)
```

## Complete Extension List

### Bool Extensions
- `toggle()` - Toggle boolean value

### Int/Double Extensions
- `add(value)` - Add to number
- `sub(value)` - Subtract from number
- `mul(value)` - Multiply number
- `div(value)` - Divide number
- `percent(value)` - Get percentage
- `applyPercent(value)` - Add percentage
- `discount(value)` - Apply discount
- `tax(value)` - Add tax
- `addGST(value)` - Add GST
- `removeGST(value)` - Remove GST
- `clamped(min, max)` - Clamp to range
- `isBetween(min, max)` - Check if in range
- `lerp(end, t)` - Linear interpolation
- `mapRange(fromMin, fromMax, toMin, toMax)` - Map to range
- `toCurrency()` - Format as currency
- `toINR()` - Format as Indian Rupee
- `toReadable()` - Format as readable (1.5K, etc.)
- `toOrdinal()` - Convert to ordinal (1st, 2nd, etc.)

### String Extensions
- `capitalized` - Capitalize first letter
- `add(value)` - Concatenate strings
- `dropFirst()` - Remove first character
- `dropLast()` - Remove last character
- `isEmpty` - Check if empty
- `isNotEmpty` - Check if not empty

### List Extensions
- `dropFirst()` - Remove first element
- `dropLast()` - Remove last element
- `containsWhere(predicate)` - Check if contains matching element

## Practical Examples

### Example: Shopping Cart

```dart
class CartController extends SwiftController {
  final items = swift<List<CartItem>>([]);
  final basePrice = swift(100.0);
  final discountPercent = swift(10.0);
  final taxPercent = swift(5.0);
  
  late final Computed<double> discountedPrice;
  late final Computed<double> finalPrice;
  
  CartController() {
    discountedPrice = Computed(() => 
      basePrice.value.discount(discountPercent.value)
    );
    
    finalPrice = Computed(() => 
      discountedPrice.value.tax(taxPercent.value)
    );
  }
  
  void applyDiscount(double percent) {
    discountPercent.value = percent;
  }
  
  void increasePrice(double amount) {
    basePrice.add(amount);
  }
  
  void decreasePrice(double amount) {
    basePrice.sub(amount);
  }
}
```

### Example: Counter with Limits

```dart
class CounterController extends SwiftController {
  final count = swift(0);
  
  void increment() {
    count.add(1);
    // Ensure count stays within bounds
    count.value = count.value.clamped(min: 0, max: 100);
  }
  
  void decrement() {
    count.sub(1);
    count.value = count.value.clamped(min: 0, max: 100);
  }
  
  bool get canIncrement => count.value.isBetween(0, 99);
  bool get canDecrement => count.value.isBetween(1, 100);
}
```

### Example: Form with String Operations

```dart
class UserController extends SwiftController {
  final firstName = swift('');
  final lastName = swift('');
  
  late final Computed<String> fullName;
  late final Computed<String> displayName;
  
  UserController() {
    fullName = Computed(() => 
      '${firstName.value} ${lastName.value}'.trim()
    );
    
    displayName = Computed(() => 
      fullName.value.isEmpty 
        ? 'Guest' 
        : fullName.value.capitalized
    );
  }
  
  void updateFirstName(String name) {
    firstName.value = name.capitalized;
  }
  
  void updateLastName(String name) {
    lastName.value = name.capitalized;
  }
}
```

## Best Practices

1. **Use extensions for readability** - Make code more expressive
2. **Combine with computed** - Use extensions in computed values
3. **Know when to use** - Don't overuse, keep code clear
4. **Import extensions** - Remember to import if needed
5. **Works with SwiftValue** - Extensions work on reactive values too

## Next Steps

Now that you understand extensions, let's learn about advanced patterns and best practices.

---

**Previous**: [Form Validation ←](07_form_validation.md) | **Next**: [Advanced Patterns →](09_advanced_patterns.md)

