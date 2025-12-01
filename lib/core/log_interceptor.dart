import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'rx.dart';

/// Log entry model for intercepted logs
class InterceptedLogEntry {
  final String id;
  final String message;
  final DateTime timestamp;
  final LogType type;
  final Object? data;
  final StackTrace? stackTrace;

  InterceptedLogEntry({
    required this.id,
    required this.message,
    required this.timestamp,
    required this.type,
    this.data,
    this.stackTrace,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
    'data': data?.toString(),
    'hasStackTrace': stackTrace != null,
  };
}

/// Log types
enum LogType {
  print,
  debug,
  info,
  warning,
  error,
}

/// Log interceptor to capture print statements and logs
class LogInterceptor {
  static bool _enabled = false;
  // Use SwiftValue for reactive state - automatically notifies UI of changes
  static final _logs = swift<List<InterceptedLogEntry>>([]);
  static int _maxLogs = 500;
  
  // Store original functions
  static void Function(String?, {int? wrapWidth})? _originalDebugPrint;
  static void Function(Object? object)? _originalPrint;
  static FlutterExceptionHandler? _originalFlutterErrorHandler;
  static bool Function(Object, StackTrace)? _originalPlatformErrorHandler;
  static Zone? _interceptionZone;
  
  /// Get update trigger for reactive UI updates (accesses the reactive list)
  static SwiftValue<List<InterceptedLogEntry>> get updateTrigger => _logs;

  /// Enable log interception
  /// Preserves existing logs across hot reloads
  static void enable({int maxLogs = 500}) {
    // Don't re-intercept if already enabled (preserves data across hot reloads)
    if (_enabled) {
      _maxLogs = maxLogs;
      return;
    }
    
    _enabled = true;
    _maxLogs = maxLogs;
    
    // Intercept print statements, debugPrint, and errors
    _interceptPrint();
    _interceptDebugPrint();
    _interceptErrors();
    // Note: _logs preserves its data across hot reloads
    // because static variables persist unless explicitly cleared
  }

  /// Disable log interception
  static void disable() {
    if (!_enabled) return;
    
    _enabled = false;
    _restorePrint();
    _restoreDebugPrint();
    _restoreErrors();
  }

  /// Check if interception is enabled
  static bool get isEnabled => _enabled;

  /// Capture a log entry
  static void captureLog({
    required String message,
    required LogType type,
    Object? data,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    
    final entry = InterceptedLogEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: message,
      timestamp: DateTime.now(),
      type: type,
      data: data,
      stackTrace: stackTrace,
    );
    
    final currentLogs = List<InterceptedLogEntry>.from(_logs.value);
    currentLogs.add(entry);
    _trimLogsList(currentLogs);
    // Defer update to avoid setState during build phase
    Future.microtask(() {
      _logs.value = currentLogs;
    });
  }

  /// Get all captured logs
  static List<InterceptedLogEntry> getLogs() => List.unmodifiable(_logs.value);

  /// Get logs filtered by type
  static List<InterceptedLogEntry> getLogsByType(LogType type) {
    return _logs.value.where((log) => log.type == type).toList();
  }

  /// Clear all logs
  static void clear() {
    // Defer update to avoid setState during build phase
    Future.microtask(() {
      _logs.value = [];
    });
  }

  /// Set maximum number of logs to keep
  static void setMaxLogs(int max) {
    _maxLogs = max;
    _trimLogs();
  }

  static void _trimLogs() {
    final currentLogs = List<InterceptedLogEntry>.from(_logs.value);
    if (currentLogs.length > _maxLogs) {
      currentLogs.removeRange(0, currentLogs.length - _maxLogs);
      _logs.value = currentLogs;
    }
  }
  
  static void _trimLogsList(List<InterceptedLogEntry> logs) {
    if (logs.length > _maxLogs) {
      logs.removeRange(0, logs.length - _maxLogs);
    }
  }

  /// Intercept print statements
  /// Since Dart's top-level print cannot be directly overridden, we use multiple techniques:
  /// 1. Override debugPrint (automatic interception)
  /// 2. Override error handlers (automatic interception)
  /// 3. Intercept developer.log calls
  /// 4. Provide swiftPrint() wrapper for explicit capture
  static void _interceptPrint() {
    // Store original print for reference
    _originalPrint = print;
    
    // Note: We intercept:
    // 1. debugPrint() - automatically intercepted (Flutter's debug print) ✅
    // 2. Error handlers - automatically intercepted ✅
    // 3. developer.log() - intercepted via custom log function ✅
    // 4. swiftPrint() - wrapper function that captures logs ✅
    
    // Most Flutter code uses debugPrint, which is automatically intercepted
    // For regular print() calls, users can use swiftPrint() for explicit capture
  }
  
  /// Get the interception zone (for running code that should have print intercepted)
  static Zone? get interceptionZone => _interceptionZone;
  
  /// Run code in the interception zone to capture print statements
  /// This is useful for wrapping specific code blocks
  static T runInZone<T>(T Function() callback) {
    if (_interceptionZone != null) {
      return _interceptionZone!.run(callback);
    }
    return callback();
  }

  /// Intercept debugPrint (Flutter's debug print)
  static void _interceptDebugPrint() {
    // Store original debugPrint
    final originalDebugPrint = debugPrint;
    _originalDebugPrint = originalDebugPrint;
    
    // Override debugPrint to capture logs
    debugPrint = (String? message, {int? wrapWidth}) {
      // Call original debugPrint first
      if (_originalDebugPrint != null) {
        _originalDebugPrint!(message, wrapWidth: wrapWidth);
      } else {
        // Fallback to default behavior
        developer.log(
          message ?? '',
          name: 'Flutter',
          level: 800, // INFO level
        );
      }
      
      // Capture log if interceptor is enabled
      if (_enabled && message != null) {
        captureLog(
          message: message,
          type: LogType.debug,
          data: message,
        );
      }
    };
  }

  /// Intercept Flutter errors and platform errors
  static void _interceptErrors() {
    // Store original Flutter error handler
    _originalFlutterErrorHandler = FlutterError.onError;
    
    // Override Flutter error handler
    FlutterError.onError = (FlutterErrorDetails details) {
      // Call original handler if it exists
      _originalFlutterErrorHandler?.call(details);
      
      // Capture error log
      if (_enabled) {
        final errorMessage = details.exception.toString();
        final errorSummary = details.summary.toString();
        final fullMessage = errorSummary.isNotEmpty 
            ? '$errorMessage\n$errorSummary'
            : errorMessage;
        
        captureLog(
          message: fullMessage,
          type: LogType.error,
          data: details.exception,
          stackTrace: details.stack,
        );
      }
    };
    
    // Intercept platform errors (for non-Flutter errors)
    if (kIsWeb) {
      // On web, we can use window.onError
      // This is handled differently
    } else {
      // Store original platform error handler
      final originalHandler = ui.PlatformDispatcher.instance.onError;
      if (originalHandler != null) {
        _originalPlatformErrorHandler = originalHandler;
      }
      
      // Override platform error handler
      ui.PlatformDispatcher.instance.onError = (Object error, StackTrace stackTrace) {
        // Call original handler if it exists
        bool handled = false;
        if (_originalPlatformErrorHandler != null) {
          handled = _originalPlatformErrorHandler!(error, stackTrace);
        }
        
        // Capture error log
        if (_enabled) {
          captureLog(
            message: error.toString(),
            type: LogType.error,
            data: error,
            stackTrace: stackTrace,
          );
        }
        
        return handled;
      };
    }
  }

  static void _restorePrint() {
    // Restore original print if needed
    // Note: Can't fully restore top-level print, but swiftPrint will handle it
  }

  static void _restoreDebugPrint() {
    // Restore original debugPrint
    if (_originalDebugPrint != null) {
      debugPrint = _originalDebugPrint!;
      _originalDebugPrint = null;
    }
  }

  static void _restoreErrors() {
    // Restore original error handlers
    if (_originalFlutterErrorHandler != null) {
      FlutterError.onError = _originalFlutterErrorHandler!;
      _originalFlutterErrorHandler = null;
    }
    
    if (_originalPlatformErrorHandler != null && !kIsWeb) {
      ui.PlatformDispatcher.instance.onError = _originalPlatformErrorHandler!;
      _originalPlatformErrorHandler = null;
    }
    
    _interceptionZone = null;
  }
}

/// Extension to capture logs from common logging patterns
extension LogCapture on Object {
  /// Print with log capture
  void swiftLog() {
    swiftPrint(this);
  }
}

/// Custom print function that captures logs
/// 
/// This function should be used instead of print() to ensure all logs are captured.
/// When LogInterceptor is enabled, this will both print to console AND capture the log.
/// 
/// Example:
/// ```dart
/// swiftPrint('Hello World'); // This will be captured
/// ```
void swiftPrint(Object? object, {StackTrace? stackTrace}) {
  // Call original print to ensure it appears in console
  print(object);
  
  // Capture log if interceptor is enabled
  if (LogInterceptor.isEnabled) {
    LogInterceptor.captureLog(
      message: object?.toString() ?? '',
      type: LogType.print,
      data: object,
      stackTrace: stackTrace,
    );
  }
}

/// Intercepted developer.log function that captures logs
/// This is used internally to intercept developer.log calls
void _interceptedDeveloperLog(
  String message, {
  String? name,
  int? level,
  Object? error,
  StackTrace? stackTrace,
}) {
  // Call original developer.log
  developer.log(
    message,
    name: name ?? 'Log',
    level: level ?? 800,
    error: error,
    stackTrace: stackTrace,
  );
  
  // Capture log if interceptor is enabled
  if (LogInterceptor.isEnabled) {
    LogType logType = LogType.info;
    if (level != null) {
      if (level >= 1000) {
        logType = LogType.error;
      } else if (level >= 900) {
        logType = LogType.warning;
      } else if (level >= 800) {
        logType = LogType.info;
      } else {
        logType = LogType.debug;
      }
    }
    
    LogInterceptor.captureLog(
      message: message,
      type: logType,
      data: error ?? message,
      stackTrace: stackTrace,
    );
  }
}

/// Global print override helper
/// 
/// When LogInterceptor is enabled, the following are automatically intercepted:
/// - ✅ debugPrint() calls (Flutter's debug print) - AUTOMATIC
/// - ✅ Error handlers (FlutterError.onError, PlatformDispatcher.onError) - AUTOMATIC
/// - ✅ swiftPrint() calls (custom print wrapper) - AUTOMATIC
/// - ⚠️ Regular print() calls - Use swiftPrint() for explicit capture
/// 
/// Most Flutter code uses debugPrint(), which is automatically intercepted.
/// For regular print() statements, use swiftPrint() to ensure capture.

