import 'package:flutter/material.dart';
import 'rx.dart';
import 'computed.dart';
import 'rx_future.dart';
import '../ui/mark.dart';
import '../store/store.dart';
import 'transaction.dart';
import 'logger.dart';

/// Testing utilities for swift_flutter
class SwiftTestHelpers {
  /// Create a mock Rx for testing
  static Rx<T> mockRx<T>(T value) {
    return Rx<T>(value);
  }

  /// Create a mock Computed for testing
  static Computed<T> mockComputed<T>(T Function() compute) {
    return Computed<T>(compute);
  }

  /// Create a mock SwiftFuture for testing
  static SwiftFuture<T> mockSwiftFuture<T>() {
    return SwiftFuture<T>();
  }

  /// Create a test widget with Mark
  static Widget testMark(Widget Function(BuildContext) builder) {
    return MaterialApp(
      home: Scaffold(
        body: Swift(builder: builder),
      ),
    );
  }

  /// Create a test widget with Mark and MaterialApp
  static Widget testMarkWithApp(Widget Function(BuildContext) builder) {
    return MaterialApp(
      home: Swift(builder: builder),
    );
  }

  /// Wait for all async operations to complete
  static Future<void> waitForAsync() async {
    await Future.delayed(const Duration(milliseconds: 100));
  }

  /// Wait for transactions to complete
  static Future<void> waitForTransactions() async {
    // Wait a bit to ensure all transactions are flushed
    await Future.delayed(const Duration(milliseconds: 50));
  }

  /// Wait for a specific condition to be true
  static Future<void> waitForCondition(
    bool Function() condition, {
    Duration timeout = const Duration(seconds: 5),
    Duration pollInterval = const Duration(milliseconds: 100),
  }) async {
    final startTime = DateTime.now();
    while (!condition()) {
      if (DateTime.now().difference(startTime) > timeout) {
        throw TimeoutException(
          'Condition not met within ${timeout.inSeconds} seconds',
        );
      }
      await Future.delayed(pollInterval);
    }
  }

  /// Wait for a specific Rx value
  static Future<void> waitForRxValue<T>(
    Rx<T> rx,
    T expectedValue, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForCondition(
      () => rx.value == expectedValue,
      timeout: timeout,
    );
  }

  /// Wait for SwiftFuture to complete (success or error)
  static Future<void> waitForSwiftFuture<T>(
    SwiftFuture<T> future, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForCondition(
      () => future.isSuccess || future.isError,
      timeout: timeout,
    );
  }

  /// Wait for SwiftFuture to succeed
  static Future<void> waitForSwiftFutureSuccess<T>(
    SwiftFuture<T> future, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForCondition(
      () => future.isSuccess,
      timeout: timeout,
    );
  }

  /// Wait for SwiftFuture to error
  static Future<void> waitForSwiftFutureError<T>(
    SwiftFuture<T> future, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    await waitForCondition(
      () => future.isError,
      timeout: timeout,
    );
  }

  /// Get all registered state keys from store
  static List<String> getRegisteredStateKeys() {
    return store.getAllStateKeys();
  }

  /// Get state keys for a namespace
  static List<String> getStateKeysForNamespace(String namespace) {
    return store.getStateKeysForNamespace(namespace);
  }

  /// Clear all state (useful for test teardown)
  static void clearAllState() {
    store.clear();
  }

  /// Setup test environment
  static void setupTestEnvironment() {
    store.clear();
    Logger.setEnabled(false); // Disable logging in tests by default
    Logger.clear();
  }

  /// Teardown test environment
  static void teardownTestEnvironment() {
    store.clear();
    Logger.clear();
  }

  /// Enable debug mode for testing
  static void enableDebugMode() {
    Logger.setEnabled(true);
    Logger.setLevel(LogLevel.debug);
  }

  /// Disable debug mode
  static void disableDebugMode() {
    Logger.setEnabled(false);
  }

  /// Run a test with transaction support
  static T runInTransaction<T>(T Function() test) {
    return Transaction.run(test);
  }

  /// Create a test that waits for all async operations
  static Future<T> runAsyncTest<T>(
    Future<T> Function() test,
  ) async {
    final result = await test();
    await waitForAsync();
    await waitForTransactions();
    return result;
  }
}

/// Exception thrown when a condition timeout occurs
class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);
  
  @override
  String toString() => 'TimeoutException: $message';
}

/// Mock reactive state for testing
class MockReactiveState {
  final Map<String, Rx<dynamic>> _state = {};

  /// Create or get a mock Rx state
  Rx<T> state<T>(String key, T initialValue) {
    if (!_state.containsKey(key)) {
      _state[key] = Rx<T>(initialValue);
    }
    return _state[key] as Rx<T>;
  }

  /// Clear all mock state
  void clear() {
    for (var state in _state.values) {
      state.dispose();
    }
    _state.clear();
  }

  /// Dispose all state
  void dispose() {
    clear();
  }
}

