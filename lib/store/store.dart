import 'package:flutter/foundation.dart';
import '../core/rx.dart';
import 'middleware.dart';

/// Global store for dependency injection and state management
class Store {
  static final Store _instance = Store._internal();
  factory Store() => _instance;
  Store._internal();

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

  /// Get state
  Rx<T> getState<T>(String key) {
    final state = _state[key];
    if (state == null) {
      throw StateError('State with key "$key" not found');
    }
    return state as Rx<T>;
  }

  /// Check if state exists
  bool hasState(String key) => _state.containsKey(key);

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
}

/// Global store instance
final store = Store();

