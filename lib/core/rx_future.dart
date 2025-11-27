import 'package:flutter/foundation.dart';
import 'rx.dart';
import '../ui/mark.dart';
import 'logger.dart';

/// Represents the state of an async operation
enum AsyncState { idle, loading, success, error }

/// Retry configuration for async operations
class RetryConfig {
  /// Maximum number of retry attempts
  final int maxAttempts;
  
  /// Delay between retries
  final Duration delay;
  
  /// Function to determine if an error should be retried
  final bool Function(Object error)? shouldRetry;
  
  /// Exponential backoff multiplier (1.0 = no backoff, 2.0 = doubles each time)
  final double backoffMultiplier;

  const RetryConfig({
    this.maxAttempts = 3,
    this.delay = const Duration(seconds: 1),
    this.shouldRetry,
    this.backoffMultiplier = 1.0,
  });

  /// Calculate delay for a specific attempt (with exponential backoff)
  Duration getDelayForAttempt(int attempt) {
    final multiplier = backoffMultiplier > 1.0 
        ? (backoffMultiplier * attempt).round() 
        : 1.0;
    return Duration(
      milliseconds: (delay.inMilliseconds * multiplier).round(),
    );
  }
}

/// Error recovery strategy
enum ErrorRecoveryStrategy {
  /// No recovery - just show error
  none,
  
  /// Retry the operation
  retry,
  
  /// Use fallback value
  fallback,
  
  /// Custom recovery function
  custom,
}

/// Wrapper for async values with loading/error states
class AsyncValue<T> {
  final AsyncState state;
  final T? data;
  final Object? error;
  final StackTrace? stackTrace;
  final int? retryCount;

  const AsyncValue.idle()
      : state = AsyncState.idle,
        data = null,
        error = null,
        stackTrace = null,
        retryCount = null;

  const AsyncValue.loading([this.retryCount])
      : state = AsyncState.loading,
        data = null,
        error = null,
        stackTrace = null;

  const AsyncValue.success(this.data)
      : state = AsyncState.success,
        error = null,
        stackTrace = null,
        retryCount = null;

  const AsyncValue.error(this.error, [this.stackTrace, this.retryCount])
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

  /// Get user-friendly error message
  String get errorMessage {
    if (error == null) return 'Unknown error';
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return error.toString();
  }
}

/// Reactive Future wrapper that tracks loading/error states with retry and error recovery
class SwiftFuture<T> extends ChangeNotifier {
  final Rx<AsyncValue<T>> _state;
  RetryConfig? _retryConfig;
  T? _fallbackValue;
  Future<T> Function()? _recoveryFunction;
  ErrorRecoveryStrategy _recoveryStrategy = ErrorRecoveryStrategy.none;
  int _currentAttempt = 0;

  SwiftFuture({
    RetryConfig? retryConfig,
    T? fallbackValue,
    Future<T> Function()? recoveryFunction,
    ErrorRecoveryStrategy recoveryStrategy = ErrorRecoveryStrategy.none,
  })  : _state = Rx(AsyncValue<T>.idle()),
        _retryConfig = retryConfig,
        _fallbackValue = fallbackValue,
        _recoveryFunction = recoveryFunction,
        _recoveryStrategy = recoveryStrategy;

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

  /// Get user-friendly error message
  String? get errorMessage => _state.value.errorMessage;

  /// Current retry attempt (0 = first attempt, 1+ = retries)
  int get currentAttempt => _currentAttempt;

  /// Configure retry behavior
  void configureRetry(RetryConfig config) {
    _retryConfig = config;
  }

  /// Configure error recovery
  void configureRecovery({
    ErrorRecoveryStrategy? strategy,
    T? fallbackValue,
    Future<T> Function()? recoveryFunction,
  }) {
    if (strategy != null) _recoveryStrategy = strategy;
    if (fallbackValue != null) _fallbackValue = fallbackValue;
    if (recoveryFunction != null) _recoveryFunction = recoveryFunction;
  }

  /// Executes a future and updates state automatically with retry support
  /// Rethrows exceptions - use [execute] for non-throwing version
  Future<T> call(Future<T> Function() future) async {
    _currentAttempt = 0;
    return _executeWithRetry(future, shouldRethrow: true);
  }

  /// Executes a future and updates state automatically with retry support
  /// Does not rethrow exceptions - errors are only stored in state
  Future<void> execute(Future<T> Function() future) async {
    _currentAttempt = 0;
    await _executeWithRetry(future, shouldRethrow: false);
  }

  Future<T> _executeWithRetry(
    Future<T> Function() future, {
    required bool shouldRethrow,
  }) async {
    final config = _retryConfig ?? const RetryConfig(maxAttempts: 0);
    final maxAttempts = config.maxAttempts + 1; // +1 for initial attempt

    while (_currentAttempt < maxAttempts) {
      try {
        if (_currentAttempt > 0) {
          // Retry attempt
          final delay = config.getDelayForAttempt(_currentAttempt);
          Logger.debug(
            'Retrying async operation (attempt ${_currentAttempt + 1}/$maxAttempts) after ${delay.inMilliseconds}ms',
          );
          await Future.delayed(delay);
        }

        _state.value = AsyncValue<T>.loading(_currentAttempt);
        final result = await future();
        _state.value = AsyncValue<T>.success(result);
        _currentAttempt = 0; // Reset on success
        return result;
      } catch (e, stackTrace) {
        _currentAttempt++;
        final shouldRetry = _currentAttempt < maxAttempts &&
            (config.shouldRetry == null || config.shouldRetry!(e));

        if (shouldRetry) {
          Logger.warning(
            'Async operation failed (attempt $_currentAttempt/$maxAttempts): $e',
            e,
          );
          continue; // Retry
        }

        // No more retries - handle error
        _state.value = AsyncValue<T>.error(e, stackTrace, _currentAttempt - 1);
        _currentAttempt = 0; // Reset

        // Apply error recovery strategy
        final recovered = await _applyRecovery(e, stackTrace);
        if (recovered != null) {
          return recovered;
        }

        if (shouldRethrow) {
          rethrow;
        }
        return _fallbackValue as T;
      }
    }

    // Should never reach here, but handle just in case
    throw StateError('Max retry attempts exceeded');
  }

  Future<T?> _applyRecovery(Object error, StackTrace? stackTrace) async {
    switch (_recoveryStrategy) {
      case ErrorRecoveryStrategy.none:
        return null;

      case ErrorRecoveryStrategy.fallback:
        if (_fallbackValue != null) {
          Logger.info('Using fallback value after error: $error');
          _state.value = AsyncValue<T>.success(_fallbackValue as T);
          return _fallbackValue as T;
        }
        return null;

      case ErrorRecoveryStrategy.custom:
        if (_recoveryFunction != null) {
          try {
            Logger.info('Attempting custom recovery for error: $error');
            final result = await _recoveryFunction!();
            _state.value = AsyncValue<T>.success(result);
            return result;
          } catch (e) {
            Logger.error('Custom recovery failed', e);
            return null;
          }
        }
        return null;

      case ErrorRecoveryStrategy.retry:
        // Already handled in _executeWithRetry
        return null;
    }
  }

  /// Retry the last failed operation
  Future<void> retry() async {
    if (_state.value.isError && _recoveryFunction != null) {
      await execute(_recoveryFunction!);
    }
  }

  /// Resets to idle state
  void reset() {
    _currentAttempt = 0;
    _state.value = AsyncValue<T>.idle();
  }

  @override
  void dispose() {
    _state.dispose();
    super.dispose();
  }
}

