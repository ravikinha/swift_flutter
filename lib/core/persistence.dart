import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'rx.dart';

/// Interface for storage backends
abstract class StorageBackend {
  Future<void> save(String key, String value);
  Future<String?> load(String key);
  Future<void> delete(String key);
  Future<void> clear();
}

/// SharedPreferences-like storage (requires shared_preferences package in real implementation)
class MemoryStorage implements StorageBackend {
  final Map<String, String> _storage = {};

  @override
  Future<void> save(String key, String value) async {
    _storage[key] = value;
  }

  @override
  Future<String?> load(String key) async {
    return _storage[key];
  }

  @override
  Future<void> delete(String key) async {
    _storage.remove(key);
  }

  @override
  Future<void> clear() async {
    _storage.clear();
  }
}

/// Reactive value with persistence
class RxPersisted<T> extends Rx<T> {
  final String _key;
  final StorageBackend _storage;
  final T Function(Map<String, dynamic>)? fromJson;
  final Map<String, dynamic> Function(T)? toJson;
  bool _isLoading = false;

  RxPersisted(
    super.initialValue,
    this._key,
    this._storage, {
    this.fromJson,
    this.toJson,
  }) {
    _load();
  }

  /// Load persisted value
  Future<void> _load() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final json = await _storage.load(_key);
      if (json != null) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        if (fromJson != null) {
          value = fromJson!(decoded);
        } else {
          value = decoded['value'] as T;
        }
      }
    } catch (e) {
      debugPrint('Error loading persisted value for $_key: $e');
    } finally {
      _isLoading = false;
    }
  }

  /// Save current value
  Future<void> _save() async {
    try {
      Map<String, dynamic> data;
      if (toJson != null) {
        data = toJson!(value);
      } else {
        data = {'value': value};
      }
      await _storage.save(_key, jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving persisted value for $_key: $e');
    }
  }

  @override
  set value(T newValue) {
    if (value == newValue) return;
    super.value = newValue;
    _save();
  }

  @override
  void update(T newValue) {
    if (value == newValue) return;
    super.update(newValue);
    _save();
  }

  /// Clear persisted value
  Future<void> clear() async {
    await _storage.delete(_key);
    _isLoading = false;
  }
}

