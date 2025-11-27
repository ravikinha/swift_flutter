import 'package:flutter/foundation.dart';
import '../store/store.dart';
import '../store/middleware.dart';
import 'rx.dart';

/// Tenant context
class TenantContext {
  final String tenantId;
  final String name;
  final Map<String, dynamic> config;
  final DateTime createdAt;

  TenantContext({
    required this.tenantId,
    required this.name,
    Map<String, dynamic>? config,
    DateTime? createdAt,
  })  : config = config ?? {},
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'tenantId': tenantId,
        'name': name,
        'config': config,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TenantContext.fromJson(Map<String, dynamic> json) {
    return TenantContext(
      tenantId: json['tenantId'] as String,
      name: json['name'] as String,
      config: json['config'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}

/// Multi-tenant store with isolated state per tenant
class TenantAwareStore {
  final Map<String, Store> _tenantStores = {};
  final Map<String, TenantContext> _tenantContexts = {};
  String? _currentTenantId;
  final List<Middleware> _globalMiddlewares = [];

  /// Get current tenant ID
  String? get currentTenantId => _currentTenantId;

  /// Get current tenant context
  TenantContext? get currentContext =>
      _currentTenantId != null ? _tenantContexts[_currentTenantId] : null;

  /// Set current tenant
  void setTenant(String tenantId, {TenantContext? context}) {
    _currentTenantId = tenantId;

    if (!_tenantStores.containsKey(tenantId)) {
      _tenantStores[tenantId] = Store();

      // Apply global middlewares to new tenant store
      for (final middleware in _globalMiddlewares) {
        _tenantStores[tenantId]!.addMiddleware(middleware);
      }
    }

    if (context != null) {
      _tenantContexts[tenantId] = context;
    } else if (!_tenantContexts.containsKey(tenantId)) {
      _tenantContexts[tenantId] = TenantContext(
        tenantId: tenantId,
        name: tenantId,
      );
    }
  }

  /// Clear current tenant
  void clearCurrentTenant() {
    _currentTenantId = null;
  }

  /// Register service for current tenant
  void register<T>(T service) {
    _ensureTenantSet();
    _tenantStores[_currentTenantId]!.register<T>(service);
  }

  /// Get service for current tenant
  T get<T>() {
    _ensureTenantSet();
    return _tenantStores[_currentTenantId]!.get<T>();
  }

  /// Check if service exists for current tenant
  bool has<T>() {
    _ensureTenantSet();
    return _tenantStores[_currentTenantId]!.has<T>();
  }

  /// Unregister service for current tenant
  void unregister<T>() {
    _ensureTenantSet();
    _tenantStores[_currentTenantId]!.unregister<T>();
  }

  /// Register state for current tenant
  void registerState<T>(String key, Rx<T> state) {
    _ensureTenantSet();
    _tenantStores[_currentTenantId]!.registerState(key, state);
  }

  /// Get state for current tenant
  Rx<T> getState<T>(String key) {
    _ensureTenantSet();
    return _tenantStores[_currentTenantId]!.getState<T>(key);
  }

  /// Check if state exists for current tenant
  bool hasState(String key) {
    _ensureTenantSet();
    return _tenantStores[_currentTenantId]!.hasState(key);
  }

  /// Add middleware to current tenant
  void addMiddleware(Middleware middleware) {
    _ensureTenantSet();
    _tenantStores[_currentTenantId]!.addMiddleware(middleware);
  }

  /// Add global middleware (applied to all tenants)
  void addGlobalMiddleware(Middleware middleware) {
    _globalMiddlewares.add(middleware);
    // Apply to all existing tenant stores
    for (final store in _tenantStores.values) {
      store.addMiddleware(middleware);
    }
  }

  /// Dispatch action for current tenant
  Future<T> dispatch<T>(Action action) {
    _ensureTenantSet();
    return _tenantStores[_currentTenantId]!.dispatch<T>(action);
  }

  /// Clear tenant data
  void clearTenant(String tenantId) {
    _tenantStores[tenantId]?.clear();
    _tenantStores.remove(tenantId);
    _tenantContexts.remove(tenantId);

    if (_currentTenantId == tenantId) {
      _currentTenantId = null;
    }
  }

  /// Clear all tenants
  void clearAll() {
    for (final store in _tenantStores.values) {
      store.clear();
    }
    _tenantStores.clear();
    _tenantContexts.clear();
    _currentTenantId = null;
  }

  /// Get all tenant IDs
  List<String> getAllTenantIds() {
    return _tenantStores.keys.toList();
  }

  /// Get tenant context
  TenantContext? getTenantContext(String tenantId) {
    return _tenantContexts[tenantId];
  }

  /// Update tenant context
  void updateTenantContext(String tenantId, TenantContext context) {
    _tenantContexts[tenantId] = context;
  }

  /// Check if tenant exists
  bool hasTenant(String tenantId) {
    return _tenantStores.containsKey(tenantId);
  }

  /// Get tenant count
  int getTenantCount() {
    return _tenantStores.length;
  }

  void _ensureTenantSet() {
    if (_currentTenantId == null) {
      throw StateError(
        'No tenant context set. Call setTenant() before accessing tenant-specific data.',
      );
    }
  }
}

/// Global tenant-aware store instance
final tenantStore = TenantAwareStore();

/// Tenant isolation middleware
class TenantIsolationMiddleware extends Middleware {
  final String Function() getTenantId;

  TenantIsolationMiddleware({required this.getTenantId});

  @override
  Future<Action?> before(Action action) async {
    final tenantId = getTenantId();
    if (tenantId.isEmpty) {
      throw StateError('Tenant ID is required for this action');
    }
    return action;
  }

  @override
  Future<void> after(Action action, dynamic result) async {
    // Log tenant action if needed
    if (kDebugMode) {
      debugPrint('Tenant ${getTenantId()}: Action ${action.runtimeType} completed');
    }
  }
}

/// Tenant-scoped reactive state
class TenantScopedRx<T> {
  final Map<String, Rx<T>> _tenantStates = {};
  final T Function() _initialValueFactory;

  TenantScopedRx(this._initialValueFactory);

  /// Get state for current tenant
  Rx<T> getForTenant(String tenantId) {
    if (!_tenantStates.containsKey(tenantId)) {
      _tenantStates[tenantId] = Rx<T>(_initialValueFactory());
    }
    return _tenantStates[tenantId]!;
  }

  /// Get state for current tenant (from tenant store)
  Rx<T> get current {
    final tenantId = tenantStore.currentTenantId;
    if (tenantId == null) {
      throw StateError('No tenant context set');
    }
    return getForTenant(tenantId);
  }

  /// Clear tenant state
  void clearTenant(String tenantId) {
    _tenantStates[tenantId]?.dispose();
    _tenantStates.remove(tenantId);
  }

  /// Clear all tenant states
  void clearAll() {
    for (final state in _tenantStates.values) {
      state.dispose();
    }
    _tenantStates.clear();
  }

  /// Get all tenant IDs with state
  List<String> getTenantIds() {
    return _tenantStates.keys.toList();
  }
}

/// Tenant configuration helper
class TenantConfig {
  /// Create tenant context from config
  static TenantContext create({
    required String tenantId,
    required String name,
    Map<String, dynamic>? config,
  }) {
    return TenantContext(
      tenantId: tenantId,
      name: name,
      config: config,
    );
  }

  /// Get config value for current tenant
  static T? get<T>(String key, {T? defaultValue}) {
    final context = tenantStore.currentContext;
    if (context == null) return defaultValue;

    final value = context.config[key];
    return value is T ? value : defaultValue;
  }

  /// Set config value for current tenant
  static void set(String key, dynamic value) {
    final context = tenantStore.currentContext;
    if (context == null) {
      throw StateError('No tenant context set');
    }

    context.config[key] = value;
  }

  /// Check if config key exists
  static bool has(String key) {
    final context = tenantStore.currentContext;
    return context?.config.containsKey(key) ?? false;
  }
}

