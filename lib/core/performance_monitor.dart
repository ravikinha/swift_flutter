import 'logger.dart';

/// Performance monitoring for reactive state updates and widget rebuilds
class PerformanceMonitor {
  static final Map<String, int> _rebuildCounts = {};
  static final Map<String, List<Duration>> _updateTimes = {};
  static final Map<String, DateTime> _lastRebuild = {};
  static bool _enabled = false;
  static int _slowUpdateThresholdMs = 16; // 1 frame at 60fps

  /// Enable or disable performance monitoring
  static void setEnabled(bool enabled) {
    _enabled = enabled;
  }

  /// Check if monitoring is enabled
  static bool get isEnabled => _enabled;

  /// Set threshold for slow update warnings (in milliseconds)
  static void setSlowUpdateThreshold(int milliseconds) {
    _slowUpdateThresholdMs = milliseconds;
  }

  /// Track a widget rebuild
  static void trackRebuild(String widgetName) {
    if (!_enabled) return;
    
    _rebuildCounts[widgetName] = (_rebuildCounts[widgetName] ?? 0) + 1;
    _lastRebuild[widgetName] = DateTime.now();
  }

  /// Track a state update duration
  static void trackUpdate(String stateName, Duration duration) {
    if (!_enabled) return;
    
    _updateTimes.putIfAbsent(stateName, () => []).add(duration);
    
    if (duration.inMilliseconds > _slowUpdateThresholdMs) {
      Logger.warning(
        'Slow update: $stateName took ${duration.inMilliseconds}ms',
        duration,
      );
    }
  }

  /// Get performance report
  static Map<String, dynamic> getReport() {
    return {
      'rebuilds': Map<String, int>.from(_rebuildCounts),
      'avgUpdateTime': _updateTimes.map((k, v) {
        if (v.isEmpty) return MapEntry(k, 0.0);
        final total = v.reduce((a, b) => a + b).inMilliseconds;
        return MapEntry(k, total / v.length);
      }),
      'lastRebuilds': _lastRebuild.map((k, v) => MapEntry(k, v.toIso8601String())),
      'totalRebuilds': _rebuildCounts.values.fold(0, (a, b) => a + b),
      'totalUpdates': _updateTimes.values.fold(0, (a, b) => a + b.length),
    };
  }

  /// Get rebuild count for a specific widget
  static int getRebuildCount(String widgetName) {
    return _rebuildCounts[widgetName] ?? 0;
  }

  /// Get average update time for a specific state
  static double? getAverageUpdateTime(String stateName) {
    final times = _updateTimes[stateName];
    if (times == null || times.isEmpty) return null;
    
    final total = times.reduce((a, b) => a + b).inMilliseconds;
    return total / times.length;
  }

  /// Reset all performance metrics
  static void reset() {
    _rebuildCounts.clear();
    _updateTimes.clear();
    _lastRebuild.clear();
  }

  /// Clear rebuild counts
  static void clearRebuildCounts() {
    _rebuildCounts.clear();
    _lastRebuild.clear();
  }

  /// Clear update times
  static void clearUpdateTimes() {
    _updateTimes.clear();
  }
}

