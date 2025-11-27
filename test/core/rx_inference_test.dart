import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx.dart';

class _TestUser {
  final String name;
  _TestUser(this.name);
}

void main() {
  group('Swift Type Inference', () {
    test('should infer int type automatically', () {
      final counter = swift(0);
      expect(counter.value, 0);
      expect(counter.value is int, true);
    });

    test('should work with explicit int type', () {
      final counter = swift<int>(0);
      expect(counter.value, 0);
      expect(counter.value is int, true);
    });

    test('should infer String type automatically', () {
      final name = swift('hello');
      expect(name.value, 'hello');
      expect(name.value is String, true);
    });

    test('should work with explicit String type', () {
      final name = swift<String>('hello');
      expect(name.value, 'hello');
      expect(name.value is String, true);
    });

    test('should infer bool type automatically', () {
      final flag = swift(true);
      expect(flag.value, true);
      expect(flag.value is bool, true);
    });

    test('should work with explicit bool type', () {
      final flag = swift<bool>(true);
      expect(flag.value, true);
      expect(flag.value is bool, true);
    });

    test('should infer double type automatically', () {
      final price = swift(99.99);
      expect(price.value, 99.99);
      expect(price.value is double, true);
    });

    test('should work with explicit double type', () {
      final price = swift<double>(99.99);
      expect(price.value, 99.99);
      expect(price.value is double, true);
    });

    test('should infer List type automatically', () {
      final list = swift([1, 2, 3]);
      expect(list.value, [1, 2, 3]);
      expect(list.value is List<int>, true);
    });

    test('should work with explicit List type', () {
      final list = swift<List<int>>([1, 2, 3]);
      expect(list.value, [1, 2, 3]);
      expect(list.value is List<int>, true);
    });

    test('should infer Map type automatically', () {
      final map = swift({'key': 'value'});
      expect(map.value['key'], 'value');
      expect(map.value is Map<String, String>, true);
    });

    test('should work with explicit Map type', () {
      final map = swift<Map<String, String>>({'key': 'value'});
      expect(map.value['key'], 'value');
      expect(map.value is Map<String, String>, true);
    });

    test('should work with null values and explicit type', () {
      final nullable = swift<String?>(null);
      expect(nullable.value, null);
    });

    test('should work with custom model types', () {
      final user = swift<_TestUser>(_TestUser('John'));
      expect(user.value.name, 'John');
      expect(user.value is _TestUser, true);
    });
  });
}

