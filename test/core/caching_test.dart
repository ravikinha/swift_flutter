import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/caching.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('MemoryCache', () {
    late MemoryCache<String> cache;

    setUp(() {
      cache = MemoryCache<String>(
        strategy: const CacheStrategy(
          maxSize: 3,
          ttl: Duration(seconds: 1),
        ),
      );
    });

    test('should set and get cached data', () {
      cache.set('key1', 'value1');
      final cached = cache.get('key1');

      expect(cached, isNotNull);
      expect(cached!.data, 'value1');
    });

    test('should return null for non-existent key', () {
      final cached = cache.get('nonexistent');
      expect(cached, isNull);
    });

    test('should check if key exists', () {
      cache.set('key1', 'value1');
      expect(cache.has('key1'), isTrue);
      expect(cache.has('key2'), isFalse);
    });

    test('should remove cached data', () {
      cache.set('key1', 'value1');
      cache.remove('key1');
      expect(cache.has('key1'), isFalse);
    });

    test('should clear all cached data', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.clear();
      expect(cache.size, 0);
    });

    test('should expire cached data based on TTL', () async {
      cache.set('key1', 'value1');
      await Future.delayed(const Duration(seconds: 2));

      final cached = cache.get('key1');
      expect(cached, isNull);
    });

    test('should evict LRU entry when max size reached', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');
      cache.set('key4', 'value4'); // Should evict key1

      expect(cache.has('key1'), isFalse);
      expect(cache.has('key4'), isTrue);
    });

    test('should track access count', () {
      cache.set('key1', 'value1');
      final cached1 = cache.get('key1');
      final initialCount = cached1!.accessCount;
      final cached2 = cache.get('key1');

      expect(cached2!.accessCount, greaterThan(initialCount));
    });

    test('should clean expired entries', () async {
      cache.set('key1', 'value1', ttl: const Duration(milliseconds: 100));
      cache.set('key2', 'value2', ttl: const Duration(seconds: 10));

      await Future.delayed(const Duration(milliseconds: 200));
      cache.cleanExpired();

      expect(cache.has('key1'), isFalse);
      expect(cache.has('key2'), isTrue);
    });

    test('should get cache statistics', () {
      cache.set('key1', 'value1');
      final stats = cache.getStats();

      expect(stats['size'], 1);
      expect(stats['maxSize'], 3);
      expect(stats['evictionPolicy'], 'lru');
    });

    test('should get all keys', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');

      final keys = cache.keys;
      expect(keys.length, 2);
      expect(keys, contains('key1'));
      expect(keys, contains('key2'));
    });
  });

  group('MemoryCache - LFU Policy', () {
    late MemoryCache<String> cache;

    setUp(() {
      cache = MemoryCache<String>(
        strategy: const CacheStrategy(
          maxSize: 3,
          evictionPolicy: CacheEvictionPolicy.lfu,
        ),
      );
    });

    test('should evict least frequently used entry', () {
      cache.set('key1', 'value1');
      cache.set('key2', 'value2');
      cache.set('key3', 'value3');

      // Access key1 and key2 multiple times
      cache.get('key1');
      cache.get('key1');
      cache.get('key2');

      // key3 should be evicted (least frequently used)
      cache.set('key4', 'value4');

      expect(cache.has('key3'), isFalse);
      expect(cache.has('key1'), isTrue);
    });
  });

  group('DiskCache', () {
    late DiskCache<String> cache;
    late MemoryStorage storage;

    setUp(() {
      storage = MemoryStorage();
      cache = DiskCache<String>(storage: storage);
    });

    test('should set and get cached data', () async {
      await cache.set('key1', 'value1');
      final cached = await cache.get('key1');

      expect(cached, isNotNull);
      expect(cached!.data, 'value1');
    });

    test('should check if key exists', () async {
      await cache.set('key1', 'value1');
      expect(await cache.has('key1'), isTrue);
      expect(await cache.has('key2'), isFalse);
    });

    test('should remove cached data', () async {
      await cache.set('key1', 'value1');
      await cache.remove('key1');
      expect(await cache.has('key1'), isFalse);
    });

    test('should clear all cached data', () async {
      await cache.set('key1', 'value1');
      await cache.set('key2', 'value2');
      await cache.clear();

      expect(await cache.has('key1'), isFalse);
      expect(await cache.has('key2'), isFalse);
    });
  });

  group('MultiLevelCache', () {
    late MultiLevelCache<String> cache;
    late MemoryStorage storage;

    setUp(() {
      storage = MemoryStorage();
      cache = MultiLevelCache<String>(
        strategy: const CacheStrategy(maxSize: 5),
        diskStorage: storage,
      );
    });

    test('should set and get from memory cache', () async {
      await cache.set('key1', 'value1');
      final value = await cache.get('key1');

      expect(value, 'value1');
    });

    test('should promote disk cache to memory cache', () async {
      // Set in disk cache directly
      await cache.diskCache!.set('key1', 'value1');

      // Get should promote to memory
      final value = await cache.get('key1');
      expect(value, 'value1');

      // Should now be in memory cache
      expect(cache.memoryCache.has('key1'), isTrue);
    });

    test('should check if key exists in either cache', () async {
      await cache.set('key1', 'value1');
      expect(await cache.has('key1'), isTrue);
      expect(await cache.has('key2'), isFalse);
    });

    test('should remove from both caches', () async {
      await cache.set('key1', 'value1');
      await cache.remove('key1');

      expect(cache.memoryCache.has('key1'), isFalse);
      expect(await cache.diskCache!.has('key1'), isFalse);
    });

    test('should clear both caches', () async {
      await cache.set('key1', 'value1');
      await cache.set('key2', 'value2');
      await cache.clear();

      expect(cache.memoryCache.size, 0);
      expect(await cache.diskCache!.has('key1'), isFalse);
    });

    test('should get cache statistics', () {
      final stats = cache.getStats();
      expect(stats['memory'], isNotNull);
      expect(stats['disk'], isNotNull);
    });
  });

  group('CacheManager', () {
    setUp(() {
      CacheManager.clearAll();
    });

    test('should get or create cache', () {
      final cache1 = CacheManager.getCache<String>('test');
      final cache2 = CacheManager.getCache<String>('test');

      expect(identical(cache1, cache2), isTrue);
    });

    test('should get all cache names', () {
      CacheManager.getCache<String>('cache1');
      CacheManager.getCache<int>('cache2');

      final names = CacheManager.getCacheNames();
      expect(names.length, 2);
      expect(names, contains('cache1'));
      expect(names, contains('cache2'));
    });

    test('should remove cache', () async {
      CacheManager.getCache<String>('test');
      await CacheManager.removeCache('test');

      final names = CacheManager.getCacheNames();
      expect(names, isNot(contains('test')));
    });

    test('should clear all caches', () async {
      final cache1 = CacheManager.getCache<String>('cache1');
      final cache2 = CacheManager.getCache<String>('cache2');

      await cache1.set('key1', 'value1');
      await cache2.set('key2', 'value2');

      await CacheManager.clearAll();

      expect(cache1.memoryCache.size, 0);
      expect(cache2.memoryCache.size, 0);
    });
  });

  group('CachedData', () {
    test('should track access count', () {
      final cached = CachedData<String>(data: 'test');
      expect(cached.accessCount, 1);

      cached.markAccessed();
      expect(cached.accessCount, 2);
    });

    test('should check if expired', () {
      final expired = CachedData<String>(
        data: 'test',
        expiresAt: DateTime.now().subtract(const Duration(seconds: 1)),
      );
      expect(expired.isExpired, isTrue);

      final valid = CachedData<String>(
        data: 'test',
        expiresAt: DateTime.now().add(const Duration(seconds: 10)),
      );
      expect(valid.isExpired, isFalse);
    });

    test('should serialize to JSON', () {
      final cached = CachedData<String>(data: 'test');
      final json = cached.toJson();

      expect(json['data'], 'test');
      expect(json['accessCount'], 1);
      expect(json['cachedAt'], isNotNull);
    });
  });
}

