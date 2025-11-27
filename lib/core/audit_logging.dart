import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'persistence.dart' show StorageBackend;
import 'encryption.dart';

/// Audit event type
enum AuditEventType {
  stateChange,
  actionDispatched,
  userLogin,
  userLogout,
  dataAccess,
  dataModification,
  securityEvent,
  custom,
}

/// Audit event
class AuditEvent {
  final String id;
  final AuditEventType type;
  final String? stateKey;
  final dynamic oldValue;
  final dynamic newValue;
  final String? userId;
  final String? userEmail;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;
  final String? previousHash;
  final String? hash;

  AuditEvent({
    String? id,
    required this.type,
    this.stateKey,
    this.oldValue,
    this.newValue,
    this.userId,
    this.userEmail,
    DateTime? timestamp,
    this.metadata,
    this.previousHash,
    this.hash,
  })  : id = id ?? _generateId(),
        timestamp = timestamp ?? DateTime.now();

  static String _generateId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().microsecondsSinceEpoch % 1000}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        if (stateKey != null) 'stateKey': stateKey,
        if (oldValue != null) 'oldValue': _serializeValue(oldValue),
        if (newValue != null) 'newValue': _serializeValue(newValue),
        if (userId != null) 'userId': userId,
        if (userEmail != null) 'userEmail': userEmail,
        'timestamp': timestamp.toIso8601String(),
        if (metadata != null) 'metadata': metadata,
        if (previousHash != null) 'previousHash': previousHash,
        if (hash != null) 'hash': hash,
      };

  factory AuditEvent.fromJson(Map<String, dynamic> json) {
    return AuditEvent(
      id: json['id'] as String,
      type: AuditEventType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => AuditEventType.custom,
      ),
      stateKey: json['stateKey'] as String?,
      oldValue: json['oldValue'],
      newValue: json['newValue'],
      userId: json['userId'] as String?,
      userEmail: json['userEmail'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      metadata: json['metadata'] as Map<String, dynamic>?,
      previousHash: json['previousHash'] as String?,
      hash: json['hash'] as String?,
    );
  }

  static dynamic _serializeValue(dynamic value) {
    if (value == null) return null;
    if (value is String || value is num || value is bool) return value;
    if (value is List || value is Map) return value;
    return value.toString();
  }

  @override
  String toString() => 'AuditEvent(${type.name}: $stateKey)';
}

/// Audit logger configuration
class AuditLoggerConfig {
  /// Enable audit logging
  final bool enabled;

  /// Enable tamper-proof hashing
  final bool enableTamperProof;

  /// Enable encryption for audit logs
  final bool enableEncryption;

  /// Encryption provider
  final EncryptionProvider? encryptionProvider;

  /// Encryption key
  final String? encryptionKey;

  /// Storage for audit logs
  final StorageBackend? storage;

  /// Max events in memory
  final int maxEventsInMemory;

  /// Auto-persist interval (null = manual only)
  final Duration? autoPersistInterval;

  /// Event filter (return true to log, false to skip)
  final bool Function(AuditEvent event)? eventFilter;

  const AuditLoggerConfig({
    this.enabled = true,
    this.enableTamperProof = true,
    this.enableEncryption = false,
    this.encryptionProvider,
    this.encryptionKey,
    this.storage,
    this.maxEventsInMemory = 1000,
    this.autoPersistInterval,
    this.eventFilter,
  });
}

/// Central audit logging system
class AuditLogger {
  static AuditLoggerConfig _config = const AuditLoggerConfig();
  static final List<AuditEvent> _events = [];
  static String? _lastHash;
  static DateTime? _lastPersist;

  /// Configure audit logger
  static void configure(AuditLoggerConfig config) {
    _config = config;

    // Set up auto-persist timer if configured
    if (config.autoPersistInterval != null) {
      _startAutoPersist();
    }
  }

  /// Log state change
  static Future<void> logStateChange({
    required String stateKey,
    required dynamic oldValue,
    required dynamic newValue,
    String? userId,
    String? userEmail,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.stateChange,
      stateKey: stateKey,
      oldValue: oldValue,
      newValue: newValue,
      userId: userId,
      userEmail: userEmail,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log action dispatched
  static Future<void> logAction({
    required String actionType,
    String? userId,
    Map<String, dynamic>? payload,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.actionDispatched,
      stateKey: actionType,
      newValue: payload,
      userId: userId,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log user login
  static Future<void> logLogin({
    required String userId,
    String? userEmail,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.userLogin,
      userId: userId,
      userEmail: userEmail,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log user logout
  static Future<void> logLogout({
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.userLogout,
      userId: userId,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log data access
  static Future<void> logDataAccess({
    required String resourceKey,
    required String userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.dataAccess,
      stateKey: resourceKey,
      userId: userId,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log security event
  static Future<void> logSecurityEvent({
    required String eventDescription,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.securityEvent,
      stateKey: eventDescription,
      userId: userId,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Log custom event
  static Future<void> logCustom({
    required String eventKey,
    dynamic data,
    String? userId,
    Map<String, dynamic>? metadata,
  }) async {
    if (!_config.enabled) return;

    final event = AuditEvent(
      type: AuditEventType.custom,
      stateKey: eventKey,
      newValue: data,
      userId: userId,
      metadata: metadata,
    );

    await _logEvent(event);
  }

  /// Internal log event method
  static Future<void> _logEvent(AuditEvent event) async {
    // Apply event filter if configured
    if (_config.eventFilter != null && !_config.eventFilter!(event)) {
      return;
    }

    // Compute tamper-proof hash if enabled
    String? hash;
    if (_config.enableTamperProof) {
      hash = _computeHash(event);
    }

    final eventWithHash = AuditEvent(
      id: event.id,
      type: event.type,
      stateKey: event.stateKey,
      oldValue: event.oldValue,
      newValue: event.newValue,
      userId: event.userId,
      userEmail: event.userEmail,
      timestamp: event.timestamp,
      metadata: event.metadata,
      previousHash: _lastHash,
      hash: hash,
    );

    _events.add(eventWithHash);
    _lastHash = hash;

    // Trim events if exceeds max
    if (_events.length > _config.maxEventsInMemory) {
      _events.removeAt(0);
    }

    // Auto-persist if needed
    if (_config.storage != null && _config.autoPersistInterval == null) {
      await _persistEvents();
    }
  }

  /// Compute tamper-proof hash (blockchain-style)
  static String _computeHash(AuditEvent event) {
    final data = '${_lastHash ?? ''}|${event.id}|${event.type.name}|'
        '${event.stateKey}|${event.timestamp.toIso8601String()}';

    // Simple hash (in production, use crypto package for SHA-256)
    var hash = 0;
    for (var i = 0; i < data.length; i++) {
      hash = ((hash << 5) - hash) + data.codeUnitAt(i);
      hash = hash & hash;
    }
    return hash.abs().toRadixString(16).padLeft(16, '0');
  }

  /// Persist events to storage
  static Future<void> _persistEvents() async {
    if (_config.storage == null) return;

    try {
      final json = jsonEncode(_events.map((e) => e.toJson()).toList());

      String data = json;
      if (_config.enableEncryption &&
          _config.encryptionProvider != null &&
          _config.encryptionKey != null) {
        data = await _config.encryptionProvider!.encrypt(
          json,
          key: _config.encryptionKey,
        );
      }

      await _config.storage!.save('audit_log', data);
      _lastPersist = DateTime.now();
    } catch (e) {
      debugPrint('Error persisting audit logs: $e');
    }
  }

  /// Load events from storage
  static Future<void> loadEvents() async {
    if (_config.storage == null) return;

    try {
      var data = await _config.storage!.load('audit_log');
      if (data == null) return;

      if (_config.enableEncryption &&
          _config.encryptionProvider != null &&
          _config.encryptionKey != null) {
        data = await _config.encryptionProvider!.decrypt(
          data,
          key: _config.encryptionKey,
        );
      }

      final List<dynamic> jsonList = jsonDecode(data);
      _events.clear();
      _events.addAll(jsonList.map((json) => AuditEvent.fromJson(json)));

      if (_events.isNotEmpty) {
        _lastHash = _events.last.hash;
      }
    } catch (e) {
      debugPrint('Error loading audit logs: $e');
    }
  }

  /// Export audit logs
  static Future<String> exportLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    AuditEventType? eventType,
  }) async {
    var filtered = _events.where((event) {
      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }
      if (userId != null && event.userId != userId) {
        return false;
      }
      if (eventType != null && event.type != eventType) {
        return false;
      }
      return true;
    });

    return jsonEncode(filtered.map((e) => e.toJson()).toList());
  }

  /// Verify audit log integrity
  static bool verifyIntegrity() {
    if (!_config.enableTamperProof) return true;

    String? expectedHash;
    for (final event in _events) {
      if (event.previousHash != expectedHash) {
        debugPrint('Integrity check failed at event ${event.id}');
        return false;
      }
      expectedHash = event.hash;
    }

    return true;
  }

  /// Get audit events
  static List<AuditEvent> getEvents({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    AuditEventType? eventType,
  }) {
    return _events.where((event) {
      if (startDate != null && event.timestamp.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && event.timestamp.isAfter(endDate)) {
        return false;
      }
      if (userId != null && event.userId != userId) {
        return false;
      }
      if (eventType != null && event.type != eventType) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Get event count
  static int getEventCount() => _events.length;

  /// Clear events (use with caution!)
  static void clearEvents() {
    _events.clear();
    _lastHash = null;
  }

  /// Start auto-persist timer
  static void _startAutoPersist() {
    // Note: In production, use a proper timer
    // This is a simplified implementation
    Future.delayed(_config.autoPersistInterval!, () async {
      await _persistEvents();
      if (_config.autoPersistInterval != null) {
        _startAutoPersist();
      }
    });
  }

  /// Get last persist time
  static DateTime? getLastPersistTime() => _lastPersist;
}

