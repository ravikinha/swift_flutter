import 'package:flutter/foundation.dart';

/// Log levels
enum LogLevel { debug, info, warning, error }

/// Logger for debugging reactive state changes
class Logger {
  static LogLevel _level = LogLevel.info;
  static bool _enabled = false;
  static final List<LogEntry> _history = [];
  static int _maxHistory = 100;

  /// Enable/disable logging
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Set minimum log level
  static void setLevel(LogLevel level) {
    _level = level;
  }

  /// Set maximum history entries
  static void setMaxHistory(int max) {
    _maxHistory = max;
    if (_history.length > _maxHistory) {
      _history.removeRange(0, _history.length - _maxHistory);
    }
  }

  /// Get log history
  static List<LogEntry> get history => List.unmodifiable(_history);

  /// Clear log history
  static void clear() {
    _history.clear();
  }

  static void _log(LogLevel level, String message, [Object? data]) {
    if (!_enabled || level.index < _level.index) return;

    final entry = LogEntry(
      level: level,
      message: message,
      data: data,
      timestamp: DateTime.now(),
    );

    _history.add(entry);
    if (_history.length > _maxHistory) {
      _history.removeAt(0);
    }

    final prefix = _getPrefix(level);
    if (kDebugMode) {
      debugPrint('$prefix $message${data != null ? ': $data' : ''}');
    }
  }

  static String _getPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '🐛 [DEBUG]';
      case LogLevel.info:
        return 'ℹ️  [INFO]';
      case LogLevel.warning:
        return '⚠️  [WARN]';
      case LogLevel.error:
        return '❌ [ERROR]';
    }
  }

  static void debug(String message, [Object? data]) {
    _log(LogLevel.debug, message, data);
  }

  static void info(String message, [Object? data]) {
    _log(LogLevel.info, message, data);
  }

  static void warning(String message, [Object? data]) {
    _log(LogLevel.warning, message, data);
  }

  static void error(String message, [Object? error]) {
    _log(LogLevel.error, message, error);
  }
}

/// Log entry
class LogEntry {
  final LogLevel level;
  final String message;
  final Object? data;
  final DateTime timestamp;

  LogEntry({
    required this.level,
    required this.message,
    this.data,
    required this.timestamp,
  });

  @override
  String toString() {
    return '[${timestamp.toIso8601String()}] ${Logger._getPrefix(level)} $message${data != null ? ': $data' : ''}';
  }
}

