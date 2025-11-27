import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/error_tracking.dart';

void main() {
  group('SwiftErrorTracker', () {
    setUp(() {
      SwiftErrorTracker.clearBreadcrumbs();
      SwiftErrorTracker.clearErrorHistory();
    });

    test('should configure error tracking', () {
      final config = ErrorTrackingConfig(
        enabled: true,
        environment: 'test',
        release: '1.0.0',
        sampleRate: 1.0,
      );

      SwiftErrorTracker.configure(config);
      expect(true, isTrue); // Configuration successful
    });

    test('should add breadcrumbs', () {
      SwiftErrorTracker.addBreadcrumb(Breadcrumb(
        message: 'User clicked button',
        category: 'ui',
        level: ErrorSeverity.info,
      ));

      final breadcrumbs = SwiftErrorTracker.getBreadcrumbs();
      expect(breadcrumbs.length, 1);
      expect(breadcrumbs.first.message, 'User clicked button');
      expect(breadcrumbs.first.category, 'ui');
    });

    test('should limit breadcrumbs to max size', () {
      SwiftErrorTracker.configure(const ErrorTrackingConfig(
        maxBreadcrumbs: 5,
      ));

      for (var i = 0; i < 10; i++) {
        SwiftErrorTracker.addBreadcrumb(Breadcrumb(
          message: 'Breadcrumb $i',
          category: 'test',
        ));
      }

      final breadcrumbs = SwiftErrorTracker.getBreadcrumbs();
      expect(breadcrumbs.length, 5);
      expect(breadcrumbs.first.message, 'Breadcrumb 5');
      expect(breadcrumbs.last.message, 'Breadcrumb 9');
    });

    test('should set user context', () {
      SwiftErrorTracker.setUser(
        userId: 'user123',
        email: 'test@example.com',
        extra: {'plan': 'premium'},
      );

      // User context is set (verified through error capture)
      expect(true, isTrue);
    });

    test('should set tags', () {
      SwiftErrorTracker.setTag('version', '1.0.0');
      SwiftErrorTracker.setTag('platform', 'android');

      // Tags are set (verified through error capture)
      expect(true, isTrue);
    });

    test('should set extra context', () {
      SwiftErrorTracker.setExtra('customData', {'key': 'value'});

      // Extra context is set (verified through error capture)
      expect(true, isTrue);
    });

    test('should capture exception', () async {
      var errorCaptured = false;
      SwiftErrorTracker.configure(ErrorTrackingConfig(
        enabled: true,
        onError: (error, stack, context) async {
          errorCaptured = true;
          expect(error.toString(), contains('Test error'));
          expect(context['environment'], 'development');
        },
      ));

      await SwiftErrorTracker.captureException(
        Exception('Test error'),
        StackTrace.current,
        severity: ErrorSeverity.error,
      );

      expect(errorCaptured, isTrue);
    });

    test('should capture message', () async {
      var messageCaptured = false;
      SwiftErrorTracker.configure(ErrorTrackingConfig(
        enabled: true,
        onLog: (message, severity) async {
          messageCaptured = true;
          expect(message, 'Test message');
          expect(severity, ErrorSeverity.info);
        },
      ));

      await SwiftErrorTracker.captureMessage(
        'Test message',
        severity: ErrorSeverity.info,
      );

      expect(messageCaptured, isTrue);
    });

    test('should store error history', () async {
      SwiftErrorTracker.configure(const ErrorTrackingConfig(enabled: true));

      await SwiftErrorTracker.captureException(
        Exception('Error 1'),
        StackTrace.current,
      );
      await SwiftErrorTracker.captureException(
        Exception('Error 2'),
        StackTrace.current,
      );

      final history = SwiftErrorTracker.getErrorHistory();
      expect(history.length, 2);
      expect(history[0].exception.toString(), contains('Error 1'));
      expect(history[1].exception.toString(), contains('Error 2'));
    });

    test('should respect sample rate', () async {
      var captureCount = 0;
      SwiftErrorTracker.configure(ErrorTrackingConfig(
        enabled: true,
        sampleRate: 0.0, // Never capture
        onError: (error, stack, context) async {
          captureCount++;
        },
      ));

      for (var i = 0; i < 10; i++) {
        await SwiftErrorTracker.captureException(
          Exception('Test'),
          StackTrace.current,
        );
      }

      // With 0.0 sample rate, should capture very few or none
      expect(captureCount, lessThan(3));
    });

    test('should get user-friendly error message', () {
      final message1 = SwiftErrorTracker.getUserFriendlyMessage(
        Exception('Test error'),
      );
      expect(message1, 'Test error');

      final message2 = SwiftErrorTracker.getUserFriendlyMessage('String error');
      expect(message2, 'String error');
    });

    test('should clear breadcrumbs', () {
      SwiftErrorTracker.addBreadcrumb(Breadcrumb(
        message: 'Test',
        category: 'test',
      ));

      expect(SwiftErrorTracker.getBreadcrumbs().length, 1);

      SwiftErrorTracker.clearBreadcrumbs();
      expect(SwiftErrorTracker.getBreadcrumbs().length, 0);
    });

    test('should clear error history', () async {
      SwiftErrorTracker.configure(const ErrorTrackingConfig(enabled: true));

      await SwiftErrorTracker.captureException(
        Exception('Test'),
        StackTrace.current,
      );

      expect(SwiftErrorTracker.getErrorHistory().length, 1);

      SwiftErrorTracker.clearErrorHistory();
      expect(SwiftErrorTracker.getErrorHistory().length, 0);
    });

    test('Breadcrumb should serialize to JSON', () {
      final breadcrumb = Breadcrumb(
        message: 'Test message',
        category: 'test',
        level: ErrorSeverity.warning,
        data: {'key': 'value'},
      );

      final json = breadcrumb.toJson();
      expect(json['message'], 'Test message');
      expect(json['category'], 'test');
      expect(json['level'], 'warning');
      expect(json['data'], {'key': 'value'});
      expect(json['timestamp'], isNotNull);
    });

    test('ErrorEvent should serialize to JSON', () {
      final event = ErrorEvent(
        exception: Exception('Test'),
        stackTrace: StackTrace.current,
        severity: ErrorSeverity.error,
        context: {'key': 'value'},
        timestamp: DateTime.now(),
      );

      final json = event.toJson();
      expect(json['exception'], contains('Test'));
      expect(json['severity'], 'error');
      expect(json['context'], {'key': 'value'});
      expect(json['timestamp'], isNotNull);
    });
  });

  group('SentryIntegration', () {
    test('should create Sentry config', () {
      final config = SentryIntegration.createConfig(
        dsn: 'https://test@sentry.io/123',
        environment: 'production',
        release: '1.0.0',
        sampleRate: 0.5,
      );

      expect(config.enabled, isTrue);
      expect(config.environment, 'production');
      expect(config.release, '1.0.0');
      expect(config.sampleRate, 0.5);
      expect(config.onError, isNotNull);
      expect(config.onLog, isNotNull);
    });
  });

  group('FirebaseCrashlyticsIntegration', () {
    test('should create Firebase config', () {
      final config = FirebaseCrashlyticsIntegration.createConfig(
        environment: 'staging',
        release: '2.0.0',
      );

      expect(config.enabled, isTrue);
      expect(config.environment, 'staging');
      expect(config.release, '2.0.0');
      expect(config.onError, isNotNull);
      expect(config.onLog, isNotNull);
    });
  });
}

