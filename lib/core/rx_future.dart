import 'package:flutter/foundation.dart';
import 'rx.dart';
import '../ui/mark.dart';

/// Represents the state of an async operation
enum AsyncState { idle, loading, success, error }

/// Wrapper for async values with loading/error states
class AsyncValue<T> {
  final AsyncState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;

  const AsyncValue.idle()
      : state = AsyncState.idle,
        data = null,
        error = null,
        stackTrace = null;

  const AsyncValue.loading()
      : state = AsyncState.loading,
        data = null,
        error = null,
        stackTrace = null;

  const AsyncValue.success(this.data)
      : state = AsyncState.success,
        error = null,
        stackTrace = null;

  const AsyncValue.error(this.error, [this.stackTrace])
      : state = AsyncState.error,
        data = null;

  bool get isIdle => state == AsyncState.idle;
  bool get isLoading => state == AsyncState.loading;
  bool get isSuccess => state == AsyncState.success;
  bool get isError => state == AsyncState.error;

  R when<R>({
    required R Function() idle,
    required R Function() loading,
    required R Function(T data) success,
    required R Function(Object error, StackTrace? stackTrace) error,
  }) {
    switch (state) {
      case AsyncState.idle:
        return idle();
      case AsyncState.loading:
        return loading();
      case AsyncState.success:
        return success(data as T);
      case AsyncState.error:
        return error(this.error!, stackTrace);
    }
  }
}

/// Reactive Future wrapper that tracks loading/error states
class SwiftFuture<T> extends ChangeNotifier {
  Rx<AsyncValue<T>> _state;

  SwiftFuture() : _state = Rx(AsyncValue<T>.idle());

  /// Current async state
  AsyncValue<T> get value {
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(_state);
    }
    return _state.value;
  }

  /// Whether the future is currently loading
  bool get isLoading => _state.value.isLoading;

  /// Whether the future has completed successfully
  bool get isSuccess => _state.value.isSuccess;

  /// Whether the future has errored
  bool get isError => _state.value.isError;

  /// The data if successful
  T? get data => _state.value.data;

  /// The error if failed
  Object? get error => _state.value.error;

  /// Executes a future and updates state automatically
  /// Rethrows exceptions - use [execute] for non-throwing version
  Future<T> call(Future<T> Function() future) async {
    _state.value = AsyncValue<T>.loading();
    try {
      final result = await future();
      _state.value = AsyncValue<T>.success(result);
      return result;
    } catch (e, stackTrace) {
      _state.value = AsyncValue<T>.error(e, stackTrace);
      rethrow;
    }
  }

  /// Executes a future and updates state automatically
  /// Does not rethrow exceptions - errors are only stored in state
  Future<void> execute(Future<T> Function() future) async {
    _state.value = AsyncValue<T>.loading();
    try {
      final result = await future();
      _state.value = AsyncValue<T>.success(result);
    } catch (e, stackTrace) {
      _state.value = AsyncValue<T>.error(e, stackTrace);
    }
  }

  /// Resets to idle state
  void reset() {
    _state.value = AsyncValue<T>.idle();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}

