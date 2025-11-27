# swift_flutter

A reactive state management library for Flutter with automatic dependency tracking.

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

Add to your `pubspec.yaml`:

```yaml
dependencies:
  swift_flutter:
    git:
      url: https://github.com/ravikinha/swift_flutter.git
      ref: main
```

## Quick Start

```dart
import 'package:swift_flutter/swift_flutter.dart';

// Create reactive state
final counter = Rx<int>(0);

// Use in widget with automatic rebuild
Mark(
  builder: (context) => Text('Count: ${counter.value}'),
)

// Update value
counter.value = 10; // Widget rebuilds automatically!
```

## Examples

See `lib/views/main.dart` for comprehensive examples of all features.

Run examples:
```bash
flutter run -t lib/views/main.dart
```

## Documentation

- [Architecture Review](ARCHITECTURE_REVIEW.md)
- [Performance Comparison](PERFORMANCE_COMPARISON.md)

## Testing

All features include comprehensive test coverage:

```bash
flutter test
```

**58 tests passing** ✅

## License

MIT

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
