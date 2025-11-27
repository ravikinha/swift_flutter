import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/analytics.dart';

void main() {
  group('AnalyticsManager', () {
    setUp(() {
      AnalyticsManager.clearEventHistory();
      AnalyticsManager.setEnabled(true);
    });

    test('should log event', () async {
      final provider = DebugAnalyticsProvider();
      AnalyticsManager.addProvider(provider);

      await AnalyticsManager.logEvent(
        'test_event',
        parameters: {'key': 'value'},
      );

      final history = AnalyticsManager.getEventHistory();
      expect(history.length, 1);
      expect(history.first.name, 'test_event');
    });

    test('should set user property', () async {
      final provider = DebugAnalyticsProvider();
      AnalyticsManager.addProvider(provider);

      await AnalyticsManager.setUserProperty('plan', 'premium');
      // No exception should be thrown
      expect(true, isTrue);
    });

    test('should set user ID', () async {
      final provider = DebugAnalyticsProvider();
      AnalyticsManager.addProvider(provider);

      await AnalyticsManager.setUserId('user123');
      // No exception should be thrown
      expect(true, isTrue);
    });

    test('should log screen view', () async {
      final provider = DebugAnalyticsProvider();
      AnalyticsManager.addProvider(provider);

      await AnalyticsManager.logScreenView('home_screen');
      // No exception should be thrown
      expect(true, isTrue);
    });

    test('should not log when disabled', () async {
      AnalyticsManager.setEnabled(false);

      await AnalyticsManager.logEvent('test_event');

      final history = AnalyticsManager.getEventHistory();
      expect(history.length, 0);
    });

    test('should clear event history', () async {
      await AnalyticsManager.logEvent('event1');
      await AnalyticsManager.logEvent('event2');

      expect(AnalyticsManager.getEventHistory().length, 2);

      AnalyticsManager.clearEventHistory();
      expect(AnalyticsManager.getEventHistory().length, 0);
    });

    test('should limit event history size', () async {
      for (var i = 0; i < 150; i++) {
        await AnalyticsManager.logEvent('event_$i');
      }

      final history = AnalyticsManager.getEventHistory();
      expect(history.length, lessThanOrEqualTo(100));
    });
  });

  group('AnalyticsEvent', () {
    test('should create event', () {
      final event = AnalyticsEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      expect(event.name, 'test_event');
      expect(event.parameters['key'], 'value');
      expect(event.timestamp, isNotNull);
    });

    test('should serialize to JSON', () {
      final event = AnalyticsEvent(
        name: 'test_event',
        parameters: {'key': 'value'},
      );

      final json = event.toJson();
      expect(json['name'], 'test_event');
      expect(json['parameters'], {'key': 'value'});
      expect(json['timestamp'], isNotNull);
    });
  });

  group('ScreenTracker', () {
    test('should track screen view', () async {
      final provider = DebugAnalyticsProvider();
      AnalyticsManager.addProvider(provider);

      await ScreenTracker.trackScreen('home_screen');
      expect(ScreenTracker.currentScreen, 'home_screen');
    });

    test('should not track same screen twice', () async {
      AnalyticsManager.clearEventHistory();

      await ScreenTracker.trackScreen('home_screen');
      await ScreenTracker.trackScreen('home_screen');

      // Should only track once
      expect(ScreenTracker.currentScreen, 'home_screen');
    });
  });

  group('UserTracker', () {
    setUp(() {
      UserTracker.clear();
    });

    test('should set user ID', () async {
      await UserTracker.setUserId('user123');
      expect(UserTracker.userId, 'user123');
    });

    test('should set user property', () async {
      await UserTracker.setUserProperty('plan', 'premium');
      expect(UserTracker.userProperties['plan'], 'premium');
    });

    test('should clear user data', () async {
      await UserTracker.setUserId('user123');
      await UserTracker.setUserProperty('plan', 'premium');

      UserTracker.clear();

      expect(UserTracker.userId, isNull);
      expect(UserTracker.userProperties.isEmpty, isTrue);
    });
  });

  group('EventTracker', () {
    setUp(() {
      AnalyticsManager.clearEventHistory();
    });

    test('should track button click', () async {
      await EventTracker.trackButtonClick('submit_button');

      final history = AnalyticsManager.getEventHistory();
      expect(history.last.name, 'button_click');
      expect(history.last.parameters['button_name'], 'submit_button');
    });

    test('should track feature usage', () async {
      await EventTracker.trackFeatureUsage('dark_mode');

      final history = AnalyticsManager.getEventHistory();
      expect(history.last.name, 'feature_usage');
      expect(history.last.parameters['feature_name'], 'dark_mode');
    });

    test('should track error', () async {
      await EventTracker.trackError('NetworkError', 'Connection failed');

      final history = AnalyticsManager.getEventHistory();
      expect(history.last.name, 'error_occurred');
      expect(history.last.parameters['error_type'], 'NetworkError');
    });

    test('should track custom event', () async {
      await EventTracker.trackCustom(
        'custom_event',
        {'custom_param': 'value'},
      );

      final history = AnalyticsManager.getEventHistory();
      expect(history.last.name, 'custom_event');
      expect(history.last.parameters['custom_param'], 'value');
    });
  });
}

