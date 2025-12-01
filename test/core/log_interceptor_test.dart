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

    test('should capture log entry', () {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(
        message: 'Test message',
        type: LogType.info,
      );

      final logs = LogInterceptor.getLogs();
      expect(logs.length, 1);
      expect(logs.first.message, 'Test message');
      expect(logs.first.type, LogType.info);
    });

    test('should capture log with data', () {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(
        message: 'Error occurred',
        type: LogType.error,
        data: {'error': 'Something went wrong'},
      );

      final logs = LogInterceptor.getLogs();
      expect(logs.length, 1);
      expect(logs.first.data, {'error': 'Something went wrong'});
    });

    test('should filter logs by type', () {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(message: 'Debug message', type: LogType.debug);
      LogInterceptor.captureLog(message: 'Info message', type: LogType.info);
      LogInterceptor.captureLog(message: 'Warning message', type: LogType.warning);
      LogInterceptor.captureLog(message: 'Error message', type: LogType.error);

      final errorLogs = LogInterceptor.getLogsByType(LogType.error);
      expect(errorLogs.length, 1);
      expect(errorLogs.first.message, 'Error message');
    });

    test('should limit maximum logs', () {
      LogInterceptor.enable(maxLogs: 5);
      
      for (int i = 0; i < 10; i++) {
        LogInterceptor.captureLog(
          message: 'Log $i',
          type: LogType.info,
        );
      }

      final logs = LogInterceptor.getLogs();
      expect(logs.length, 5); // Should only keep last 5
    });

    test('should clear all logs', () {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(message: 'Test', type: LogType.info);
      expect(LogInterceptor.getLogs().length, 1);
      
      LogInterceptor.clear();
      expect(LogInterceptor.getLogs().length, 0);
    });

    test('should capture different log types', () {
      LogInterceptor.enable();
      
      LogInterceptor.captureLog(message: 'Print', type: LogType.print);
      LogInterceptor.captureLog(message: 'Debug', type: LogType.debug);
      LogInterceptor.captureLog(message: 'Info', type: LogType.info);
      LogInterceptor.captureLog(message: 'Warning', type: LogType.warning);
      LogInterceptor.captureLog(message: 'Error', type: LogType.error);

      final logs = LogInterceptor.getLogs();
      expect(logs.length, 5);
    });
  });

  group('LogEntry', () {
    test('should serialize to JSON', () {
      final entry = LogEntry(
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

