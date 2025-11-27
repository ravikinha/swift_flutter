# swift_flutter

[![pub package](https://img.shields.io/pub/v/swift_flutter.svg)](https://pub.dev/packages/swift_flutter)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A reactive state management library for Flutter with automatic dependency tracking. Inspired by MobX and Vue's reactivity system, but built specifically for Flutter.

## Features

✅ **Reactive State (Rx)** - Automatic dependency tracking  
✅ **Mark Widget** - Auto-rebuild when dependencies change  
✅ **Computed (Derived State)** - Automatically computed values with nested dependency support  
✅ **SwiftFuture / Async State** - Loading/error/success states for async operations  
✅ **SwiftField / Form Validation** - Field validation with built-in validators  
✅ **SwiftPersisted / Persistence** - Automatic save/load of reactive values  
✅ **Middleware / Interceptors** - Action interception and logging  
✅ **Batch Update Transactions** - Prevent unnecessary rebuilds  
✅ **Debug Logger** - Configurable logging with history  
✅ **SwiftTween / Animation Tween** - Reactive animation values  
✅ **Lifecycle Controller** - Widget lifecycle management  
✅ **Global Store / Dependency Injection** - Service registration and state management  

## Installation

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  swift_flutter: ^1.1.0
```

Then run:

```bash
flutter pub get
```

## Quick Start

### Basic Reactive State

```dart
import 'package:swift_flutter/swift_flutter.dart';

// Create reactive state with automatic type inference
// The swift() function automatically infers the type from the value
final counter = swift(0);        // Creates Rx<int> automatically
final name = swift('Hello');     // Creates Rx<String> automatically
final flag = swift(true);        // Creates Rx<bool> automatically
final price = swift(99.99);      // Creates Rx<double> automatically

// For custom models or complex types, use explicit type annotation
// This ensures type safety and better IDE support
final counter = swift<int>(0);                    // Explicitly typed as Rx<int>
final user = swift<User>(User('John'));           // Required for custom classes
final list = swift<List<String>>(['a', 'b']);    // Required for generic types
final nullable = swift<String?>(null);            // Required for nullable types

// Alternative: Use Rx constructor directly (still supported)
final explicit = Rx<int>(0);

// Wrap your widget with Mark to enable automatic rebuilds
// Mark automatically tracks dependencies and rebuilds when values change
Mark(
  builder: (context) => Text('Count: ${counter.value}'),
)

// Simply update the value - the widget rebuilds automatically!
// No need to call setState() or manage listeners manually
counter.value = 10;
```

### Computed Values (Derived State)

```dart
// Create reactive state variables
// These will be tracked as dependencies for computed values
final price = swift(100.0);  // Reactive price value
final quantity = swift(2);   // Reactive quantity value

// Or use explicit typing for better type safety
final price = swift<double>(100.0);
final quantity = swift<int>(2);

// Create a computed value that automatically updates
// when its dependencies (price or quantity) change
// The computation function is only called when dependencies change
final total = Computed(() => price.value * quantity.value);

// Use the computed value in your UI
// It will automatically update when price or quantity changes
Mark(
  builder: (context) => Text('Total: \$${total.value}'),
)
```

### Async State Management

```dart
// Create a SwiftFuture to manage async operations
// It automatically tracks loading, success, and error states
final swiftFuture = SwiftFuture<String>();

// Execute an async operation
// The state automatically transitions: idle → loading → success/error
swiftFuture.execute(() async {
  await Future.delayed(Duration(seconds: 2));
  return 'Data loaded!';
});

// Display different UI based on the current async state
// The when() method provides a type-safe way to handle all states
Mark(
  builder: (context) => swiftFuture.value.when(
    idle: () => Text('Click to load'),              // Initial state
    loading: () => CircularProgressIndicator(),     // Loading indicator
    success: (data) => Text(data),                  // Success with data
    error: (error, stack) => Text('Error: $error'), // Error handling
  ),
)
```

### Form Validation

```dart
final emailField = SwiftField<String>('');
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

**67+ tests passing** ✅

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
