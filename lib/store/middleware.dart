import 'package:flutter/foundation.dart';

/// Action interface for middleware
abstract class Action {
  String get type;
  Map<String, dynamic> get payload;
  Future<dynamic> execute();
}

/// Middleware interface for intercepting actions
abstract class Middleware {
  /// Called before action execution
  Future<Action?> before(Action action) async => action;

  /// Called after successful action execution
  Future<void> after(Action action, dynamic result) async {}

  /// Called when action execution fails
  Future<void> onError(Object error, StackTrace stackTrace, Action action) async {}
}

/// Logging middleware
class LoggingMiddleware extends Middleware {
  @override
  Future<Action?> before(Action action) async {
    // Use debugPrint instead of print for production code
    debugPrint('🔵 [Middleware] Before: ${action.type}');
    return action;
  }

  @override
  Future<void> after(Action action, dynamic result) async {
    debugPrint('🟢 [Middleware] After: ${action.type} -> $result');
  }

  @override
  Future<void> onError(Object error, StackTrace stackTrace, Action action) async {
    debugPrint('🔴 [Middleware] Error in ${action.type}: $error');
  }
}

/// Example action implementation
class ExampleAction implements Action {
  @override
  final String type;
  @override
  final Map<String, dynamic> payload;
  final Future<dynamic> Function() _execute;

  ExampleAction(this.type, this.payload, this._execute);

  @override
  Future<dynamic> execute() => _execute();
}

