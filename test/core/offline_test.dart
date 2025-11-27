import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/offline.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('OfflineQueueManager', () {
    late OfflineQueueManager manager;

    setUp(() {
      manager = OfflineQueueManager(storage: MemoryStorage());
      manager.isOnline.value = false; // Start offline
    });

    tearDown(() {
      manager.dispose();
    });

    test('should enqueue action when offline', () async {
      var executed = false;
      final action = BaseOfflineAction(
        type: 'test_action',
        payload: {'data': 'test'},
        executeFunction: () async {
          executed = true;
        },
      );

      await manager.enqueue(action);
      expect(manager.queueSize, 1);
      expect(executed, isFalse); // Should not execute while offline
    });

    test('should execute action immediately when online', () async {
      manager.isOnline.value = true;
      var executed = false;

      final action = BaseOfflineAction(
        type: 'test_action',
        payload: {'data': 'test'},
        executeFunction: () async {
          executed = true;
        },
      );

      await manager.enqueue(action);
      expect(executed, isTrue);
      expect(manager.queueSize, 0);
    });

    test('should sync queue when coming online', () async {
      var executedCount = 0;

      for (var i = 0; i < 3; i++) {
        final action = BaseOfflineAction(
          type: 'test_action_$i',
          payload: {'index': i},
          executeFunction: () async {
            executedCount++;
          },
        );
        await manager.enqueue(action);
      }

      expect(manager.queueSize, 3);

      manager.isOnline.value = true;
      
      // Wait for sync to complete
      while (manager.isSyncing.value || manager.queueSize > 0) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      expect(executedCount, 3);
      expect(manager.queueSize, 0);
    });

    test('should handle action failure with retry', () async {
      var attempts = 0;

      final action = BaseOfflineAction(
        type: 'failing_action',
        payload: {},
        executeFunction: () async {
          attempts++;
          throw Exception('Test error');
        },
      );

      await manager.enqueue(action);
      manager.isOnline.value = true;
      
      // Wait for sync to complete (will retry 3 times then fail)
      while (manager.isSyncing.value) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      expect(attempts, greaterThan(0));
      expect(manager.failedCount, greaterThan(0));
    });

    test('should track action status', () async {
      final action = BaseOfflineAction(
        type: 'test_action',
        payload: {},
        executeFunction: () async {},
      );

      await manager.enqueue(action);
      expect(
        manager.getActionStatus(action.id),
        OfflineActionStatus.pending,
      );
    });

    test('should get failed actions', () async {
      final action = BaseOfflineAction(
        type: 'failing_action',
        payload: {},
        executeFunction: () async {
          throw Exception('Test error');
        },
      );

      await manager.enqueue(action);
      manager.isOnline.value = true;
      
      // Wait for sync to complete
      while (manager.isSyncing.value) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      final failed = manager.getFailedActions();
      expect(failed.isNotEmpty, isTrue);
    });

    test('should retry failed action', () async {
      var attempts = 0;

      // This action will fail all 3 times, then we manually retry it and it succeeds
      final action = BaseOfflineAction(
        type: 'retry_action',
        payload: {},
        executeFunction: () async {
          attempts++;
          if (attempts < 4) {  // Fail first 3 times (auto-retries), succeed on 4th (manual retry)
            throw Exception('Fail first time');
          }
        },
      );

      await manager.enqueue(action);
      manager.isOnline.value = true;
      
      // Wait for first sync to complete (will fail after 3 retries)
      while (manager.isSyncing.value) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Should have failed after 3 attempts
      expect(manager.failedCount, greaterThan(0));
      expect(attempts, 3);

      // Retry the failed action
      await manager.retryFailedAction(action.id);
      
      // Wait for retry sync to complete
      while (manager.isSyncing.value || manager.queueSize > 0) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      // Should have succeeded on 4th attempt
      expect(attempts, 4);
      expect(manager.failedCount, 0);  // No longer in failed list
    });

    test('should clear queue', () async {
      final action = BaseOfflineAction(
        type: 'test_action',
        payload: {},
        executeFunction: () async {},
      );

      await manager.enqueue(action);
      expect(manager.queueSize, 1);

      await manager.clearQueue();
      expect(manager.queueSize, 0);
    });

    test('should clear failed actions', () async {
      final action = BaseOfflineAction(
        type: 'failing_action',
        payload: {},
        executeFunction: () async {
          throw Exception('Test error');
        },
      );

      await manager.enqueue(action);
      manager.isOnline.value = true;
      
      // Wait for sync to complete
      while (manager.isSyncing.value) {
        await Future.delayed(const Duration(milliseconds: 50));
      }

      expect(manager.failedCount, greaterThan(0));

      manager.clearFailedActions();
      expect(manager.failedCount, 0);
    });

    test('should check if queue is empty', () async {
      expect(manager.isEmpty, isTrue);

      final action = BaseOfflineAction(
        type: 'test_action',
        payload: {},
        executeFunction: () async {},
      );

      await manager.enqueue(action);
      expect(manager.isEmpty, isFalse);
    });
  });

  group('BaseOfflineAction', () {
    test('should create action with generated ID', () {
      final action = BaseOfflineAction(
        type: 'test',
        payload: {},
        executeFunction: () async {},
      );

      expect(action.id, isNotEmpty);
      expect(action.type, 'test');
    });

    test('should serialize to JSON', () {
      final action = BaseOfflineAction(
        type: 'test',
        payload: {'key': 'value'},
        executeFunction: () async {},
      );

      final json = action.toJson();
      expect(json['id'], action.id);
      expect(json['type'], 'test');
      expect(json['payload'], {'key': 'value'});
    });

    test('should execute function', () async {
      var executed = false;
      final action = BaseOfflineAction(
        type: 'test',
        payload: {},
        executeFunction: () async {
          executed = true;
        },
      );

      await action.execute();
      expect(executed, isTrue);
    });

    test('should track retry count', () {
      final action = BaseOfflineAction(
        type: 'test',
        payload: {},
        executeFunction: () async {},
      );

      expect(action.retryCount, 0);
      action.retryCount++;
      expect(action.retryCount, 1);
    });
  });

  group('OfflineRx', () {
    late OfflineQueueManager manager;

    setUp(() {
      manager = OfflineQueueManager();
      manager.isOnline.value = false;
    });

    tearDown(() {
      manager.dispose();
    });

    test('should queue sync when offline', () async {
      var synced = false;
      final state = OfflineRx<int>(
        0,
        queueManager: manager,
        syncFunction: (value) async {
          synced = true;
        },
      );

      state.value = 10;
      expect(state.value, 10);
      expect(synced, isFalse);
      expect(manager.queueSize, 1);
    });

    test('should sync immediately when online', () async {
      manager.isOnline.value = true;
      var synced = false;

      final state = OfflineRx<int>(
        0,
        queueManager: manager,
        syncFunction: (value) async {
          synced = true;
        },
      );

      state.value = 10;
      await Future.delayed(const Duration(milliseconds: 100));
      expect(synced, isTrue);
    });

    test('should track pending sync', () async {
      var synced = false;
      final state = OfflineRx<int>(
        0,
        queueManager: manager,
        syncFunction: (value) async {
          synced = true;
        },
      );

      state.value = 10;
      expect(state.hasPendingSync, isTrue);
      expect(state.pendingValue, 10);
    });
  });

  group('ConflictException', () {
    test('should create conflict exception', () {
      final exception = ConflictException(
        'Data conflict',
        serverData: {'version': 2},
        localData: {'version': 1},
      );

      expect(exception.message, 'Data conflict');
      expect(exception.serverData, {'version': 2});
      expect(exception.localData, {'version': 1});
    });

    test('should have string representation', () {
      final exception = ConflictException('Test conflict');
      expect(exception.toString(), contains('ConflictException'));
    });
  });
}

