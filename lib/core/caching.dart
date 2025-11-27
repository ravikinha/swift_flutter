import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'persistence.dart' show StorageBackend;

/// Cache eviction policy
enum CacheEvictionPolicy {
  lru, // Least Recently Used
  lfu, // Least Frequently Used
  fifo, // First In First Out
  ttl, // Time To Live only
}

/// Cached data wrapper
class CachedData<T> {
  final T data;
  final DateTime cachedAt;
  final DateTime? expiresAt;
  int accessCount;
  DateTime lastAccessedAt;

  CachedData({
    required this.data,
    DateTime? cachedAt,
    this.expiresAt,
    this.accessCount = 1,
    DateTime? lastAccessedAt,
  })  : cachedAt = cachedAt ?? DateTime.now(),
        lastAccessedAt = lastAccessedAt ?? DateTime.now();

  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  void markAccessed() {
    accessCount++;
    lastAccessedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
        'data': data,
        'cachedAt': cachedAt.toIso8601String(),
        if (expiresAt != null) 'expiresAt': expiresAt!.toIso8601String(),
        'accessCount': accessCount,
        'lastAccessedAt': lastAccessedAt.toIso8601String(),
      };
}

/// Cache strategy configuration
class CacheStrategy {
  final Duration ttl;
  final int maxSize;
  final CacheEvictionPolicy evictionPolicy;
  final bool enableMemoryCache;
  final bool enableDiskCache;

  const CacheStrategy({
    this.ttl = const Duration(minutes: 5),
    this.maxSize = 100,
    this.evictionPolicy = CacheEvictionPolicy.lru,
    this.enableMemoryCache = true,
    this.enableDiskCache = false,
  });
}

/// Memory cache implementation
class MemoryCache<T> {
  final CacheStrategy strategy;
  final LinkedHashMap<String, CachedData<T>> _cache = LinkedHashMap();
  final Map<String, int> _accessFrequency = {};

  MemoryCache({CacheStrategy? strategy})
      : strategy = strategy ?? const CacheStrategy();

  /// Get cached data
  CachedData<T>? get(String key) {
    final cached = _cache[key];
    if (cached == null) return null;

    if (cached.isExpired) {
      _cache.remove(key);
      _accessFrequency.remove(key);
      return null;
    }

    cached.markAccessed();
    _accessFrequency[key] = (_accessFrequency[key] ?? 0) + 1;

    // Move to end for LRU
    if (strategy.evictionPolicy == CacheEvictionPolicy.lru) {
      _cache.remove(key);
      _cache[key] = cached;
    }

    return cached;
  }

  /// Set cached data
  void set(String key, T data, {Duration? ttl}) {
    final expiresAt = ttl != null || strategy.ttl.inSeconds > 0
        ? DateTime.now().add(ttl ?? strategy.ttl)
        : null;

    final cached = CachedData<T>(
      data: data,
      expiresAt: expiresAt,
    );

    // Evict if necessary
    if (_cache.length >= strategy.maxSize) {
      _evict();
    }

    _cache[key] = cached;
    _accessFrequency[key] = 1;
  }

  /// Check if key exists and is not expired
  bool has(String key) {
    final cached = _cache[key];
    if (cached == null) return false;
    if (cached.isExpired) {
      _cache.remove(key);
      _accessFrequency.remove(key);
      return false;
    }
    return true;
  }

  /// Remove cached data
  void remove(String key) {
    _cache.remove(key);
    _accessFrequency.remove(key);
  }

  /// Clear all cached data
  void clear() {
    _cache.clear();
    _accessFrequency.clear();
  }

  /// Get cache size
  int get size => _cache.length;

  /// Get all keys
  List<String> get keys => _cache.keys.toList();

  /// Evict based on policy
  void _evict() {
    if (_cache.isEmpty) return;

    String? keyToRemove;

    switch (strategy.evictionPolicy) {
      case CacheEvictionPolicy.lru:
        // Remove least recently used (first in LinkedHashMap)
        keyToRemove = _cache.keys.first;
        break;

      case CacheEvictionPolicy.lfu:
        // Remove least frequently used
        var minFreq = double.infinity;
        for (final entry in _accessFrequency.entries) {
          if (entry.value < minFreq) {
            minFreq = entry.value.toDouble();
            keyToRemove = entry.key;
          }
        }
        break;

      case CacheEvictionPolicy.fifo:
        // Remove first in (first in LinkedHashMap)
        keyToRemove = _cache.keys.first;
        break;

      case CacheEvictionPolicy.ttl:
        // Remove expired entries first
        for (final entry in _cache.entries) {
          if (entry.value.isExpired) {
            keyToRemove = entry.key;
            break;
          }
        }
        // If no expired, remove oldest
        keyToRemove ??= _cache.keys.first;
        break;
    }

    if (keyToRemove != null) {
      _cache.remove(keyToRemove);
      _accessFrequency.remove(keyToRemove);
    }
  }

  /// Clean expired entries
  void cleanExpired() {
    final expiredKeys = <String>[];
    for (final entry in _cache.entries) {
      if (entry.value.isExpired) {
        expiredKeys.add(entry.key);
      }
    }
    for (final key in expiredKeys) {
      _cache.remove(key);
      _accessFrequency.remove(key);
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': strategy.maxSize,
      'evictionPolicy': strategy.evictionPolicy.name,
      'ttl': strategy.ttl.inSeconds,
    };
  }
}

/// Disk cache implementation
class DiskCache<T> {
  final StorageBackend storage;
  final CacheStrategy strategy;
  final String prefix;

  DiskCache({
    required this.storage,
    CacheStrategy? strategy,
    this.prefix = 'cache_',
  }) : strategy = strategy ?? const CacheStrategy();

  /// Get cached data
  Future<CachedData<T>?> get(String key) async {
    try {
      final jsonString = await storage.load('$prefix$key');
      if (jsonString == null) return null;

      // Deserialize from JSON
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final cachedAt = DateTime.parse(json['cachedAt'] as String);
      final data = json['data'] as T;

      final cached = CachedData<T>(
        data: data,
        cachedAt: cachedAt,
      );

      if (cached.isExpired) {
        await remove(key);
        return null;
      }

      return cached;
    } catch (e) {
      debugPrint('Error reading from disk cache: $e');
      return null;
    }
  }

  /// Set cached data
  Future<void> set(String key, T data, {Duration? ttl}) async {
    try {
      final json = {
        'data': data,
        'cachedAt': DateTime.now().toIso8601String(),
      };
      await storage.save('$prefix$key', jsonEncode(json));
    } catch (e) {
      debugPrint('Error writing to disk cache: $e');
    }
  }

  /// Check if key exists
  Future<bool> has(String key) async {
    final data = await get(key);
    return data != null;
  }

  /// Remove cached data
  Future<void> remove(String key) async {
    try {
      await storage.delete('$prefix$key');
    } catch (e) {
      debugPrint('Error removing from disk cache: $e');
    }
  }

  /// Clear all cached data
  Future<void> clear() async {
    try {
      await storage.clear();
    } catch (e) {
      debugPrint('Error clearing disk cache: $e');
    }
  }
}

/// Multi-level cache (Memory + Disk)
class MultiLevelCache<T> {
  final MemoryCache<T> memoryCache;
  final DiskCache<T>? diskCache;

  MultiLevelCache({
    CacheStrategy? strategy,
    StorageBackend? diskStorage,
  })  : memoryCache = MemoryCache<T>(strategy: strategy),
        diskCache = diskStorage != null
            ? DiskCache<T>(storage: diskStorage, strategy: strategy)
            : null;

  /// Get cached data (checks memory first, then disk)
  Future<T?> get(String key) async {
    // Check memory cache first
    final memCached = memoryCache.get(key);
    if (memCached != null) {
      return memCached.data;
    }

    // Check disk cache
    if (diskCache != null) {
      final diskCached = await diskCache!.get(key);
      if (diskCached != null) {
        // Promote to memory cache
        memoryCache.set(key, diskCached.data);
        return diskCached.data;
      }
    }

    return null;
  }

  /// Set cached data (writes to both memory and disk)
  Future<void> set(String key, T data, {Duration? ttl}) async {
    memoryCache.set(key, data, ttl: ttl);

    if (diskCache != null) {
      await diskCache!.set(key, data, ttl: ttl);
    }
  }

  /// Check if key exists
  Future<bool> has(String key) async {
    if (memoryCache.has(key)) return true;
    if (diskCache != null) {
      return await diskCache!.has(key);
    }
    return false;
  }

  /// Remove cached data
  Future<void> remove(String key) async {
    memoryCache.remove(key);
    if (diskCache != null) {
      await diskCache!.remove(key);
    }
  }

  /// Clear all caches
  Future<void> clear() async {
    memoryCache.clear();
    if (diskCache != null) {
      await diskCache!.clear();
    }
  }

  /// Clean expired entries
  void cleanExpired() {
    memoryCache.cleanExpired();
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'memory': memoryCache.getStats(),
      'disk': diskCache != null ? {'enabled': true} : {'enabled': false},
    };
  }
}

/// Cache manager for global cache operations
class CacheManager {
  static final Map<String, MultiLevelCache<dynamic>> _caches = {};

  /// Get or create cache
  static MultiLevelCache<T> getCache<T>(
    String name, {
    CacheStrategy? strategy,
    StorageBackend? diskStorage,
  }) {
    final existing = _caches[name];
    if (existing != null) {
      // Check if the existing cache is the same type
      try {
        return existing as MultiLevelCache<T>;
      } catch (e) {
        // Type mismatch - remove old cache and create new one
        _caches.remove(name);
      }
    }
    final cache = MultiLevelCache<T>(
      strategy: strategy,
      diskStorage: diskStorage,
    );
    _caches[name] = cache;
    return cache;
  }

  /// Clear all caches
  static Future<void> clearAll() async {
    final caches = _caches.values.toList();
    for (final cache in caches) {
      await cache.clear();
    }
    _caches.clear();
  }

  /// Clean expired entries in all caches
  static void cleanExpiredAll() {
    for (final cache in _caches.values) {
      cache.cleanExpired();
    }
  }

  /// Get all cache names
  static List<String> getCacheNames() {
    return _caches.keys.toList();
  }

  /// Remove cache
  static Future<void> removeCache(String name) async {
    final cache = _caches[name];
    if (cache != null) {
      await cache.clear();
      _caches.remove(name);
    }
  }
}

