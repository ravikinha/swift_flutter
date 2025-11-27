import 'rx.dart';
import 'transaction.dart';

/// Lazy reactive state that only loads when first accessed
class LazyRx<T> extends Rx<T> {
  final T Function() _loader;
  bool _loaded = false;
  bool _loading = false;

  /// Create a lazy Rx that loads value on first access
  LazyRx(this._loader, T initialValue) : super(initialValue);

  @override
  T get value {
    if (!_loaded && !_loading) {
      _loading = true;
      try {
        final loadedValue = _loader();
        super.value = loadedValue;
        _loaded = true;
        _loading = false;
      } catch (e) {
        _loading = false;
        rethrow;
      }
    }
    return super.value;
  }

  /// Force reload the value
  void reload() {
    _loaded = false;
    _loading = false;
    final loadedValue = _loader();
    super.value = loadedValue;
    _loaded = true;
    notifyListenersTransaction();
  }

  /// Check if value has been loaded
  bool get isLoaded => _loaded;

  /// Check if value is currently loading
  bool get isLoading => _loading;

  /// Reset to unloaded state (value will be reloaded on next access)
  void reset() {
    _loaded = false;
    _loading = false;
  }
}

