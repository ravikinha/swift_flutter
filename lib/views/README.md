# Swift Flutter - Feature Examples

This directory contains a comprehensive example app demonstrating all features of the Swift Flutter library.

## Running the Examples

To run the example app, update your main entry point:

```dart
// In your app's main.dart or run configuration
import 'package:swift_flutter/views/main.dart' as examples;

void main() {
  examples.main();
}
```

Or run directly:
```bash
flutter run -t lib/views/main.dart
```

## Features Demonstrated

1. **Reactive State (Rx)** - Basic reactive state management with automatic dependency tracking
2. **Computed (Derived State)** - Automatically computed values that update when dependencies change
3. **RxFuture (Async State)** - Handling async operations with loading/error/success states
4. **Form Validation** - Field validation with built-in validators
5. **Transactions (Batch Updates)** - Batching multiple updates to prevent unnecessary rebuilds
6. **Animation Tween** - Reactive animations with smooth interpolation
7. **Lifecycle Controller** - Managing widget lifecycle states
8. **Persistence** - Automatic save/load of reactive values
9. **Global Store / DI** - Dependency injection and global state management
10. **Logger** - Debug logging with history and levels

Each feature is demonstrated in an expandable card with interactive examples.

