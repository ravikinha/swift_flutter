import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx_future.dart';

void main() {
  group('SwiftFuture', () {
    test('should start in idle state', () {
      final swiftFuture = SwiftFuture<String>();
      expect(swiftFuture.value.isIdle, true);
      expect(swiftFuture.isLoading, false);
      expect(swiftFuture.isSuccess, false);
      expect(swiftFuture.isError, false);
    });

    test('should update to loading state', () async {
      final swiftFuture = SwiftFuture<String>();
      final future = swiftFuture.call(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 'success';
      });
      
      expect(swiftFuture.isLoading, true);
      await future;
      expect(swiftFuture.isSuccess, true);
      expect(swiftFuture.data, 'success');
    });

    test('should handle errors', () async {
      final swiftFuture = SwiftFuture<String>();
      
      try {
        await swiftFuture.call(() async {
          throw Exception('Test error');
        });
      } catch (e) {
        // Expected
      }
      
      expect(swiftFuture.isError, true);
      expect(swiftFuture.error, isA<Exception>());
    });

    test('should reset to idle', () {
      final swiftFuture = SwiftFuture<String>();
      swiftFuture.reset();
      expect(swiftFuture.value.isIdle, true);
    });

    test('should use when method correctly', () {
      final swiftFuture = SwiftFuture<String>();
      
      final result = swiftFuture.value.when(
        idle: () => 'idle',
        loading: () => 'loading',
        success: (data) => 'success: $data',
        error: (error, stack) => 'error: $error',
      );
      
      expect(result, 'idle');
    });
  });
}

