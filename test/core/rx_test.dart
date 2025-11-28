import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx.dart';

void main() {
  group('Rx', () {
    test('should initialize with value', () {
      final rx = swift(42);
      expect(rx.value, 42);
    });

    test('should update value', () {
      final rx = swift(0);
      rx.value = 10;
      expect(rx.value, 10);
    });

    test('should not notify if value unchanged', () {
      final rx = swift(5);
      var notified = false;
      rx.addListener(() => notified = true);
      
      rx.value = 5; // Same value
      expect(notified, false);
      
      rx.value = 10; // Different value
      expect(notified, true);
    });

    test('should update using update method', () {
      final rx = swift('hello');
      rx.update('world');
      expect(rx.value, 'world');
    });

    test('should return rawValue without dependency tracking', () {
      final rx = swift(100);
      expect(rx.rawValue, 100);
    });

    test('toString should return value string', () {
      final rx = swift(42);
      expect(rx.toString(), '42');
    });
  });
}

