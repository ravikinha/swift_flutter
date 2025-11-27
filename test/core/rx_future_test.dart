import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx_future.dart';

void main() {
  group('RxFuture', () {
    test('should start in idle state', () {
      final rxFuture = RxFuture<String>();
      expect(rxFuture.value.isIdle, true);
      expect(rxFuture.isLoading, false);
      expect(rxFuture.isSuccess, false);
      expect(rxFuture.isError, false);
    });

    test('should update to loading state', () async {
      final rxFuture = RxFuture<String>();
      final future = rxFuture.call(() async {
        await Future.delayed(Duration(milliseconds: 10));
        return 'success';
      });
      
      expect(rxFuture.isLoading, true);
      await future;
      expect(rxFuture.isSuccess, true);
      expect(rxFuture.data, 'success');
    });

    test('should handle errors', () async {
      final rxFuture = RxFuture<String>();
      
      try {
        await rxFuture.call(() async {
          throw Exception('Test error');
        });
      } catch (e) {
        // Expected
      }
      
      expect(rxFuture.isError, true);
      expect(rxFuture.error, isA<Exception>());
    });

    test('should reset to idle', () {
      final rxFuture = RxFuture<String>();
      rxFuture.reset();
      expect(rxFuture.value.isIdle, true);
    });

    test('should use when method correctly', () {
      final rxFuture = RxFuture<String>();
      
      final result = rxFuture.value.when(
        idle: () => 'idle',
        loading: () => 'loading',
        success: (data) => 'success: $data',
        error: (error, stack) => 'error: $error',
      );
      
      expect(result, 'idle');
    });
  });
}

