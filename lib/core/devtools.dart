import 'package:flutter/foundation.dart';
import 'rx.dart';
import 'computed.dart';
import 'performance_monitor.dart';
import '../store/store.dart';
import 'reducers.dart';

/// DevTools integration for Swift Flutter
/// 
/// Provides zero-overhead debugging when disabled.
/// All tracking is lazy-loaded and conditional.
class SwiftDevTools {
  static bool _enabled = false;
  static bool _trackDependencies = false;
  static bool _trackStateHistory = false;
  static bool _trackPerformance = false;
  
  /// Check if dependency tracking is enabled (internal use)
  static bool get isTrackingDependencies => _trackDependencies;
  
  /// Check if state history tracking is enabled (internal use)
  static bool get isTrackingStateHistory => _trackStateHistory;
  
  /// Check if performance tracking is enabled (internal use)
  static bool get isTrackingPerformance => _trackPerformance;
  
  // Lazy-loaded tracking data (only created when needed)
  static final Map<String, _StateNode> _stateNodes = {};
  static final Map<String, _DependencyEdge> _dependencyGraph = {};
  static final List<_StateSnapshot> _stateHistory = [];
  static final Map<String, _SwiftInfo> _swiftRegistry = {};
  static final Map<String, _ComputedInfo> _computedRegistry = {};
  static final Map<String, _MarkInfo> _markRegistry = {};
  static final Map<String, _ControllerInfo> _controllerRegistry = {};
  
  // References for actual objects (for state inspector)
  // Note: In debug mode, keeping strong references is acceptable for DevTools
  static final Map<String, SwiftValue<dynamic>> _swiftRefs = {};
  
  // Backward compatibility
  @Deprecated('Use _swiftRegistry instead')
  // ignore: deprecated_member_use_from_same_package
  static Map<String, _RxInfo> get _rxRegistry => _swiftRegistry.map((k, v) => MapEntry(k, _RxInfo(id: v.id, name: v.name, type: v.type, createdAt: v.createdAt)));
  
  @Deprecated('Use _swiftRefs instead')
  // ignore: deprecated_member_use_from_same_package
  static Map<String, Rx<dynamic>> get _rxRefs => _swiftRefs.cast<String, Rx<dynamic>>();
  static final Map<String, Computed<dynamic>> _computedRefs = {};
  static final Map<String, ReduxStore<dynamic>> _reduxStoreRefs = {};
  static final Map<String, dynamic> _controllerRefs = {};
  
  /// Track Mark widget creation (internal use)
  static void trackMarkCreation(dynamic mark, String name) {
    if (!_enabled || !_trackDependencies) return;
    _markRegistry[getMarkId(mark)] = _MarkInfo(
      id: getMarkId(mark),
      name: name,
      createdAt: DateTime.now(),
    );
  }
  
  // Performance tracking (only when enabled)
  static final List<_PerformanceEvent> _performanceEvents = [];
  static int _maxHistorySize = 1000;
  static int _maxPerformanceEvents = 500;

  /// Enable DevTools integration
  /// 
  /// [trackDependencies] - Track dependency graph (minimal overhead)
  /// [trackStateHistory] - Track state change history (moderate overhead)
  /// [trackPerformance] - Track performance events (minimal overhead)
  static void enable({
    bool trackDependencies = true,
    bool trackStateHistory = false,
    bool trackPerformance = true,
  }) {
    _enabled = true;
    _trackDependencies = trackDependencies;
    _trackStateHistory = trackStateHistory;
    _trackPerformance = trackPerformance;
    
    if (trackPerformance) {
      PerformanceMonitor.setEnabled(true);
    }
    
    if (kDebugMode) {
      debugPrint('🔧 Swift DevTools enabled');
    }
  }

  /// Disable DevTools integration (zero overhead)
  static void disable() {
    _enabled = false;
    _trackDependencies = false;
    _trackStateHistory = false;
    _trackPerformance = false;
    PerformanceMonitor.setEnabled(false);
    _clearAll();
  }

  /// Check if DevTools is enabled
  static bool get isEnabled => _enabled;

  /// Set maximum history size
  static void setMaxHistorySize(int size) {
    _maxHistorySize = size;
    _trimHistory();
  }

  /// Set maximum performance events
  static void setMaxPerformanceEvents(int size) {
    _maxPerformanceEvents = size;
    _trimPerformanceEvents();
  }

  // ========== Internal Tracking (Zero overhead when disabled) ==========

  /// Track SwiftValue creation (only called when enabled)
  /// Internal use only - called from SwiftValue constructor
  static void trackSwiftCreation(SwiftValue<dynamic> swift, String? name) {
    if (!_enabled || !_trackDependencies) return;
    
    final id = getSwiftId(swift);
    _swiftRegistry[id] = _SwiftInfo(
      id: id,
      name: name ?? swift.runtimeType.toString(),
      type: swift.runtimeType.toString(),
      createdAt: DateTime.now(),
    );
    
    // Store reference for state inspector
    _swiftRefs[id] = swift;
    
    _stateNodes[id] = _StateNode(
      id: id,
      type: 'SwiftValue',
      name: name ?? swift.runtimeType.toString(),
    );
  }

  /// Track Computed creation (only called when enabled)
  /// Internal use only - called from Computed constructor
  static void trackComputedCreation(Computed<dynamic> computed, String? name) {
    if (!_enabled || !_trackDependencies) return;
    
    final id = getComputedId(computed);
    _computedRegistry[id] = _ComputedInfo(
      id: id,
      name: name ?? computed.runtimeType.toString(),
      type: computed.runtimeType.toString(),
      createdAt: DateTime.now(),
    );
    
    // Store reference for state inspector
    _computedRefs[id] = computed;
    
    _stateNodes[id] = _StateNode(
      id: id,
      type: 'Computed',
      name: name ?? computed.runtimeType.toString(),
    );
  }

  /// Track Controller creation (only called when enabled)
  /// Internal use only - called from SwiftController constructor
  static void trackControllerCreation(dynamic controller) {
    if (!_enabled || !_trackDependencies) return;
    
    final id = getControllerId(controller);
    _controllerRegistry[id] = _ControllerInfo(
      id: id,
      name: controller.runtimeType.toString(),
      type: controller.runtimeType.toString(),
      createdAt: DateTime.now(),
    );
    
    // Store reference for state inspector
    _controllerRefs[id] = controller;
    
    _stateNodes[id] = _StateNode(
      id: id,
      type: 'Controller',
      name: controller.runtimeType.toString(),
    );
  }

  /// Track Controller disposal (only called when enabled)
  /// Internal use only - called from SwiftController dispose
  static void trackControllerDisposal(dynamic controller) {
    if (!_enabled || !_trackDependencies) return;
    
    final id = getControllerId(controller);
    _controllerRefs.remove(id);
    // Keep registry entry for history, but mark as disposed
    if (_controllerRegistry.containsKey(id)) {
      _controllerRegistry[id] = _ControllerInfo(
        id: id,
        name: _controllerRegistry[id]!.name,
        type: _controllerRegistry[id]!.type,
        createdAt: _controllerRegistry[id]!.createdAt,
        disposedAt: DateTime.now(),
      );
    }
  }

  /// Track dependency relationship (only called when enabled)
  /// Internal use only - called from Rx/Computed value getters
  static void trackDependency(String dependentId, String dependencyId) {
    if (!_enabled || !_trackDependencies) return;
    
    final edgeKey = '$dependentId->$dependencyId';
    if (!_dependencyGraph.containsKey(edgeKey)) {
      _dependencyGraph[edgeKey] = _DependencyEdge(
        from: dependentId,
        to: dependencyId,
        createdAt: DateTime.now(),
      );
    }
  }

  /// Track state change (only called when enabled)
  /// Internal use only - called from Rx value setter
  static void trackStateChange(String id, dynamic oldValue, dynamic newValue) {
    if (!_enabled || !_trackStateHistory) return;
    
    _stateHistory.add(_StateSnapshot(
      stateId: id,
      oldValue: oldValue,
      newValue: newValue,
      timestamp: DateTime.now(),
    ));
    
    _trimHistory();
  }

  /// Track performance event (only called when enabled)
  /// Internal use only - called from performance-critical paths
  static void trackPerformanceEvent(String name, Duration duration, Map<String, dynamic>? metadata) {
    if (!_enabled || !_trackPerformance) return;
    
    _performanceEvents.add(_PerformanceEvent(
      name: name,
      duration: duration,
      timestamp: DateTime.now(),
      metadata: metadata ?? {},
    ));
    
    _trimPerformanceEvents();
  }

  // ========== Public API for DevTools Extension ==========

  /// Get dependency graph as JSON
  static Map<String, dynamic> getDependencyGraph() {
    if (!_enabled) {
      return {'error': 'DevTools not enabled'};
    }

    return {
      'nodes': _stateNodes.values.map((n) => n.toJson()).toList(),
      'edges': _dependencyGraph.values.map((e) => e.toJson()).toList(),
      // ignore: deprecated_member_use_from_same_package
      'rxCount': _rxRegistry.length,
      'computedCount': _computedRegistry.length,
      'markCount': _markRegistry.length,
    };
  }

  /// Get state inspector data
  static Map<String, dynamic> getStateInspector() {
    if (!_enabled) {
      return {'error': 'DevTools not enabled'};
    }

    final allState = <String, dynamic>{};
    
    // Get all Rx states
    // ignore: deprecated_member_use_from_same_package
    for (final entry in _rxRegistry.entries) {
      try {
        // ignore: deprecated_member_use_from_same_package
        final rx = _getRxById(entry.key);
        if (rx != null) {
          allState[entry.key] = {
            'type': 'Rx',
            'name': entry.value.name,
            'value': _serializeValue(rx.rawValue),
            'createdAt': entry.value.createdAt.toIso8601String(),
            'id': entry.key,
          };
        } else {
          // Object was garbage collected
          allState[entry.key] = {
            'type': 'Rx',
            'name': entry.value.name,
            'value': '<disposed>',
            'status': 'disposed',
          };
        }
      } catch (e) {
        allState[entry.key] = {'error': e.toString()};
      }
    }
    
    // Get all Computed states
    for (final entry in _computedRegistry.entries) {
      try {
        final computed = _getComputedById(entry.key);
        if (computed != null) {
          allState[entry.key] = {
            'type': 'Computed',
            'name': entry.value.name,
            'value': _serializeValue(computed.value),
            'createdAt': entry.value.createdAt.toIso8601String(),
            'id': entry.key,
          };
        } else {
          allState[entry.key] = {
            'type': 'Computed',
            'name': entry.value.name,
            'value': '<disposed>',
            'status': 'disposed',
          };
        }
      } catch (e) {
        allState[entry.key] = {'error': e.toString()};
      }
    }
    
    // Get store states
    final storeStates = store.getAllStateKeys();
    for (final key in storeStates) {
      try {
        // ignore: deprecated_member_use_from_same_package
        final state = store.getState<Rx<dynamic>>(key);
        allState['store:$key'] = {
          'type': 'StoreState',
          'name': key,
          'value': _serializeValue(state.rawValue),
          'id': 'store:$key',
        };
      } catch (e) {
        allState['store:$key'] = {'error': e.toString()};
      }
    }
    
    // Get Redux stores
    for (final entry in _reduxStoreRefs.entries) {
      try {
        final reduxStore = entry.value;
        allState[entry.key] = {
          'type': 'ReduxStore',
          'name': _stateNodes[entry.key]?.name ?? 'ReduxStore',
          'value': _serializeValue(reduxStore.value),
          'actionHistoryCount': reduxStore.actionHistory.length,
          'id': entry.key,
        };
      } catch (e) {
        allState[entry.key] = {'error': e.toString()};
      }
    }

    return {
      'states': allState,
      'totalCount': allState.length,
      // ignore: deprecated_member_use_from_same_package
      'rxCount': _rxRegistry.length,
      'computedCount': _computedRegistry.length,
      'markCount': _markRegistry.length,
      'reduxStoreCount': _reduxStoreRefs.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get performance report
  static Map<String, dynamic> getPerformanceReport() {
    if (!_enabled || !_trackPerformance) {
      return {'error': 'Performance tracking not enabled'};
    }

    final report = PerformanceMonitor.getReport();
    
    // Add recent performance events
    final recentEvents = _performanceEvents.take(100).map((e) => e.toJson()).toList();
    
    return {
      ...report,
      'recentEvents': recentEvents,
      'totalEvents': _performanceEvents.length,
    };
  }

  /// Get state change history
  static List<Map<String, dynamic>> getStateHistory({int? limit}) {
    if (!_enabled || !_trackStateHistory) {
      return [];
    }

    final history = limit != null 
        ? _stateHistory.take(limit).toList()
        : _stateHistory;
    
    return history.map((s) => s.toJson()).toList();
  }

  /// Get time-travel debugging data (for ReduxStore)
  static Map<String, dynamic>? getTimeTravelData(String storeId) {
    if (!_enabled) {
      return {'error': 'DevTools not enabled'};
    }

    // Try to find ReduxStore by ID
    try {
      final reduxStore = _getStoreById(storeId);
      if (reduxStore != null && reduxStore is ReduxStore) {
        return {
          'currentState': _serializeValue(reduxStore.value),
          'actionHistory': reduxStore.actionHistory.map((a) => {
            'type': a.type,
            'payload': a.payload,
            'timestamp': DateTime.now().toIso8601String(),
          }).toList(),
          'canTimeTravel': true,
          'actionCount': reduxStore.actionHistory.length,
        };
      }
    } catch (e) {
      return {'error': e.toString()};
    }

    return {'error': 'ReduxStore not found with id: $storeId'};
  }
  
  /// Get all Redux stores
  static List<Map<String, dynamic>> getAllReduxStores() {
    if (!_enabled) {
      return [];
    }
    
    final stores = <Map<String, dynamic>>[];
    for (final entry in _reduxStoreRefs.entries) {
      try {
        final reduxStore = entry.value;
        stores.add({
          'id': entry.key,
          'name': _stateNodes[entry.key]?.name ?? 'ReduxStore',
          'currentState': _serializeValue(reduxStore.value),
          'actionCount': reduxStore.actionHistory.length,
        });
      } catch (e) {
        stores.add({
          'id': entry.key,
          'error': e.toString(),
        });
      }
    }
    return stores;
  }
  
  /// Get summary statistics
  static Map<String, dynamic> getSummary() {
    if (!_enabled) {
      return {'error': 'DevTools not enabled'};
    }
    
    return {
      'enabled': _enabled,
      'trackDependencies': _trackDependencies,
      'trackStateHistory': _trackStateHistory,
      'trackPerformance': _trackPerformance,
      // ignore: deprecated_member_use_from_same_package
      'rxCount': _rxRegistry.length,
      'computedCount': _computedRegistry.length,
      'markCount': _markRegistry.length,
      'reduxStoreCount': _reduxStoreRefs.length,
      'dependencyEdges': _dependencyGraph.length,
      'stateHistorySize': _stateHistory.length,
      'performanceEvents': _performanceEvents.length,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Clear all tracking data
  static void clear() {
    _clearAll();
  }

  // ========== Helper Methods ==========

  /// Get unique ID for Rx (internal use)
  static String getSwiftId(SwiftValue<dynamic> swift) => swift.hashCode.toString();
  
  // Backward compatibility
  @Deprecated('Use getSwiftId instead')
  // ignore: deprecated_member_use_from_same_package
  static String getRxId(Rx<dynamic> rx) => getSwiftId(rx);
  /// Get unique ID for Computed (internal use)
  static String getComputedId(Computed<dynamic> computed) => computed.hashCode.toString();
  /// Get unique ID for Mark (internal use)
  static String getMarkId(dynamic mark) => mark.hashCode.toString();
  /// Get unique ID for Controller (internal use)
  static String getControllerId(dynamic controller) => controller.hashCode.toString();

  static SwiftValue<dynamic>? _getSwiftById(String id) {
    return _swiftRefs[id];
  }
  
  // Backward compatibility
  @Deprecated('Use _getSwiftById instead')
  // ignore: deprecated_member_use_from_same_package
  static Rx<dynamic>? _getRxById(String id) => _getSwiftById(id);

  static Computed<dynamic>? _getComputedById(String id) {
    return _computedRefs[id];
  }

  static dynamic _getStoreById(String id) {
    return _reduxStoreRefs[id];
  }
  
  /// Register ReduxStore for time-travel debugging
  static void registerReduxStore(ReduxStore<dynamic> store, String? name) {
    if (!_enabled) return;
    final id = 'redux_${store.hashCode}';
    _reduxStoreRefs[id] = store;
    _stateNodes[id] = _StateNode(
      id: id,
      type: 'ReduxStore',
      name: name ?? store.runtimeType.toString(),
    );
  }

  static dynamic _serializeValue(dynamic value) {
    try {
      if (value == null) return null;
      if (value is num || value is bool || value is String) return value;
      if (value is List) return value.map((e) => _serializeValue(e)).toList();
      if (value is Map) {
        return value.map((k, v) => MapEntry(k.toString(), _serializeValue(v)));
      }
      return value.toString();
    } catch (e) {
      return '<serialization error: $e>';
    }
  }

  static void _trimHistory() {
    if (_stateHistory.length > _maxHistorySize) {
      _stateHistory.removeRange(0, _stateHistory.length - _maxHistorySize);
    }
  }

  static void _trimPerformanceEvents() {
    if (_performanceEvents.length > _maxPerformanceEvents) {
      _performanceEvents.removeRange(0, _performanceEvents.length - _maxPerformanceEvents);
    }
  }

  static void _clearAll() {
    _stateNodes.clear();
    _dependencyGraph.clear();
    _stateHistory.clear();
    _swiftRegistry.clear();
    _computedRegistry.clear();
    _markRegistry.clear();
    _performanceEvents.clear();
    _swiftRefs.clear();
    _computedRefs.clear();
    _reduxStoreRefs.clear();
    _controllerRefs.clear();
  }
}

// ========== Internal Data Structures ==========

class _StateNode {
  final String id;
  final String type;
  final String name;

  _StateNode({required this.id, required this.type, required this.name});

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'name': name,
  };
}

class _DependencyEdge {
  final String from;
  final String to;
  final DateTime createdAt;

  _DependencyEdge({
    required this.from,
    required this.to,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
    'from': from,
    'to': to,
    'createdAt': createdAt.toIso8601String(),
  };
}

class _StateSnapshot {
  final String stateId;
  final dynamic oldValue;
  final dynamic newValue;
  final DateTime timestamp;

  _StateSnapshot({
    required this.stateId,
    required this.oldValue,
    required this.newValue,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'stateId': stateId,
    'oldValue': _serializeValue(oldValue),
    'newValue': _serializeValue(newValue),
    'timestamp': timestamp.toIso8601String(),
  };

  static dynamic _serializeValue(dynamic value) {
    try {
      if (value == null) return null;
      if (value is num || value is bool || value is String) return value;
      return value.toString();
    } catch (e) {
      return '<error>';
    }
  }
}

class _PerformanceEvent {
  final String name;
  final Duration duration;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  _PerformanceEvent({
    required this.name,
    required this.duration,
    required this.timestamp,
    required this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'durationMs': duration.inMilliseconds,
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };
}

class _SwiftInfo {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  _SwiftInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });
}

// Backward compatibility
@Deprecated('Use _SwiftInfo instead')
class _RxInfo {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  _RxInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });
}

class _ComputedInfo {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;

  _ComputedInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
  });
}

class _MarkInfo {
  final String id;
  final String name;
  final DateTime createdAt;

  _MarkInfo({
    required this.id,
    required this.name,
    required this.createdAt,
  });
}

class _ControllerInfo {
  final String id;
  final String name;
  final String type;
  final DateTime createdAt;
  final DateTime? disposedAt;

  _ControllerInfo({
    required this.id,
    required this.name,
    required this.type,
    required this.createdAt,
    this.disposedAt,
  });
}

