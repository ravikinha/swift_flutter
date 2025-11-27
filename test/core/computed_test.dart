import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx.dart';
import 'package:swift_flutter/core/computed.dart';

void main() {
  group('Computed', () {
    test('should compute value from dependencies', () {
      final a = Rx<int>(5);
      final b = Rx<int>(10);
      final sum = Computed<int>(() => a.value + b.value);
      
      expect(sum.value, 15);
    });

    test('should update when dependency changes', () {
      final a = Rx<int>(5);
      final b = Rx<int>(10);
      final sum = Computed<int>(() => a.value + b.value);
      
      expect(sum.value, 15);
      
      a.value = 20;
      expect(sum.value, 30);
    });

    test('should notify listeners when recomputed', () {
      final a = Rx<int>(5);
      final sum = Computed<int>(() => a.value * 2);
      
      var notified = false;
      sum.addListener(() => notified = true);
      
      a.value = 10;
      expect(notified, true);
      expect(sum.value, 20);
    });

    test('should handle multiple dependencies', () {
      final x = Rx<int>(1);
      final y = Rx<int>(2);
      final z = Rx<int>(3);
      final product = Computed<int>(() => x.value * y.value * z.value);
      
      expect(product.value, 6);
      
      x.value = 2;
      expect(product.value, 12);
    });

    test('should dispose properly', () {
      final a = Rx<int>(5);
      final sum = Computed<int>(() => a.value + 10);
      
      // Get value before dispose
      expect(sum.value, 15);
      
      // Should not throw when disposing
      expect(() => sum.dispose(), returnsNormally);
      // Should not throw when disposing again (idempotent)
      expect(() => sum.dispose(), returnsNormally);
    });
  });
}

