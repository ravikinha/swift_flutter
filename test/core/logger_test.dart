import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/logger.dart';

void main() {
  group('Logger', () {
    setUp(() {
      Logger.clear();
      Logger.setEnabled(true);
      Logger.setLevel(LogLevel.debug);
    });

    test('should log debug messages', () {
      Logger.debug('Test debug');
      expect(Logger.history.length, 1);
      expect(Logger.history.first.level, LogLevel.debug);
    });

    test('should log info messages', () {
      Logger.info('Test info');
      expect(Logger.history.length, 1);
      expect(Logger.history.first.level, LogLevel.info);
    });

    test('should log warning messages', () {
      Logger.warning('Test warning');
      expect(Logger.history.length, 1);
      expect(Logger.history.first.level, LogLevel.warning);
    });

    test('should log error messages', () {
      Logger.error('Test error');
      expect(Logger.history.length, 1);
      expect(Logger.history.first.level, LogLevel.error);
    });

    test('should respect log level', () {
      Logger.setLevel(LogLevel.warning);
      Logger.debug('Debug message');
      Logger.info('Info message');
      Logger.warning('Warning message');
      
      expect(Logger.history.length, 1);
      expect(Logger.history.first.message, 'Warning message');
    });

    test('should respect enabled flag', () {
      Logger.setEnabled(false);
      Logger.info('Should not log');
      expect(Logger.history.length, 0);
    });

    test('should limit history size', () {
      Logger.setMaxHistory(5);
      for (int i = 0; i < 10; i++) {
        Logger.info('Message $i');
      }
      expect(Logger.history.length, 5);
    });

    test('should clear history', () {
      Logger.info('Message 1');
      Logger.info('Message 2');
      Logger.clear();
      expect(Logger.history.length, 0);
    });
  });
}

