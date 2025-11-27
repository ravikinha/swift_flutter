import 'dart:async';
import 'package:flutter/foundation.dart';
import '../store/middleware.dart';

/// Analytics event
class AnalyticsEvent {
  final String name;
  final Map<String, dynamic> parameters;
  final DateTime timestamp;

  AnalyticsEvent({
    required this.name,
    Map<String, dynamic>? parameters,
    DateTime? timestamp,
  })  : parameters = parameters ?? {},
        timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'name': name,
        'parameters': parameters,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Analytics provider interface
abstract class AnalyticsProvider {
  /// Log event
  Future<void> logEvent(String name, Map<String, dynamic>? parameters);

  /// Set user property
  Future<void> setUserProperty(String name, String value);

  /// Set user ID
  Future<void> setUserId(String userId);

  /// Log screen view
  Future<void> logScreenView(String screenName, {String? screenClass});
}

/// Debug analytics provider (for development)
class DebugAnalyticsProvider implements AnalyticsProvider {
  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    if (kDebugMode) {
      debugPrint('Analytics Event: $name');
      if (parameters != null && parameters.isNotEmpty) {
        debugPrint('Parameters: $parameters');
      }
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    if (kDebugMode) {
      debugPrint('Analytics User Property: $name = $value');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    if (kDebugMode) {
      debugPrint('Analytics User ID: $userId');
    }
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    if (kDebugMode) {
      debugPrint('Analytics Screen View: $screenName');
      if (screenClass != null) {
        debugPrint('Screen Class: $screenClass');
      }
    }
  }
}

/// Firebase Analytics provider (placeholder - requires firebase_analytics)
class FirebaseAnalyticsProvider implements AnalyticsProvider {
  // Note: Requires firebase_analytics package
  // import 'package:firebase_analytics/firebase_analytics.dart';
  // final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  Future<void> logEvent(String name, Map<String, dynamic>? parameters) async {
    // Production: await _analytics.logEvent(name: name, parameters: parameters);
    if (kDebugMode) {
      debugPrint('Firebase Analytics: Would log event $name');
    }
  }

  @override
  Future<void> setUserProperty(String name, String value) async {
    // Production: await _analytics.setUserProperty(name: name, value: value);
    if (kDebugMode) {
      debugPrint('Firebase Analytics: Would set user property $name');
    }
  }

  @override
  Future<void> setUserId(String userId) async {
    // Production: await _analytics.setUserId(id: userId);
    if (kDebugMode) {
      debugPrint('Firebase Analytics: Would set user ID $userId');
    }
  }

  @override
  Future<void> logScreenView(String screenName, {String? screenClass}) async {
    // Production: await _analytics.logScreenView(screenName: screenName, screenClass: screenClass);
    if (kDebugMode) {
      debugPrint('Firebase Analytics: Would log screen view $screenName');
    }
  }
}

/// Analytics manager
class AnalyticsManager {
  static final List<AnalyticsProvider> _providers = [];
  static final List<AnalyticsEvent> _eventHistory = [];
  static const int _maxHistorySize = 100;
  static bool _enabled = true;

  /// Add analytics provider
  static void addProvider(AnalyticsProvider provider) {
    _providers.add(provider);
  }

  /// Remove analytics provider
  static void removeProvider(AnalyticsProvider provider) {
    _providers.remove(provider);
  }

  /// Enable/disable analytics
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Check if analytics is enabled
  static bool get isEnabled => _enabled;

  /// Log event to all providers
  static Future<void> logEvent(
    String name, {
    Map<String, dynamic>? parameters,
  }) async {
    if (!_enabled) return;

    final event = AnalyticsEvent(name: name, parameters: parameters);
    _addToHistory(event);

    for (final provider in _providers) {
      try {
        await provider.logEvent(name, parameters);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error logging event to provider: $e');
        }
      }
    }
  }

  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      try {
        await provider.setUserProperty(name, value);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error setting user property: $e');
        }
      }
    }
  }

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      try {
        await provider.setUserId(userId);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error setting user ID: $e');
        }
      }
    }
  }

  /// Log screen view
  static Future<void> logScreenView(
    String screenName, {
    String? screenClass,
  }) async {
    if (!_enabled) return;

    for (final provider in _providers) {
      try {
        await provider.logScreenView(screenName, screenClass: screenClass);
      } catch (e) {
        if (kDebugMode) {
          debugPrint('Error logging screen view: $e');
        }
      }
    }
  }

  /// Get event history
  static List<AnalyticsEvent> getEventHistory() {
    return List.unmodifiable(_eventHistory);
  }

  /// Clear event history
  static void clearEventHistory() {
    _eventHistory.clear();
  }

  /// Add event to history
  static void _addToHistory(AnalyticsEvent event) {
    _eventHistory.add(event);
    if (_eventHistory.length > _maxHistorySize) {
      _eventHistory.removeAt(0);
    }
  }
}

/// Analytics middleware for tracking state actions
class AnalyticsMiddleware extends Middleware {
  final bool trackActions;
  final bool trackErrors;
  final Map<String, dynamic> Function(Action)? customParameters;

  AnalyticsMiddleware({
    this.trackActions = true,
    this.trackErrors = true,
    this.customParameters,
  });

  @override
  Future<Action?> before(Action action) async {
    if (trackActions) {
      final parameters = <String, dynamic>{
        'action_type': action.type,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (customParameters != null) {
        parameters.addAll(customParameters!(action));
      }

      await AnalyticsManager.logEvent(
        'state_action',
        parameters: parameters,
      );
    }

    return action;
  }

  @override
  Future<void> after(Action action, dynamic result) async {
    // Log successful action completion if needed
    if (trackActions) {
      await AnalyticsManager.logEvent(
        'state_action_completed',
        parameters: {
          'action_type': action.type,
          'success': true,
        },
      );
    }
  }

  @override
  Future<void> onError(Object error, StackTrace stackTrace, Action action) async {
    if (trackErrors) {
      await AnalyticsManager.logEvent(
        'state_action_error',
        parameters: {
          'action_type': action.type,
          'error': error.toString(),
        },
      );
    }
  }
}

/// Screen tracking helper
class ScreenTracker {
  static String? _currentScreen;

  /// Track screen view
  static Future<void> trackScreen(String screenName, {String? screenClass}) async {
    if (_currentScreen == screenName) return;

    _currentScreen = screenName;
    await AnalyticsManager.logScreenView(screenName, screenClass: screenClass);
  }

  /// Get current screen
  static String? get currentScreen => _currentScreen;
}

/// User tracking helper
class UserTracker {
  static String? _userId;
  static final Map<String, String> _userProperties = {};

  /// Set user ID
  static Future<void> setUserId(String userId) async {
    _userId = userId;
    await AnalyticsManager.setUserId(userId);
  }

  /// Set user property
  static Future<void> setUserProperty(String name, String value) async {
    _userProperties[name] = value;
    await AnalyticsManager.setUserProperty(name, value);
  }

  /// Get user ID
  static String? get userId => _userId;

  /// Get user properties
  static Map<String, String> get userProperties =>
      Map.unmodifiable(_userProperties);

  /// Clear user data
  static void clear() {
    _userId = null;
    _userProperties.clear();
  }
}

/// Event tracking helper
class EventTracker {
  /// Track button click
  static Future<void> trackButtonClick(String buttonName) async {
    await AnalyticsManager.logEvent(
      'button_click',
      parameters: {'button_name': buttonName},
    );
  }

  /// Track feature usage
  static Future<void> trackFeatureUsage(String featureName) async {
    await AnalyticsManager.logEvent(
      'feature_usage',
      parameters: {'feature_name': featureName},
    );
  }

  /// Track error
  static Future<void> trackError(String errorType, String errorMessage) async {
    await AnalyticsManager.logEvent(
      'error_occurred',
      parameters: {
        'error_type': errorType,
        'error_message': errorMessage,
      },
    );
  }

  /// Track custom event
  static Future<void> trackCustom(
    String eventName,
    Map<String, dynamic>? parameters,
  ) async {
    await AnalyticsManager.logEvent(eventName, parameters: parameters);
  }
}

