import 'rx.dart';
import 'transaction.dart';
import 'logger.dart';

/// Action interface for Redux-like pattern
abstract class Action {
  String get type;
  Map<String, dynamic>? get payload => null;
}

/// Reducer function type
typedef Reducer<T> = T Function(T state, Action action);

/// Store with Redux-like reducer pattern
class ReduxStore<T> extends Rx<T> {
  final Reducer<T> _reducer;
  final List<Action> _actionHistory = [];
  int _historyLimit = 50;
  bool _enableHistory = true;

  ReduxStore(
    T initialState,
    this._reducer,
  ) : super(initialState);

  /// Dispatch an action to update state
  void dispatch(Action action) {
    try {
      final newState = _reducer(value, action);
      
      Transaction.run(() {
        value = newState;
      });

      if (_enableHistory) {
        _actionHistory.add(action);
        if (_actionHistory.length > _historyLimit) {
          _actionHistory.removeAt(0);
        }
      }

      Logger.debug('Action dispatched: ${action.type}', action.payload);
    } catch (e) {
      Logger.error('Error dispatching action: ${action.type}', e);
      rethrow;
    }
  }

  /// Get action history
  List<Action> get actionHistory => List.unmodifiable(_actionHistory);

  /// Clear action history
  void clearHistory() {
    _actionHistory.clear();
  }

  /// Enable/disable action history
  void setHistoryEnabled(bool enabled) {
    _enableHistory = enabled;
    if (!enabled) {
      clearHistory();
    }
  }

  /// Set history limit
  void setHistoryLimit(int limit) {
    _historyLimit = limit;
    while (_actionHistory.length > _historyLimit) {
      _actionHistory.removeAt(0);
    }
  }

  /// Get current state (alias for value)
  T get state => value;

  /// Reset to initial state
  void reset(T initialState) {
    value = initialState;
    clearHistory();
  }
}

/// Combine multiple reducers into one
Reducer<T> combineReducers<T>(Map<String, Reducer<T>> reducers) {
  return (T state, Action action) {
    final reducer = reducers[action.type];
    if (reducer != null) {
      return reducer(state, action);
    }
    return state;
  };
}

/// Middleware for Redux store
typedef ReduxMiddleware<T> = void Function(
  ReduxStore<T> store,
  Action action,
  void Function(Action) next,
);

/// Apply middleware to a reducer
Reducer<T> applyMiddleware<T>(
  Reducer<T> reducer,
  List<ReduxMiddleware<T>> middlewares,
) {
  return (T state, Action action) {
    // Create a chain of middleware
    void Function(Action) next = (Action action) {
      reducer(state, action);
    };

    for (var i = middlewares.length - 1; i >= 0; i--) {
      final middleware = middlewares[i];
      final currentNext = next;
      next = (Action action) {
        middleware(
          ReduxStore(state, reducer),
          action,
          currentNext,
        );
      };
    }

    next(action);
    return state;
  };
}

