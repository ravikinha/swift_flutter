import 'package:flutter/widgets.dart';

/// Lifecycle states
enum LifecycleState {
  initializing,
  initialized,
  active,
  inactive,
  paused,
  resumed,
  disposing,
  disposed,
}

/// Lifecycle controller for managing widget/component lifecycle
class LifecycleController extends ChangeNotifier {
  LifecycleState _state = LifecycleState.initializing;
  final Map<String, dynamic> _data = {};

  LifecycleState get state => _state;

  bool get isInitialized => _state != LifecycleState.initializing;
  bool get isActive => _state == LifecycleState.active;
  bool get isDisposed => _state == LifecycleState.disposed;

  /// Initialize the lifecycle
  void initialize() {
    if (_state == LifecycleState.initializing) {
      _state = LifecycleState.initialized;
      notifyListeners();
    }
  }

  /// Activate the lifecycle
  void activate() {
    if (_state != LifecycleState.active && _state != LifecycleState.disposed) {
      _state = LifecycleState.active;
      notifyListeners();
    }
  }

  /// Deactivate the lifecycle
  void deactivate() {
    if (_state == LifecycleState.active) {
      _state = LifecycleState.inactive;
      notifyListeners();
    }
  }

  /// Pause the lifecycle
  void pause() {
    if (_state != LifecycleState.paused && _state != LifecycleState.disposed) {
      _state = LifecycleState.paused;
      notifyListeners();
    }
  }

  /// Resume the lifecycle
  void resume() {
    if (_state == LifecycleState.paused) {
      _state = LifecycleState.resumed;
      notifyListeners();
    }
  }

  /// Start disposing
  void startDisposing() {
    if (_state != LifecycleState.disposed) {
      _state = LifecycleState.disposing;
      notifyListeners();
    }
  }

  /// Complete disposal
  @override
  void dispose() {
    if (_state != LifecycleState.disposed) {
      _state = LifecycleState.disposed;
      _data.clear();
      notifyListeners();
      super.dispose();
    }
  }

  /// Store data in lifecycle context
  void setData(String key, dynamic value) {
    _data[key] = value;
  }

  /// Get data from lifecycle context
  T? getData<T>(String key) {
    return _data[key] as T?;
  }

  /// Remove data from lifecycle context
  void removeData(String key) {
    _data.remove(key);
  }
}

/// Widget mixin for lifecycle management
mixin LifecycleMixin<T extends StatefulWidget> on State<T> {
  late final LifecycleController lifecycle;

  @override
  void initState() {
    super.initState();
    lifecycle = LifecycleController();
    lifecycle.initialize();
    lifecycle.activate();
  }

  @override
  void activate() {
    super.activate();
    lifecycle.activate();
  }

  @override
  void deactivate() {
    lifecycle.deactivate();
    super.deactivate();
  }

  @override
  void dispose() {
    lifecycle.startDisposing();
    lifecycle.dispose();
    super.dispose();
  }
}

