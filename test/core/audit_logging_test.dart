import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/audit_logging.dart';
import 'package:swift_flutter/core/persistence.dart';

void main() {
  group('AuditLogger', () {
    setUp(() {
      AuditLogger.clearEvents();
      AuditLogger.configure(const AuditLoggerConfig(enabled: true));
    });

    test('should log state change', () async {
      await AuditLogger.logStateChange(
        stateKey: 'counter',
        oldValue: 0,
        newValue: 1,
        userId: 'user123',
      );

      final events = AuditLogger.getEvents();
      expect(events.length, 1);
      expect(events.first.type, AuditEventType.stateChange);
      expect(events.first.stateKey, 'counter');
      expect(events.first.oldValue, 0);
      expect(events.first.newValue, 1);
    });

    test('should log action', () async {
      await AuditLogger.logAction(
        actionType: 'INCREMENT',
        userId: 'user123',
        payload: {'amount': 1},
      );

      final events = AuditLogger.getEvents();
      expect(events.length, 1);
      expect(events.first.type, AuditEventType.actionDispatched);
    });

    test('should log user login', () async {
      await AuditLogger.logLogin(
        userId: 'user123',
        userEmail: 'test@example.com',
      );

      final events = AuditLogger.getEvents();
      expect(events.first.type, AuditEventType.userLogin);
      expect(events.first.userId, 'user123');
      expect(events.first.userEmail, 'test@example.com');
    });

    test('should log user logout', () async {
      await AuditLogger.logLogout(userId: 'user123');

      final events = AuditLogger.getEvents();
      expect(events.first.type, AuditEventType.userLogout);
    });

    test('should log data access', () async {
      await AuditLogger.logDataAccess(
        resourceKey: 'user_profile',
        userId: 'user123',
      );

      final events = AuditLogger.getEvents();
      expect(events.first.type, AuditEventType.dataAccess);
    });

    test('should log security event', () async {
      await AuditLogger.logSecurityEvent(
        eventDescription: 'Failed login attempt',
        userId: 'user123',
      );

      final events = AuditLogger.getEvents();
      expect(events.first.type, AuditEventType.securityEvent);
    });

    test('should log custom event', () async {
      await AuditLogger.logCustom(
        eventKey: 'custom_action',
        data: {'custom': 'data'},
        userId: 'user123',
      );

      final events = AuditLogger.getEvents();
      expect(events.first.type, AuditEventType.custom);
    });

    test('should create tamper-proof hash chain', () async {
      AuditLogger.configure(const AuditLoggerConfig(
        enabled: true,
        enableTamperProof: true,
      ));

      await AuditLogger.logStateChange(
        stateKey: 'test1',
        oldValue: 0,
        newValue: 1,
      );
      await AuditLogger.logStateChange(
        stateKey: 'test2',
        oldValue: 1,
        newValue: 2,
      );

      final events = AuditLogger.getEvents();
      expect(events[0].previousHash, isNull);
      expect(events[0].hash, isNotNull);
      expect(events[1].previousHash, events[0].hash);
      expect(events[1].hash, isNotNull);
    });

    test('should verify integrity', () async {
      AuditLogger.configure(const AuditLoggerConfig(
        enabled: true,
        enableTamperProof: true,
      ));

      await AuditLogger.logStateChange(
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
      );

      expect(AuditLogger.verifyIntegrity(), isTrue);
    });

    test('should filter events by date', () async {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(days: 1));
      final tomorrow = now.add(const Duration(days: 1));

      await AuditLogger.logStateChange(
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
      );

      final events1 = AuditLogger.getEvents(startDate: yesterday);
      expect(events1.length, 1);

      final events2 = AuditLogger.getEvents(startDate: tomorrow);
      expect(events2.length, 0);
    });

    test('should filter events by user', () async {
      await AuditLogger.logStateChange(
        stateKey: 'test1',
        oldValue: 0,
        newValue: 1,
        userId: 'user1',
      );
      await AuditLogger.logStateChange(
        stateKey: 'test2',
        oldValue: 0,
        newValue: 1,
        userId: 'user2',
      );

      final events = AuditLogger.getEvents(userId: 'user1');
      expect(events.length, 1);
      expect(events.first.userId, 'user1');
    });

    test('should filter events by type', () async {
      await AuditLogger.logStateChange(
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
      );
      await AuditLogger.logLogin(userId: 'user123');

      final events = AuditLogger.getEvents(
        eventType: AuditEventType.userLogin,
      );
      expect(events.length, 1);
      expect(events.first.type, AuditEventType.userLogin);
    });

    test('should export logs as JSON', () async {
      await AuditLogger.logStateChange(
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
      );

      final exported = await AuditLogger.exportLogs();
      expect(exported, isNotEmpty);
      expect(exported, contains('test'));
    });

    test('should persist and load events', () async {
      final storage = MemoryStorage();
      AuditLogger.configure(AuditLoggerConfig(
        enabled: true,
        storage: storage,
      ));

      await AuditLogger.logStateChange(
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
      );

      // Events should be persisted
      await Future.delayed(const Duration(milliseconds: 100));

      // Clear and reload
      AuditLogger.clearEvents();
      await AuditLogger.loadEvents();

      final events = AuditLogger.getEvents();
      expect(events.length, 1);
    });

    test('should apply event filter', () async {
      AuditLogger.configure(AuditLoggerConfig(
        enabled: true,
        eventFilter: (event) => event.userId == 'allowed_user',
      ));

      await AuditLogger.logStateChange(
        stateKey: 'test1',
        oldValue: 0,
        newValue: 1,
        userId: 'allowed_user',
      );
      await AuditLogger.logStateChange(
        stateKey: 'test2',
        oldValue: 0,
        newValue: 1,
        userId: 'blocked_user',
      );

      final events = AuditLogger.getEvents();
      expect(events.length, 1);
      expect(events.first.userId, 'allowed_user');
    });

    test('should respect max events in memory', () async {
      AuditLogger.configure(const AuditLoggerConfig(
        enabled: true,
        maxEventsInMemory: 5,
      ));

      for (var i = 0; i < 10; i++) {
        await AuditLogger.logStateChange(
          stateKey: 'test$i',
          oldValue: i,
          newValue: i + 1,
        );
      }

      expect(AuditLogger.getEventCount(), 5);
    });

    test('should serialize and deserialize AuditEvent', () {
      final event = AuditEvent(
        type: AuditEventType.stateChange,
        stateKey: 'test',
        oldValue: 0,
        newValue: 1,
        userId: 'user123',
        metadata: {'key': 'value'},
      );

      final json = event.toJson();
      final deserialized = AuditEvent.fromJson(json);

      expect(deserialized.type, event.type);
      expect(deserialized.stateKey, event.stateKey);
      expect(deserialized.userId, event.userId);
    });
  });
}

