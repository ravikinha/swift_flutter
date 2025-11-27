import 'rx.dart';

/// Scoped state management for isolating state per feature/module
class SwiftScope {
  final String id;
  final Map<String, Rx<dynamic>> _state = {};
  bool _disposed = false;

  /// Create a new scope with an identifier
  SwiftScope({required this.id});

  /// Get state from this scope
  Rx<T> getState<T>(String key) {
    if (_disposed) {
      throw StateError('Scope "$id" has been disposed');
    }
    final state = _state[key];
    if (state == null) {
      throw StateError('State with key "$key" not found in scope "$id"');
    }
    return state as Rx<T>;
  }

  /// Register state in this scope
  void registerState<T>(String key, Rx<T> state) {
    if (_disposed) {
      throw StateError('Cannot register state in disposed scope "$id"');
    }
    _state[key] = state;
  }

  /// Check if state exists in this scope
  bool hasState(String key) => _state.containsKey(key);

  /// Get all state keys in this scope
  List<String> getStateKeys() => _state.keys.toList();

  /// Remove state from this scope (without disposing)
  void removeState(String key) {
    _state.remove(key);
  }

  /// Dispose all state in this scope
  void dispose() {
    if (_disposed) return;
    
    for (var state in _state.values) {
      state.dispose();
    }
    _state.clear();
    _disposed = true;
  }

  /// Check if scope is disposed
  bool get isDisposed => _disposed;

  @override
  String toString() => 'SwiftScope(id: $id, states: ${_state.keys.length})';
}

