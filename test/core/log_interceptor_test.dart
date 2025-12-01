import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/log_interceptor.dart';

void main() {
  group('LogInterceptor', () {
    tearDown(() {
      LogInterceptor.disable();
      LogInterceptor.clear();
    });

    test('should be disabled by default', () {
      expect(LogInterceptor.isEnabled, false);
    });

    test('should enable log interception', () {
      LogInterceptor.enable();
      expect(LogInterceptor.isEnabled, true);
    });

    test('should disable log interception', () {
      LogInterceptor.enable();
      LogInterceptor.disable();
      expect(LogInterceptor.isEnabled, false);
    });

    test('should capture log entry', () async {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(
        message: 'Test message',
        type: LogType.info,
      );

      // Wait for microtask to complete
      await Future.microtask(() {});
      final logs = LogInterceptor.getLogs();
      expect(logs.length, 1);
      expect(logs.first.message, 'Test message');
      expect(logs.first.type, LogType.info);
    });

    test('should capture log with data', () async {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(
        message: 'Error occurred',
        type: LogType.error,
        data: {'error': 'Something went wrong'},
      );

      // Wait for microtask to complete
      await Future.microtask(() {});
      final logs = LogInterceptor.getLogs();
      expect(logs.length, 1);
      expect(logs.first.data, {'error': 'Something went wrong'});
    });

    test('should filter logs by type', () async {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(message: 'Debug message', type: LogType.debug);
      LogInterceptor.captureLog(message: 'Info message', type: LogType.info);
      LogInterceptor.captureLog(message: 'Warning message', type: LogType.warning);
      LogInterceptor.captureLog(message: 'Error message', type: LogType.error);

      // Wait for all microtasks to complete
      await Future.microtask(() {});
      final errorLogs = LogInterceptor.getLogsByType(LogType.error);
      expect(errorLogs.length, 1);
      expect(errorLogs.first.message, 'Error message');
    });

    test('should limit maximum logs', () async {
      LogInterceptor.enable(maxLogs: 5);
      
      // Capture logs one at a time, waiting for each to complete
      for (int i = 0; i < 10; i++) {
        LogInterceptor.captureLog(
          message: 'Log $i',
          type: LogType.info,
        );
        // Wait for this microtask to complete before next call
        await Future.microtask(() {});
      }
      
      final logs = LogInterceptor.getLogs();
      expect(logs.length, 5); // Should only keep last 5
    });

    test('should clear all logs', () async {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(message: 'Test', type: LogType.info);
      // Wait for capture microtask to complete
      await Future.microtask(() {});
      expect(LogInterceptor.getLogs().length, 1);
      
      LogInterceptor.clear();
      // Wait for clear microtask to complete
      await Future.microtask(() {});
      expect(LogInterceptor.getLogs().length, 0);
    });

    test('should capture different log types', () async {
      LogInterceptor.enable();
      
      // Capture logs one at a time, waiting for each to complete
      LogInterceptor.captureLog(message: 'Print', type: LogType.print);
      await Future.microtask(() {});
      LogInterceptor.captureLog(message: 'Debug', type: LogType.debug);
      await Future.microtask(() {});
      LogInterceptor.captureLog(message: 'Info', type: LogType.info);
      await Future.microtask(() {});
      LogInterceptor.captureLog(message: 'Warning', type: LogType.warning);
      await Future.microtask(() {});
      LogInterceptor.captureLog(message: 'Error', type: LogType.error);
      await Future.microtask(() {});

      final logs = LogInterceptor.getLogs();
      expect(logs.length, 5);
    });
  });

  group('InterceptedLogEntry', () {
    test('should serialize to JSON', () {
      final entry = InterceptedLogEntry(
        id: '1',
        message: 'Test message',
        timestamp: DateTime(2024, 1, 1),
        type: LogType.info,
        data: {'key': 'value'},
      );

      final json = entry.toJson();
      expect(json['id'], '1');
      expect(json['message'], 'Test message');
      expect(json['type'], 'LogType.info');
      expect(json['data'], isNotNull);
      expect(json['data'].toString(), contains('key'));
    });
  });
}

