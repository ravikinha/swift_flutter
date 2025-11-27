# Swift Flutter DevTools Integration

Full DevTools integration for Swift Flutter with **zero performance impact** when disabled.

## Features

✅ **Dependency Graph Visualization** - See all reactive dependencies  
✅ **State Inspector** - Inspect all Rx, Computed, and Store states  
✅ **Performance Monitoring** - Track rebuilds and update times  
✅ **Time-Travel Debugging** - Debug ReduxStore with action history  
✅ **Zero Overhead** - Completely disabled in production builds  

## Quick Start

### Enable DevTools

```dart
import 'package:swift_flutter/swift_flutter.dart';

void main() {
  // Enable DevTools (only in debug mode)
  if (kDebugMode) {
    SwiftDevTools.enable(
      trackDependencies: true,    // Track dependency graph
      trackStateHistory: false,   // Track state changes (optional)
      trackPerformance: true,     // Track performance metrics
    );
  }
  
  runApp(MyApp());
}
```

### Use Named States (Recommended)

Name your reactive states for better DevTools visualization:

```dart
// Named Rx
final counter = swift(0, name: 'counter');
final user = swift<User?>(null, name: 'user');

// Named Computed
final total = Computed(() => price.value * quantity.value, name: 'total');
```

## API Reference

### SwiftDevTools

#### Enable/Disable

```dart
// Enable with options
SwiftDevTools.enable(
  trackDependencies: true,    // Track dependency graph (minimal overhead)
  trackStateHistory: false,   // Track state history (moderate overhead)
  trackPerformance: true,     // Track performance (minimal overhead)
);

// Disable (zero overhead)
SwiftDevTools.disable();

// Check if enabled
if (SwiftDevTools.isEnabled) {
  // DevTools is active
}
```

#### Get Dependency Graph

```dart
final graph = SwiftDevTools.getDependencyGraph();
// Returns:
// {
//   'nodes': [...],  // All state nodes (Rx, Computed, Mark)
//   'edges': [...],  // Dependency relationships
//   'rxCount': 10,
//   'computedCount': 5,
//   'markCount': 8,
// }
```

#### Get State Inspector Data

```dart
final inspector = SwiftDevTools.getStateInspector();
// Returns:
// {
//   'states': {
//     'counter': {
//       'type': 'Rx',
//       'name': 'counter',
//       'value': 42,
//       'hasListeners': true,
//     },
//     ...
//   },
//   'totalCount': 15,
//   'timestamp': '2024-01-01T00:00:00Z',
// }
```

#### Get Performance Report

```dart
final report = SwiftDevTools.getPerformanceReport();
// Returns:
// {
//   'rebuilds': {...},
//   'avgUpdateTime': {...},
//   'recentEvents': [...],
//   'totalEvents': 100,
// }
```

#### Get State History

```dart
final history = SwiftDevTools.getStateHistory(limit: 50);
// Returns list of state changes:
// [
//   {
//     'stateId': 'counter',
//     'oldValue': 0,
//     'newValue': 1,
//     'timestamp': '2024-01-01T00:00:00Z',
//   },
//   ...
// ]
```

#### Time-Travel Debugging

```dart
// For ReduxStore
final store = ReduxStore<int>(0, reducer);

// Get time-travel data
final timeTravel = SwiftDevTools.getTimeTravelData(storeId);
// Returns:
// {
//   'currentState': 42,
//   'actionHistory': [
//     {'type': 'INCREMENT', 'payload': {...}, 'timestamp': '...'},
//     ...
//   ],
//   'canTimeTravel': true,
// }
```

#### Configuration

```dart
// Set max history size
SwiftDevTools.setMaxHistorySize(1000);

// Set max performance events
SwiftDevTools.setMaxPerformanceEvents(500);

// Clear all tracking data
SwiftDevTools.clear();
```

## Flutter DevTools Extension

To use with Flutter DevTools extension, create a service connector:

```dart
// In your app
class SwiftDevToolsService {
  static Map<String, dynamic> handleRequest(String method, Map<String, dynamic>? params) {
    switch (method) {
      case 'getDependencyGraph':
        return SwiftDevTools.getDependencyGraph();
      case 'getStateInspector':
        return SwiftDevTools.getStateInspector();
      case 'getPerformanceReport':
        return SwiftDevTools.getPerformanceReport();
      case 'getStateHistory':
        final limit = params?['limit'] as int?;
        return {'history': SwiftDevTools.getStateHistory(limit: limit)};
      default:
        return {'error': 'Unknown method: $method'};
    }
  }
}
```

## Performance Impact

### When Disabled (Default)
- **Zero overhead** - All tracking is conditional
- No memory allocation
- No CPU usage
- Production-ready

### When Enabled
- **Dependency Tracking**: ~1-2% overhead (minimal)
- **State History**: ~5-10% overhead (moderate, optional)
- **Performance Tracking**: ~1-2% overhead (minimal)

### Best Practices

1. **Only enable in debug mode**:
   ```dart
   if (kDebugMode) {
     SwiftDevTools.enable();
   }
   ```

2. **Disable state history in production** (if enabled):
   ```dart
   SwiftDevTools.enable(
     trackStateHistory: false,  // Disable for production
   );
   ```

3. **Use named states** for better debugging:
   ```dart
   final counter = swift(0, name: 'counter');
   ```

4. **Limit history size** for large apps:
   ```dart
   SwiftDevTools.setMaxHistorySize(500);
   ```

## Example

```dart
import 'package:flutter/foundation.dart';
import 'package:swift_flutter/swift_flutter.dart';

void main() {
  // Enable DevTools in debug mode
  if (kDebugMode) {
    SwiftDevTools.enable(
      trackDependencies: true,
      trackPerformance: true,
    );
  }
  
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // Named states for better DevTools visualization
  final counter = swift(0, name: 'counter');
  final price = swift(100.0, name: 'price');
  final quantity = swift(2, name: 'quantity');
  
  // Named computed
  final total = Computed(
    () => price.value * quantity.value,
    name: 'total',
  );
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Mark(
          builder: (context) => Column(
            children: [
              Text('Counter: ${counter.value}'),
              Text('Total: \$${total.value}'),
              ElevatedButton(
                onPressed: () => counter.value++,
                child: Text('Increment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  // Get DevTools data
  void debugInfo() {
    if (SwiftDevTools.isEnabled) {
      final graph = SwiftDevTools.getDependencyGraph();
      final inspector = SwiftDevTools.getStateInspector();
      final performance = SwiftDevTools.getPerformanceReport();
      
      print('Dependency Graph: $graph');
      print('State Inspector: $inspector');
      print('Performance: $performance');
    }
  }
}
```

## Integration with Flutter DevTools

The DevTools service provides JSON APIs that can be consumed by a Flutter DevTools extension. The extension can:

1. **Visualize Dependency Graph** - Show all Rx, Computed, and Mark relationships
2. **Inspect State** - View current values of all reactive states
3. **Monitor Performance** - Track rebuilds and update times
4. **Time-Travel Debug** - Step through ReduxStore action history

## Troubleshooting

### DevTools not showing data

1. Make sure DevTools is enabled:
   ```dart
   if (SwiftDevTools.isEnabled) {
     print('DevTools is enabled');
   }
   ```

2. Check if states are named:
   ```dart
   final counter = swift(0, name: 'counter');  // Named
   ```

3. Verify tracking is enabled:
   ```dart
   SwiftDevTools.enable(trackDependencies: true);
   ```

### Performance issues

1. Disable state history if not needed:
   ```dart
   SwiftDevTools.enable(trackStateHistory: false);
   ```

2. Reduce history size:
   ```dart
   SwiftDevTools.setMaxHistorySize(100);
   ```

3. Clear old data:
   ```dart
   SwiftDevTools.clear();
   ```

## Summary

Swift Flutter DevTools provides comprehensive debugging capabilities with **zero performance impact** when disabled. Enable it in debug mode for powerful state inspection and performance monitoring.

