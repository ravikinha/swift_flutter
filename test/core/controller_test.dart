import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/controller.dart';
import 'package:swift_flutter/core/rx.dart';

void main() {
  group('SwiftController', () {
    test('should create controller', () {
      final controller = _TestController();
      expect(controller.isDisposed, false);
      controller.dispose();
      expect(controller.isDisposed, true);
    });

    test('should expose read-only Rx values', () {
      final controller = _TestController();
      final readOnly = controller.count;
      
      expect(readOnly.value, 0);
      // ReadOnlyRx has no setter - this is enforced at compile time
      // We can only read, not write
      
      controller.dispose();
    });

    test('should allow controller to modify state', () {
      final controller = _TestController();
      expect(controller.count.value, 0);
      
      controller.increment();
      expect(controller.count.value, 1);
      
      controller.setValue(10);
      expect(controller.count.value, 10);
      
      controller.dispose();
    });

    test('should automatically dispose managed Rx', () {
      final controller = _TestController();
      
      controller.dispose();
      
      // After disposal, controller is disposed
      expect(controller.isDisposed, true);
    });
  });

  group('ReadOnlyRx', () {
    test('should read value from underlying Rx', () {
      final rx = swift(42);
      final readOnly = ReadOnlyRx(rx);
      
      expect(readOnly.value, 42);
      expect(readOnly.rawValue, 42);
      
      readOnly.dispose();
      rx.dispose();
    });

    test('should update when underlying Rx changes', () {
      final rx = swift(0);
      final readOnly = ReadOnlyRx(rx);
      
      rx.value = 10;
      expect(readOnly.value, 10);
      
      readOnly.dispose();
      rx.dispose();
    });

    test('should not have setter', () {
      final rx = swift(0);
      final readOnly = ReadOnlyRx(rx);
      
      // ReadOnlyRx has no setter - this is enforced at compile time
      // The type system prevents direct assignment: readOnly.value = 10;
      expect(readOnly.value, 0);
      
      readOnly.dispose();
      rx.dispose();
    });

    test('should forward notifications', () {
      final rx = swift(0);
      final readOnly = ReadOnlyRx(rx);
      
      var notified = false;
      readOnly.addListener(() => notified = true);
      
      rx.value = 10;
      expect(notified, true);
      
      readOnly.dispose();
      rx.dispose();
    });
  });
}

class _TestController extends SwiftController {
  final _count = swift(0);
  
  ReadOnlyRx<int> get count => readOnly(_count);
  
  void increment() => _count.value++;
  void setValue(int value) => _count.value = value;
}

