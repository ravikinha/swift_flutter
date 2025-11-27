# swift_flutter

[![pub package](https://img.shields.io/pub/v/swift_flutter.svg)](https://pub.dev/packages/swift_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A reactive state management library for Flutter with automatic dependency tracking. Inspired by MobX and Vue's reactivity system, but built specifically for Flutter.

## Features

✅ **Reactive State (Rx)** - Automatic dependency tracking  
✅ **Mark Widget** - Auto-rebuild when dependencies change  
✅ **Computed (Derived State)** - Automatically computed values with nested dependency support  
✅ **RxFuture / Async State** - Loading/error/success states for async operations  
✅ **Form Validation** - Field validation with built-in validators  
✅ **Persistence** - Automatic save/load of reactive values  
✅ **Middleware / Interceptors** - Action interception and logging  
✅ **Batch Update Transactions** - Prevent unnecessary rebuilds  
✅ **Debug Logger** - Configurable logging with history  
✅ **Animation Tween** - Reactive animation values  
✅ **Lifecycle Controller** - Widget lifecycle management  
✅ **Global Store / Dependency Injection** - Service registration and state management  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  swift_flutter: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Reactive State

```dart
import 'package:swift_flutter/swift_flutter.dart';

// Automatic type inference (for simple types)
final counter = swift(0);        // Automatically Rx<int>
final name = swift('Hello');     // Automatically Rx<String>
final flag = swift(true);        // Automatically Rx<bool>
final price = swift(99.99);      // Automatically Rx<double>

// Explicit typing (recommended for models/complex types)
final counter = swift<int>(0);                    // Explicit Rx<int>
final user = swift<User>(User('John'));           // For custom models - type required
final list = swift<List<String>>(['a', 'b']);     // For complex generics
final nullable = swift<String?>(null);            // For nullable types

// Traditional way (still works)
final explicit = Rx<int>(0);

// Use in widget with automatic rebuild
Mark(
  builder: (context) => Text('Count: ${counter.value}'),
)

// Update value - widget rebuilds automatically!
counter.value = 10;
```

### Computed Values

```dart
// Automatic type inference
final price = swift(100.0);  // Rx<double>
final quantity = swift(2);  // Rx<int>

// Or explicit typing
final price = swift<double>(100.0);
final quantity = swift<int>(2);

// Automatically recomputes when price or quantity changes
final total = Computed(() => price.value * quantity.value);

Mark(
  builder: (context) => Text('Total: \$${total.value}'),
)
```

### Async State

```dart
final rxFuture = RxFuture<String>();

// Execute async operation
rxFuture.execute(() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded!';
});

// Display state
Mark(
  builder: (context) => rxFuture.value.when(
    idle: () => Text('Click to load'),
    loading: () => CircularProgressIndicator(),
    success: (data) => Text(data),
    error: (error, stack) => Text('Error: $error'),
  ),
)
```

### Form Validation

```dart
final emailField = RxField<String>('');
emailField.addValidator(Validators.required());
emailField.addValidator(Validators.email());

TextField(
  onChanged: (value) => emailField.value = value,
  decoration: InputDecoration(
    errorText: emailField.error,
  ),
)
```

## Documentation

- [Full API Documentation](https://pub.dev/documentation/swift_flutter)
- [Architecture Review](ARCHITECTURE_REVIEW.md)
- [Performance Comparison](PERFORMANCE_COMPARISON.md)

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

**58 tests passing** ✅

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
