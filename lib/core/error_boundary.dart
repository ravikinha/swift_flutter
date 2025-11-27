import 'package:flutter/material.dart';
import 'logger.dart';

/// Error boundary for safe state updates with error recovery
class ErrorBoundary {
  /// Execute a function safely, returning fallback on error
  static T? safeUpdate<T>(T Function() update, {T? fallback}) {
    try {
      return update();
    } catch (e, stackTrace) {
      Logger.error('State update error', e);
      Logger.debug('Stack trace', stackTrace);
      return fallback;
    }
  }

  /// Execute an async function safely, returning fallback on error
  static Future<T?> safeUpdateAsync<T>(
    Future<T> Function() update, {
    T? fallback,
  }) async {
    try {
      return await update();
    } catch (e, stackTrace) {
      Logger.error('Async state update error', e);
      Logger.debug('Stack trace', stackTrace);
      return fallback;
    }
  }

  /// Execute a function safely, throwing if error occurs
  static T safeUpdateOrThrow<T>(T Function() update) {
    try {
      return update();
    } catch (e, stackTrace) {
      Logger.error('State update error (throwing)', e);
      Logger.debug('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// Execute an async function safely, throwing if error occurs
  static Future<T> safeUpdateAsyncOrThrow<T>(
    Future<T> Function() update,
  ) async {
    try {
      return await update();
    } catch (e, stackTrace) {
      Logger.error('Async state update error (throwing)', e);
      Logger.debug('Stack trace', stackTrace);
      rethrow;
    }
  }

  /// Execute a function with custom error handler
  static T safeUpdateWithHandler<T>(
    T Function() update,
    T Function(Object error, StackTrace stackTrace) onError,
  ) {
    try {
      return update();
    } catch (e, stackTrace) {
      Logger.error('State update error (custom handler)', e);
      Logger.debug('Stack trace', stackTrace);
      return onError(e, stackTrace);
    }
  }

  /// Execute an async function with custom error handler
  static Future<T> safeUpdateAsyncWithHandler<T>(
    Future<T> Function() update,
    Future<T> Function(Object error, StackTrace stackTrace) onError,
  ) async {
    try {
      return await update();
    } catch (e, stackTrace) {
      Logger.error('Async state update error (custom handler)', e);
      Logger.debug('Stack trace', stackTrace);
      return await onError(e, stackTrace);
    }
  }

  /// Get user-friendly error message from an error object
  static String getErrorMessage(Object error, [StackTrace? stackTrace]) {
    if (error is Exception) {
      final message = error.toString();
      // Remove "Exception: " prefix if present
      return message.replaceFirst(RegExp(r'^Exception:\s*'), '');
    }
    return error.toString();
  }

  /// Get error context for better debugging
  static Map<String, dynamic> getErrorContext(
    Object error,
    StackTrace? stackTrace,
  ) {
    return {
      'error': error.toString(),
      'errorType': error.runtimeType.toString(),
      'message': getErrorMessage(error, stackTrace),
      'stackTrace': stackTrace?.toString(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }
}

/// Error boundary widget that catches errors in widget tree
class ErrorBoundaryWidget extends StatefulWidget {
  final Widget child;
  final Widget Function(BuildContext context, Object error, StackTrace? stackTrace)? errorBuilder;
  final VoidCallback? onError;

  const ErrorBoundaryWidget({
    super.key,
    required this.child,
    this.errorBuilder,
    this.onError,
  });

  @override
  State<ErrorBoundaryWidget> createState() => _ErrorBoundaryWidgetState();
}

class _ErrorBoundaryWidgetState extends State<ErrorBoundaryWidget> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  void initState() {
    super.initState();
    // Catch Flutter errors
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
      widget.onError?.call();
      Logger.error('Widget error caught by ErrorBoundary', details.exception);
    };
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      if (widget.errorBuilder != null) {
        return widget.errorBuilder!(context, _error!, _stackTrace);
      }
      return _DefaultErrorWidget(
        error: _error!,
        stackTrace: _stackTrace,
        onRetry: () {
          setState(() {
            _error = null;
            _stackTrace = null;
          });
        },
      );
    }
    return widget.child;
  }
}

/// Default error widget displayed when error occurs
class _DefaultErrorWidget extends StatelessWidget {
  final Object error;
  final StackTrace? stackTrace;
  final VoidCallback? onRetry;

  const _DefaultErrorWidget({
    required this.error,
    this.stackTrace,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final errorMessage = ErrorBoundary.getErrorMessage(error, stackTrace);
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Something went wrong',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              if (onRetry != null) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: onRetry,
                  child: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

