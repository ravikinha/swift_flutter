import 'dart:async';
import 'rx.dart';

/// WebSocket event types
enum WebSocketEventType {
  connect,
  disconnect,
  messageSent,
  messageReceived,
  error,
}

/// WebSocket event model
class WebSocketEvent {
  final String id;
  final String connectionId;
  final WebSocketEventType type;
  final dynamic data;
  final DateTime timestamp;
  final String? error;

  WebSocketEvent({
    required this.id,
    required this.connectionId,
    required this.type,
    this.data,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'connectionId': connectionId,
    'type': type.toString(),
    'data': data?.toString(),
    'timestamp': timestamp.toIso8601String(),
    'error': error,
  };
}

/// WebSocket connection model
class WebSocketConnection {
  final String id;
  final String url;
  final Map<String, String> headers;
  final DateTime connectedAt;
  DateTime? disconnectedAt;
  final List<WebSocketEvent> events = [];
  bool isConnected = false;

  WebSocketConnection({
    required this.id,
    required this.url,
    required this.headers,
    required this.connectedAt,
  });

  void addEvent(WebSocketEvent event) {
    events.add(event);
    if (event.type == WebSocketEventType.connect) {
      isConnected = true;
    } else if (event.type == WebSocketEventType.disconnect) {
      isConnected = false;
      disconnectedAt = event.timestamp;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'headers': headers,
    'connectedAt': connectedAt.toIso8601String(),
    'disconnectedAt': disconnectedAt?.toIso8601String(),
    'isConnected': isConnected,
    'eventCount': events.length,
  };
}

/// WebSocket interceptor to capture WebSocket connections and events
class WebSocketInterceptor {
  static bool _enabled = false;
  // Use SwiftValue for reactive state - automatically notifies UI of changes
  static final _connections = swift<Map<String, WebSocketConnection>>({});
  static final _allEvents = swift<List<WebSocketEvent>>([]);
  static int _maxConnections = 50;
  static int _maxEventsPerConnection = 100;
  
  /// Get update trigger for reactive UI updates (accesses the reactive connections)
  static SwiftValue<Map<String, WebSocketConnection>> get updateTrigger => _connections;

  /// Enable WebSocket interception
  /// Preserves existing connections and events across hot reloads
  static void enable({int maxConnections = 50, int maxEventsPerConnection = 100}) {
    // Don't clear data if already enabled (preserves data across hot reloads)
    if (_enabled) {
      _maxConnections = maxConnections;
      _maxEventsPerConnection = maxEventsPerConnection;
      return;
    }
    _enabled = true;
    _maxConnections = maxConnections;
    _maxEventsPerConnection = maxEventsPerConnection;
    // Note: _connections and _allEvents preserve their data across hot reloads
    // because static variables persist unless explicitly cleared
  }

  /// Disable WebSocket interception
  static void disable() {
    _enabled = false;
    clear();
  }

  /// Check if interception is enabled
  static bool get isEnabled => _enabled;

  /// Capture WebSocket connection
  static String captureConnection({
    required String url,
    Map<String, String>? headers,
  }) {
    if (!_enabled) return '';
    
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final connection = WebSocketConnection(
      id: id,
      url: url,
      headers: headers ?? {},
      connectedAt: DateTime.now(),
    );
    
    final currentConnections = Map<String, WebSocketConnection>.from(_connections.value);
    currentConnections[id] = connection;
    _trimConnectionsMap(currentConnections);
    // Defer update to avoid setState during build phase
    Future.microtask(() {
      _connections.value = currentConnections;
    });
    
    // Capture connect event
    captureEvent(
      connectionId: id,
      type: WebSocketEventType.connect,
    );
    
    return id;
  }

  /// Capture WebSocket event
  static void captureEvent({
    required String connectionId,
    required WebSocketEventType type,
    dynamic data,
    String? error,
  }) {
    if (!_enabled) return;
    
    final event = WebSocketEvent(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      connectionId: connectionId,
      type: type,
      data: data,
      timestamp: DateTime.now(),
      error: error,
    );
    
    final currentEvents = List<WebSocketEvent>.from(_allEvents.value);
    currentEvents.add(event);
    _trimAllEventsList(currentEvents);
    // Defer update to avoid setState during build phase
    Future.microtask(() {
      _allEvents.value = currentEvents;
    });
    
    final currentConnections = Map<String, WebSocketConnection>.from(_connections.value);
    final connection = currentConnections[connectionId];
    if (connection != null) {
      connection.addEvent(event);
      _trimConnectionEvents(connection);
      // Defer update to avoid setState during build phase
      Future.microtask(() {
        _connections.value = currentConnections;
      });
    }
  }

  /// Get all connections
  static List<WebSocketConnection> getConnections() {
    return List.unmodifiable(_connections.value.values.toList());
  }

  /// Get a specific connection by ID
  static WebSocketConnection? getConnection(String id) {
    return _connections.value[id];
  }

  /// Get all events
  static List<WebSocketEvent> getAllEvents() {
    return List.unmodifiable(_allEvents.value);
  }

  /// Get events for a specific connection
  static List<WebSocketEvent> getConnectionEvents(String connectionId) {
    final connection = _connections.value[connectionId];
    return connection != null 
        ? List.unmodifiable(connection.events)
        : [];
  }

  /// Clear all connections and events
  static void clear() {
    // Defer update to avoid setState during build phase
    Future.microtask(() {
      _connections.value = {};
      _allEvents.value = [];
    });
  }
  
  static void _trimConnectionsMap(Map<String, WebSocketConnection> connections) {
    if (connections.length > _maxConnections) {
      final keysToRemove = connections.keys
          .take(connections.length - _maxConnections)
          .toList();
      for (final key in keysToRemove) {
        connections.remove(key);
      }
    }
  }

  static void _trimConnectionEvents(WebSocketConnection connection) {
    if (connection.events.length > _maxEventsPerConnection) {
      connection.events.removeRange(
        0,
        connection.events.length - _maxEventsPerConnection,
      );
    }
  }

  static void _trimAllEventsList(List<WebSocketEvent> events) {
    if (events.length > _maxEventsPerConnection * _maxConnections) {
      events.removeRange(
        0,
        events.length - (_maxEventsPerConnection * _maxConnections),
      );
    }
  }
}

/// Helper class to create intercepted WebSocket connections
/// 
/// Usage:
/// ```dart
/// final ws = SwiftWebSocket.connect('wss://example.com/ws');
/// ws.stream.listen((message) {
///   // Handle message
/// });
/// ws.sink.add('Hello');
/// ```
class SwiftWebSocket {
  final String url;
  final Map<String, String>? headers;
  StreamController<dynamic>? _controller;
  String? _connectionId;
  bool _isConnected = false;

  SwiftWebSocket._(this.url, this.headers);

  /// Connect to a WebSocket
  static Future<SwiftWebSocket> connect(
    String url, {
    Map<String, String>? headers,
  }) async {
    final ws = SwiftWebSocket._(url, headers);
    await ws._connect();
    return ws;
  }

  Future<void> _connect() async {
    if (WebSocketInterceptor.isEnabled) {
      _connectionId = WebSocketInterceptor.captureConnection(
        url: url,
        headers: headers ?? {},
      );
    }

    try {
      // Note: This is a placeholder - actual WebSocket implementation
      // would use web_socket_channel or dart:io WebSocket
      // For now, we just track the connection attempt
      _isConnected = true;
      
      if (WebSocketInterceptor.isEnabled && _connectionId != null) {
        WebSocketInterceptor.captureEvent(
          connectionId: _connectionId!,
          type: WebSocketEventType.connect,
        );
      }
    } catch (e) {
      if (WebSocketInterceptor.isEnabled && _connectionId != null) {
        WebSocketInterceptor.captureEvent(
          connectionId: _connectionId!,
          type: WebSocketEventType.error,
          error: e.toString(),
        );
      }
      rethrow;
    }
  }

  /// Send a message
  void send(dynamic message) {
    if (!_isConnected) {
      throw StateError('WebSocket is not connected');
    }

    if (WebSocketInterceptor.isEnabled && _connectionId != null) {
      WebSocketInterceptor.captureEvent(
        connectionId: _connectionId!,
        type: WebSocketEventType.messageSent,
        data: message,
      );
    }
  }

  /// Close the connection
  void close() {
    if (_isConnected && WebSocketInterceptor.isEnabled && _connectionId != null) {
      WebSocketInterceptor.captureEvent(
        connectionId: _connectionId!,
        type: WebSocketEventType.disconnect,
      );
    }
    _isConnected = false;
  }

  /// Stream of received messages
  Stream<dynamic> get stream {
    _controller ??= StreamController<dynamic>.broadcast();
    return _controller!.stream;
  }

  /// Sink for sending messages
  StreamSink<dynamic> get sink {
    _controller ??= StreamController<dynamic>.broadcast();
    return _controller!.sink;
  }
}

