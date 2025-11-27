import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'persistence.dart' show StorageBackend;
import 'rx.dart';

/// Conflict resolution strategy
enum ConflictStrategy {
  serverWins, // Server data overwrites local
  clientWins, // Local data overwrites server
  merge, // Attempt to merge changes
  manual, // Require manual resolution
}

/// Offline action status
enum OfflineActionStatus {
  pending,
  executing,
  success,
  failed,
  conflict,
}

/// Offline action interface
abstract class OfflineAction {
  String get id;
  String get type;
  Map<String, dynamic> get payload;
  ConflictStrategy get conflictStrategy;
  DateTime get createdAt;
  int get retryCount;
  set retryCount(int value);

  /// Execute the action
  Future<dynamic> execute();

  /// Serialize to JSON
  Map<String, dynamic> toJson();

  /// Deserialize from JSON
  static OfflineAction fromJson(Map<String, dynamic> json) {
    // Override in subclasses
    throw UnimplementedError('fromJson must be implemented in subclass');
  }
}

/// Base offline action implementation
class BaseOfflineAction implements OfflineAction {
  @override
  final String id;

  @override
  final String type;

  @override
  final Map<String, dynamic> payload;

  @override
  final ConflictStrategy conflictStrategy;

  @override
  final DateTime createdAt;

  @override
  int retryCount;

  final Future<dynamic> Function() executeFunction;

  BaseOfflineAction({
    String? id,
    required this.type,
    required this.payload,
    this.conflictStrategy = ConflictStrategy.serverWins,
    DateTime? createdAt,
    this.retryCount = 0,
    required this.executeFunction,
  })  : id = id ?? _generateId(),
        createdAt = createdAt ?? DateTime.now();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  @override
  Future<dynamic> execute() => executeFunction();

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'payload': payload,
        'conflictStrategy': conflictStrategy.name,
        'createdAt': createdAt.toIso8601String(),
        'retryCount': retryCount,
      };
}

/// Offline queue manager
class OfflineQueueManager {
  final Queue<OfflineAction> _queue = Queue();
  final Rx<bool> isOnline = swift(true);
  final Rx<bool> isSyncing = swift(false);
  final Map<String, OfflineActionStatus> _actionStatus = {};
  final List<OfflineAction> _failedActions = [];
  final StorageBackend? _storage;
  final String _storageKey = 'offline_queue';

  OfflineQueueManager({StorageBackend? storage}) : _storage = storage {
    // Load persisted queue
    _loadQueue();

    // Listen to online status changes
    isOnline.addListener(_onConnectivityChanged);
  }

  /// Get queue size
  int get queueSize => _queue.length;

  /// Get failed actions count
  int get failedCount => _failedActions.length;

  /// Check if queue is empty
  bool get isEmpty => _queue.isEmpty;

  /// Enqueue action
  Future<void> enqueue(OfflineAction action) async {
    if (isOnline.value && !isSyncing.value) {
      // Execute immediately if online
      await _executeAction(action);
    } else {
      // Add to queue if offline
      _queue.add(action);
      _actionStatus[action.id] = OfflineActionStatus.pending;
      await _persistQueue();

      if (kDebugMode) {
        debugPrint('Action ${action.type} queued for offline execution');
      }
    }
  }

  /// Sync queue when online
  Future<void> syncWhenOnline() async {
    if (!isOnline.value || isSyncing.value) return;

    isSyncing.value = true;

    try {
      while (_queue.isNotEmpty) {
        final action = _queue.first;
        _actionStatus[action.id] = OfflineActionStatus.executing;

        try {
          await _executeAction(action);
          _queue.removeFirst();
          _actionStatus[action.id] = OfflineActionStatus.success;
        } catch (e) {
          if (e is ConflictException) {
            await _handleConflict(action, e);
          } else {
            // Retry logic
            action.retryCount++;
            if (action.retryCount >= 3) {
              // Move to failed actions
              _queue.removeFirst();
              _failedActions.add(action);
              _actionStatus[action.id] = OfflineActionStatus.failed;

              if (kDebugMode) {
                debugPrint('Action ${action.type} failed after 3 retries: $e');
              }
            } else {
              // Retry immediately with exponential backoff
              if (kDebugMode) {
                debugPrint('Action ${action.type} failed, retrying (attempt ${action.retryCount + 1}/3): $e');
              }
              await Future.delayed(Duration(milliseconds: 100 * action.retryCount));
              // Continue loop to retry this action
            }
          }
        }

        await _persistQueue();
      }
    } finally {
      isSyncing.value = false;
    }
  }

  /// Execute action
  Future<void> _executeAction(OfflineAction action) async {
    try {
      await action.execute();
      if (kDebugMode) {
        debugPrint('Action ${action.type} executed successfully');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Action ${action.type} execution failed: $e');
      }
      rethrow;
    }
  }

  /// Handle conflict
  Future<void> _handleConflict(OfflineAction action, ConflictException error) async {
    _actionStatus[action.id] = OfflineActionStatus.conflict;

    switch (action.conflictStrategy) {
      case ConflictStrategy.serverWins:
        // Discard local changes
        _queue.removeFirst();
        if (kDebugMode) {
          debugPrint('Conflict resolved: Server wins for ${action.type}');
        }
        break;

      case ConflictStrategy.clientWins:
        // Retry with force flag
        try {
          await action.execute();
          _queue.removeFirst();
          _actionStatus[action.id] = OfflineActionStatus.success;
        } catch (e) {
          _queue.removeFirst();
          _failedActions.add(action);
          _actionStatus[action.id] = OfflineActionStatus.failed;
        }
        break;

      case ConflictStrategy.merge:
        // Attempt smart merge
        try {
          final merged = await _mergeChanges(action, error);
          if (merged) {
            _queue.removeFirst();
            _actionStatus[action.id] = OfflineActionStatus.success;
          } else {
            throw Exception('Merge failed');
          }
        } catch (e) {
          _queue.removeFirst();
          _failedActions.add(action);
          _actionStatus[action.id] = OfflineActionStatus.failed;
        }
        break;

      case ConflictStrategy.manual:
        // Move to failed for manual resolution
        _queue.removeFirst();
        _failedActions.add(action);
        if (kDebugMode) {
          debugPrint('Conflict requires manual resolution for ${action.type}');
        }
        break;
    }
  }

  /// Merge changes (placeholder - implement based on your data model)
  Future<bool> _mergeChanges(OfflineAction action, ConflictException error) async {
    // Implement merge logic based on your data model
    // This is a simplified placeholder
    if (kDebugMode) {
      debugPrint('Attempting to merge changes for ${action.type}');
    }
    return false;
  }

  /// Get action status
  OfflineActionStatus? getActionStatus(String actionId) {
    return _actionStatus[actionId];
  }

  /// Get failed actions
  List<OfflineAction> getFailedActions() {
    return List.unmodifiable(_failedActions);
  }

  /// Retry failed action
  Future<void> retryFailedAction(String actionId) async {
    final action = _failedActions.firstWhere(
      (a) => a.id == actionId,
      orElse: () => throw StateError('Action not found'),
    );

    _failedActions.remove(action);
    action.retryCount = 0;
    await enqueue(action);
  }

  /// Clear failed actions
  void clearFailedActions() {
    _failedActions.clear();
  }

  /// Clear queue
  Future<void> clearQueue() async {
    _queue.clear();
    _actionStatus.clear();
    await _persistQueue();
  }

  /// Persist queue to storage
  Future<void> _persistQueue() async {
    if (_storage == null) return;

    try {
      final data = {
        'queue': _queue.map((a) => a.toJson()).toList(),
        'failed': _failedActions.map((a) => a.toJson()).toList(),
      };
      await _storage!.save(_storageKey, jsonEncode(data));
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error persisting offline queue: $e');
      }
    }
  }

  /// Load queue from storage
  Future<void> _loadQueue() async {
    if (_storage == null) return;

    try {
      final data = await _storage!.load(_storageKey);
      if (data == null) return;

      jsonDecode(data);

      // Note: Actual deserialization depends on your action types
      // This is a simplified version
      if (kDebugMode) {
        debugPrint('Loaded offline queue from storage');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error loading offline queue: $e');
      }
    }
  }

  /// Handle connectivity changes
  void _onConnectivityChanged() {
    if (isOnline.value && _queue.isNotEmpty) {
      syncWhenOnline();
    }
  }

  /// Dispose
  void dispose() {
    isOnline.removeListener(_onConnectivityChanged);
    isOnline.dispose();
    isSyncing.dispose();
  }
}

/// Conflict exception
class ConflictException implements Exception {
  final String message;
  final dynamic serverData;
  final dynamic localData;

  ConflictException(this.message, {this.serverData, this.localData});

  @override
  String toString() => 'ConflictException: $message';
}

/// Offline-aware reactive state
class OfflineRx<T> extends Rx<T> {
  final OfflineQueueManager queueManager;
  final Future<void> Function(T value) syncFunction;
  T? _pendingValue;

  OfflineRx(
    super.value, {
    required this.queueManager,
    required this.syncFunction,
  });

  @override
  set value(T newValue) {
    super.value = newValue;

    if (queueManager.isOnline.value) {
      // Sync immediately if online
      _syncValue(newValue);
    } else {
      // Queue for later if offline
      _pendingValue = newValue;
      _queueSync(newValue);
    }
  }

  Future<void> _syncValue(T value) async {
    try {
      await syncFunction(value);
      _pendingValue = null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error syncing value: $e');
      }
      _pendingValue = value;
    }
  }

  void _queueSync(T value) {
    final action = BaseOfflineAction(
      type: 'sync_state',
      payload: {'value': value},
      executeFunction: () => syncFunction(value),
    );
    queueManager.enqueue(action);
  }

  /// Check if value is pending sync
  bool get hasPendingSync => _pendingValue != null;

  /// Get pending value
  T? get pendingValue => _pendingValue;
}

/// Global offline queue manager instance
final offlineQueue = OfflineQueueManager();

