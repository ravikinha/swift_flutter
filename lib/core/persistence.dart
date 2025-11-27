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

/// Migration function type
typedef MigrationFunction<T> = T Function(Map<String, dynamic> oldData, int fromVersion, int toVersion);

/// Migration configuration
class MigrationConfig<T> {
  final int fromVersion;
  final int toVersion;
  final MigrationFunction<T> migrate;

  const MigrationConfig({
    required this.fromVersion,
    required this.toVersion,
    required this.migrate,
  });
}

/// Reactive value with persistence
class SwiftPersisted<T> extends Rx<T> {
  final String _key;
  final StorageBackend _storage;
  final T Function(Map<String, dynamic>)? fromJson;
  final Map<String, dynamic> Function(T)? toJson;
  final List<MigrationConfig<T>>? _migrations;
  final int? _currentVersion;
  bool _isLoading = false;

  SwiftPersisted(
    super.initialValue,
    this._key,
    this._storage, {
    this.fromJson,
    this.toJson,
    List<MigrationConfig<T>>? migrations,
    int? currentVersion,
  })  : _migrations = migrations,
        _currentVersion = currentVersion {
    _load();
  }

  /// Load persisted value with migration support
  Future<void> _load() async {
    if (_isLoading) return;
    _isLoading = true;

    try {
      final json = await _storage.load(_key);
      if (json != null) {
        final decoded = jsonDecode(json) as Map<String, dynamic>;
        
        // Check for version and apply migrations if needed
        final storedVersion = decoded['_version'] as int? ?? 0;
        final targetVersion = _currentVersion ?? 0;
        
        Map<String, dynamic> migratedData = decoded;
        
        if (storedVersion < targetVersion && _migrations != null) {
          // Apply migrations
          for (final migration in _migrations!) {
            if (storedVersion <= migration.fromVersion && 
                migration.toVersion <= targetVersion) {
              try {
                migratedData = migration.migrate(
                  migratedData,
                  migration.fromVersion,
                  migration.toVersion,
                ) as Map<String, dynamic>? ?? migratedData;
              } catch (e) {
                debugPrint('Error applying migration from ${migration.fromVersion} to ${migration.toVersion}: $e');
              }
            }
          }
          // Update version after migration
          migratedData['_version'] = targetVersion;
          // Save migrated data
          await _storage.save(_key, jsonEncode(migratedData));
        }
        
        // Load the (possibly migrated) data
        if (fromJson != null) {
          value = fromJson!(migratedData);
        } else {
          value = migratedData['value'] as T;
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
      
      // Add version if specified
      if (_currentVersion != null) {
        data['_version'] = _currentVersion;
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

  /// Migrate data manually (useful for testing or manual migration)
  Future<void> migrate() async {
    await _load();
  }
}

/// Migration helper utilities
class MigrationHelper {
  /// Create a simple migration that transforms data
  static MigrationConfig<T> simpleMigration<T>({
    required int fromVersion,
    required int toVersion,
    required T Function(Map<String, dynamic>) transform,
  }) {
    return MigrationConfig<T>(
      fromVersion: fromVersion,
      toVersion: toVersion,
      migrate: (oldData, from, to) => transform(oldData),
    );
  }

  /// Create a migration that renames a key
  static MigrationConfig<T> renameKeyMigration<T>({
    required int fromVersion,
    required int toVersion,
    required String oldKey,
    required String newKey,
    T Function(Map<String, dynamic>)? transform,
  }) {
    return MigrationConfig<T>(
      fromVersion: fromVersion,
      toVersion: toVersion,
      migrate: (oldData, from, to) {
        final newData = Map<String, dynamic>.from(oldData);
        if (newData.containsKey(oldKey)) {
          newData[newKey] = newData.remove(oldKey);
        }
        if (transform != null) {
          return transform(newData);
        }
        return newData as T;
      },
    );
  }
}

