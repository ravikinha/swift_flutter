import '../core/rx.dart';
import 'middleware.dart';

/// Global store for dependency injection and state management
class Store {
  final Map<Type, dynamic> _services = {};
  final Map<String, Rx<dynamic>> _state = {};
  final List<Middleware> _middlewares = [];

  /// Register a service/controller
  void register<T>(T service) {
    _services[T] = service;
  }

  /// Get a registered service
  T get<T>() {
    final service = _services[T];
    if (service == null) {
      throw StateError('Service of type $T not found. Register it first using store.register<T>(instance)');
    }
    return service as T;
  }

  /// Check if a service is registered
  bool has<T>() => _services.containsKey(T);

  /// Unregister a service
  void unregister<T>() {
    _services.remove(T);
  }

  /// Register state
  void registerState<T>(String key, Rx<T> state) {
    _state[key] = state;
  }

  /// Register state with namespace
  void registerStateWithNamespace<T>(String namespace, String key, Rx<T> state) {
    _state['$namespace:$key'] = state;
  }

  /// Get state
  Rx<T> getState<T>(String key) {
    final state = _state[key];
    if (state == null) {
      throw StateError('State with key "$key" not found');
    }
    return state as Rx<T>;
  }

  /// Get state with namespace
  Rx<T> getStateWithNamespace<T>(String namespace, String key) {
    final state = _state['$namespace:$key'];
    if (state == null) {
      throw StateError('State with namespace "$namespace" and key "$key" not found');
    }
    return state as Rx<T>;
  }

  /// Check if state exists
  bool hasState(String key) => _state.containsKey(key);

  /// Check if state exists with namespace
  bool hasStateWithNamespace(String namespace, String key) => 
      _state.containsKey('$namespace:$key');

  /// Add middleware
  void addMiddleware(Middleware middleware) {
    _middlewares.add(middleware);
  }

  /// Remove middleware
  void removeMiddleware(Middleware middleware) {
    _middlewares.remove(middleware);
  }

  /// Execute action through middleware chain
  Future<T> dispatch<T>(Action action) async {
    Action currentAction = action;
    
    // Execute before middleware
    for (final middleware in _middlewares) {
      currentAction = await middleware.before(currentAction) ?? currentAction;
    }

    // Execute action
    T result;
    try {
      result = await currentAction.execute() as T;
    } catch (e, stackTrace) {
      // Execute error middleware
      for (final middleware in _middlewares) {
        await middleware.onError(e, stackTrace, currentAction);
      }
      rethrow;
    }

    // Execute after middleware
    for (final middleware in _middlewares) {
      await middleware.after(currentAction, result);
    }

    return result;
  }

  /// Clear all registered services and state
  void clear() {
    _services.clear();
    for (final state in _state.values) {
      state.dispose();
    }
    _state.clear();
  }

  /// Cleanup state by namespace
  void cleanupNamespace(String namespace) {
    final keysToRemove = _state.keys
        .where((key) => key.startsWith('$namespace:'))
        .toList();
    
    for (final key in keysToRemove) {
      _state[key]?.dispose();
      _state.remove(key);
    }
  }

  /// Cleanup unused state (removes all state - use with caution)
  /// Note: This removes all state regardless of listeners since hasListeners
  /// is not accessible from outside ChangeNotifier
  void cleanupUnused() {
    // Note: We can't check hasListeners from outside, so this clears all state
    // Use cleanupNamespace for more targeted cleanup
    final keysToRemove = _state.keys.toList();
    
    for (final key in keysToRemove) {
      _state[key]?.dispose();
      _state.remove(key);
    }
  }

  /// Get list of all state keys
  /// Note: Cannot determine unused state without access to hasListeners
  List<String> getUnusedStateKeys() {
    // Return empty list since we can't check listeners
    // Users should track state usage manually if needed
    return [];
  }

  /// Get all state keys
  List<String> getAllStateKeys() {
    return _state.keys.toList();
  }

  /// Get all state keys for a namespace
  List<String> getStateKeysForNamespace(String namespace) {
    return _state.keys
        .where((key) => key.startsWith('$namespace:'))
        .map((key) => key.substring(namespace.length + 1))
        .toList();
  }
}

/// Global store instance
final store = Store();

