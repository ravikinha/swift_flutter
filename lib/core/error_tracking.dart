import 'dart:async';
import 'package:flutter/foundation.dart';
import 'devtools.dart' show SwiftDevTools;
import 'performance_monitor.dart';

/// Error severity levels
enum ErrorSeverity {
  debug,
  info,
  warning,
  error,
  fatal,
}

/// Error tracking configuration
class ErrorTrackingConfig {
  /// Enable error tracking
  final bool enabled;

  /// Environment (development, staging, production)
  final String environment;

  /// Release version
  final String? release;

  /// Custom error handler
  final Future<void> Function(Object error, StackTrace stack, Map<String, dynamic> context)? onError;

  /// Custom log handler
  final Future<void> Function(String message, ErrorSeverity severity)? onLog;

  /// Sample rate (0.0 to 1.0)
  final double sampleRate;

  /// Enable performance tracking
  final bool enablePerformanceTracking;

  /// Enable breadcrumbs
  final bool enableBreadcrumbs;

  /// Max breadcrumbs
  final int maxBreadcrumbs;

  const ErrorTrackingConfig({
    this.enabled = true,
    this.environment = 'development',
    this.release,
    this.onError,
    this.onLog,
    this.sampleRate = 1.0,
    this.enablePerformanceTracking = true,
    this.enableBreadcrumbs = true,
    this.maxBreadcrumbs = 100,
  });
}

/// Breadcrumb for tracking user actions
class Breadcrumb {
  final String message;
  final String category;
  final ErrorSeverity level;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  Breadcrumb({
    required this.message,
    required this.category,
    this.level = ErrorSeverity.info,
    DateTime? timestamp,
    this.data,
  }) : timestamp = timestamp ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'message': message,
        'category': category,
        'level': level.name,
        'timestamp': timestamp.toIso8601String(),
        if (data != null) 'data': data,
      };
}

/// Error context information
class ErrorContext {
  final Map<String, dynamic> tags;
  final Map<String, dynamic> extra;
  final String? userId;
  final String? userEmail;
  final List<Breadcrumb> breadcrumbs;

  ErrorContext({
    Map<String, dynamic>? tags,
    Map<String, dynamic>? extra,
    this.userId,
    this.userEmail,
    List<Breadcrumb>? breadcrumbs,
  })  : tags = tags ?? {},
        extra = extra ?? {},
        breadcrumbs = breadcrumbs ?? [];

  Map<String, dynamic> toJson() => {
        'tags': tags,
        'extra': extra,
        if (userId != null) 'userId': userId,
        if (userEmail != null) 'userEmail': userEmail,
        'breadcrumbs': breadcrumbs.map((b) => b.toJson()).toList(),
      };
}

/// Central error tracking system
class SwiftErrorTracker {
  static ErrorTrackingConfig _config = const ErrorTrackingConfig();
  static final List<Breadcrumb> _breadcrumbs = [];
  static ErrorContext _context = ErrorContext();
  static final List<ErrorEvent> _errorHistory = [];
  static const int _maxErrorHistory = 50;

  /// Configure error tracking
  static void configure(ErrorTrackingConfig config) {
    _config = config;

    // Set up global error handlers if enabled
    if (config.enabled) {
      FlutterError.onError = (FlutterErrorDetails details) {
        captureException(
          details.exception,
          details.stack ?? StackTrace.current,
          severity: ErrorSeverity.error,
        );
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        captureException(error, stack, severity: ErrorSeverity.fatal);
        return true;
      };
    }
  }

  /// Set user context
  static void setUser({
    String? userId,
    String? email,
    Map<String, dynamic>? extra,
  }) {
    _context = ErrorContext(
      tags: _context.tags,
      extra: {..._context.extra, if (extra != null) ...extra},
      userId: userId,
      userEmail: email,
      breadcrumbs: _context.breadcrumbs,
    );
  }

  /// Add tag
  static void setTag(String key, String value) {
    _context.tags[key] = value;
  }

  /// Add extra context
  static void setExtra(String key, dynamic value) {
    _context.extra[key] = value;
  }

  /// Add breadcrumb
  static void addBreadcrumb(Breadcrumb breadcrumb) {
    if (!_config.enableBreadcrumbs) return;

    _breadcrumbs.add(breadcrumb);
    if (_breadcrumbs.length > _config.maxBreadcrumbs) {
      _breadcrumbs.removeAt(0);
    }
  }

  /// Capture exception
  static Future<void> captureException(
    Object exception,
    StackTrace stackTrace, {
    ErrorSeverity severity = ErrorSeverity.error,
    Map<String, dynamic>? extra,
  }) async {
    if (!_config.enabled) return;

    // Sample rate check
    if (_config.sampleRate < 1.0) {
      if (DateTime.now().millisecondsSinceEpoch % 100 >= _config.sampleRate * 100) {
        return;
      }
    }

    // Build error context
    final errorContext = _buildErrorContext(extra);

    // Store in history
    _addToHistory(ErrorEvent(
      exception: exception,
      stackTrace: stackTrace,
      severity: severity,
      context: errorContext,
      timestamp: DateTime.now(),
    ));

    // Call custom handler
    if (_config.onError != null) {
      try {
        await _config.onError!(exception, stackTrace, errorContext);
      } catch (e) {
        debugPrint('Error in custom error handler: $e');
      }
    }

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('SwiftErrorTracker: $severity - $exception');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Capture message
  static Future<void> captureMessage(
    String message, {
    ErrorSeverity severity = ErrorSeverity.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!_config.enabled) return;

    // Add as breadcrumb
    addBreadcrumb(Breadcrumb(
      message: message,
      category: 'log',
      level: severity,
    ));

    // Call custom log handler
    if (_config.onLog != null) {
      try {
        await _config.onLog!(message, severity);
      } catch (e) {
        debugPrint('Error in custom log handler: $e');
      }
    }

    // Log to console in debug mode
    if (kDebugMode) {
      debugPrint('SwiftErrorTracker: $severity - $message');
    }
  }

  /// Get error context with Swift Flutter state
  static Map<String, dynamic> _buildErrorContext(Map<String, dynamic>? extra) {
    final context = <String, dynamic>{
      'environment': _config.environment,
      'release': _config.release,
      'timestamp': DateTime.now().toIso8601String(),
      'breadcrumbs': _breadcrumbs.map((b) => b.toJson()).toList(),
      'user': {
        if (_context.userId != null) 'id': _context.userId,
        if (_context.userEmail != null) 'email': _context.userEmail,
      },
      'tags': _context.tags,
      'extra': {..._context.extra, if (extra != null) ...extra},
    };

    // Add Swift Flutter specific context
    if (SwiftDevTools.isEnabled) {
      context['swiftFlutter'] = {
        'devToolsEnabled': true,
      };
    }

    // Add performance metrics
    if (_config.enablePerformanceTracking && PerformanceMonitor.isEnabled) {
      context['performance'] = PerformanceMonitor.getReport();
    }

    return context;
  }

  /// Add to error history
  static void _addToHistory(ErrorEvent event) {
    _errorHistory.add(event);
    if (_errorHistory.length > _maxErrorHistory) {
      _errorHistory.removeAt(0);
    }
  }

  /// Get error history
  static List<ErrorEvent> getErrorHistory() => List.unmodifiable(_errorHistory);

  /// Get breadcrumbs
  static List<Breadcrumb> getBreadcrumbs() => List.unmodifiable(_breadcrumbs);

  /// Clear breadcrumbs
  static void clearBreadcrumbs() => _breadcrumbs.clear();

  /// Clear error history
  static void clearErrorHistory() => _errorHistory.clear();

  /// Get user-friendly error message
  static String getUserFriendlyMessage(Object error) {
    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception: " prefix
      if (message.startsWith('Exception: ')) {
        return message.substring(11);
      }
      return message;
    }
    return error.toString();
  }
}

/// Error event for history
class ErrorEvent {
  final Object exception;
  final StackTrace stackTrace;
  final ErrorSeverity severity;
  final Map<String, dynamic> context;
  final DateTime timestamp;

  ErrorEvent({
    required this.exception,
    required this.stackTrace,
    required this.severity,
    required this.context,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'exception': exception.toString(),
        'stackTrace': stackTrace.toString(),
        'severity': severity.name,
        'context': context,
        'timestamp': timestamp.toIso8601String(),
      };
}

/// Sentry integration helper
class SentryIntegration {
  /// Configure Sentry (requires sentry_flutter package)
  static ErrorTrackingConfig createConfig({
    required String dsn,
    String environment = 'production',
    String? release,
    double sampleRate = 1.0,
  }) {
    return ErrorTrackingConfig(
      enabled: true,
      environment: environment,
      release: release,
      sampleRate: sampleRate,
      onError: (error, stack, context) async {
        // Note: Actual Sentry integration requires sentry_flutter package
        // This is a placeholder for the integration pattern
        debugPrint('Sentry: Would send error to DSN: $dsn');
        debugPrint('Error: $error');
        debugPrint('Context: $context');
      },
      onLog: (message, severity) async {
        debugPrint('Sentry: Would log message: $message ($severity)');
      },
    );
  }
}

/// Firebase Crashlytics integration helper
class FirebaseCrashlyticsIntegration {
  /// Configure Firebase Crashlytics (requires firebase_crashlytics package)
  static ErrorTrackingConfig createConfig({
    String environment = 'production',
    String? release,
  }) {
    return ErrorTrackingConfig(
      enabled: true,
      environment: environment,
      release: release,
      onError: (error, stack, context) async {
        // Note: Actual Firebase integration requires firebase_crashlytics package
        // This is a placeholder for the integration pattern
        debugPrint('Firebase: Would send error to Crashlytics');
        debugPrint('Error: $error');
        debugPrint('Context: $context');
      },
      onLog: (message, severity) async {
        debugPrint('Firebase: Would log message: $message ($severity)');
      },
    );
  }
}

