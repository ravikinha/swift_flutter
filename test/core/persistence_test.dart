import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('RxPersisted', () {
    late MemoryStorage storage;

    setUp(() {
      storage = MemoryStorage();
    });

    test('should save and load value', () async {
      final rx = RxPersisted<int>(
        42,
        'test_key',
        storage,
      );

      // Wait for initial load
      await Future.delayed(Duration(milliseconds: 10));

      // Change value (should auto-save)
      rx.value = 100;
      await Future.delayed(Duration(milliseconds: 10));

      // Create new instance and load
      final rx2 = RxPersisted<int>(
        0,
        'test_key',
        storage,
      );
      await Future.delayed(Duration(milliseconds: 10));

      expect(rx2.value, 100);
    });

    test('should use custom fromJson/toJson', () async {
      final rx = RxPersisted<Map<String, int>>(
        {'count': 5},
        'test_key',
        storage,
        fromJson: (json) => {'count': json['count'] as int},
        toJson: (val) => {'count': val['count']},
      );

      rx.value = {'count': 10};
      await Future.delayed(Duration(milliseconds: 10));

      final rx2 = RxPersisted<Map<String, int>>(
        {},
        'test_key',
        storage,
        fromJson: (json) => {'count': json['count'] as int},
        toJson: (val) => {'count': val['count']},
      );
      await Future.delayed(Duration(milliseconds: 10));

      expect(rx2.value['count'], 10);
    });

    test('should clear persisted value', () async {
      final rx = RxPersisted<int>(
        42,
        'test_key',
        storage,
      );
      rx.value = 100;
      await Future.delayed(Duration(milliseconds: 10));

      await rx.clear();
      final loaded = await storage.load('test_key');
      expect(loaded, null);
    });
  });
}

