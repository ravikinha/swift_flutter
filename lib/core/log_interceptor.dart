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
  static final List<InterceptedLogEntry> _logs = [];
  static int _maxLogs = 500;

  /// Enable log interception
  static void enable({int maxLogs = 500}) {
    if (_enabled) return;
    
    _enabled = true;
    _maxLogs = maxLogs;
    
    // Intercept print statements
    _interceptPrint();
  }

  /// Disable log interception
  static void disable() {
    if (!_enabled) return;
    
    _enabled = false;
    _restorePrint();
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
    
    _logs.add(entry);
    _trimLogs();
  }

  /// Get all captured logs
  static List<InterceptedLogEntry> getLogs() => List.unmodifiable(_logs);

  /// Get logs filtered by type
  static List<InterceptedLogEntry> getLogsByType(LogType type) {
    return _logs.where((log) => log.type == type).toList();
  }

  /// Clear all logs
  static void clear() {
    _logs.clear();
  }

  /// Set maximum number of logs to keep
  static void setMaxLogs(int max) {
    _maxLogs = max;
    _trimLogs();
  }

  static void _trimLogs() {
    if (_logs.length > _maxLogs) {
      _logs.removeRange(0, _logs.length - _maxLogs);
    }
  }

  static void _interceptPrint() {
    // Note: Dart's print cannot be easily intercepted at the language level
    // Users should use swiftPrint() instead of print() to capture logs
    // Or we can provide a custom print wrapper
    // This is a placeholder for future implementation
  }

  static void _restorePrint() {
    // Restore original print if needed
    // This is a placeholder for future implementation
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
void swiftPrint(Object? object, {StackTrace? stackTrace}) {
  // Call original print
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

