# Getting Started

## Installation

The first step to using swift_flutter is adding it to your project. Let's get started!

### Step 1: Add Dependency

Open your `pubspec.yaml` file and add swift_flutter to your dependencies:

```yaml
dependencies:
  flutter:
    sdk: flutter
  swift_flutter: ^2.1.0
```

### Step 2: Install Package

Run the following command in your terminal:

```bash
flutter pub get
```

This will download and install the swift_flutter package along with its dependencies.

### Step 3: Import the Library

In any Dart file where you want to use swift_flutter, add this import:

```dart
import 'package:swift_flutter/swift_flutter.dart';
```

If you want to use the Swift-like extensions, also import:

```dart
import 'package:swift_flutter/core/extensions.dart';
```

### Step 4: Verify Installation

Create a simple test to verify everything is working:

```dart
import 'package:flutter/material.dart';
import 'package:swift_flutter/swift_flutter.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'swift_flutter Demo',
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a reactive value
    final counter = swift(0);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('swift_flutter Demo'),
      ),
      body: Center(
        child: Swift(
          builder: (context) => Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Counter: ${counter.value}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => counter.value++,
                child: const Text('Increment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

If this runs without errors, congratulations! You've successfully installed swift_flutter.

## Project Structure

For a well-organized project using swift_flutter, consider this structure:

```
lib/
├── main.dart
├── models/          # Data models
├── controllers/     # SwiftController classes
├── views/           # UI widgets
├── services/        # Business logic services
└── utils/           # Utility functions
```

## Version Compatibility

swift_flutter requires:

- **Flutter SDK**: >=3.0.0
- **Dart SDK**: >=3.0.0 <4.0.0

Make sure your Flutter version is compatible before installing.

## Next Steps

Now that you have swift_flutter installed, let's learn about the core concepts that make this library powerful.

---

**Previous**: [Introduction ←](00_introduction.md) | **Next**: [Core Concepts →](02_basic_concepts.md)

