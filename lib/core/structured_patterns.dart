import 'rx.dart';
import 'logger.dart';
import 'transaction.dart';

/// Structured state management pattern (Bloc-like but simpler)
/// Provides opinionated structure for state management
class StructuredState<TState, TEvent> {
  final TState state;
  final TEvent? lastEvent;
  final DateTime timestamp;
  final List<TEvent> eventHistory;

  StructuredState({
    required this.state,
    this.lastEvent,
    DateTime? timestamp,
    List<TEvent>? eventHistory,
  })  : timestamp = timestamp ?? DateTime.now(),
        eventHistory = eventHistory ?? [];

  StructuredState<TState, TEvent> copyWith({
    TState? state,
    TEvent? lastEvent,
    DateTime? timestamp,
    List<TEvent>? eventHistory,
  }) {
    return StructuredState<TState, TEvent>(
      state: state ?? this.state,
      lastEvent: lastEvent ?? this.lastEvent,
      timestamp: timestamp ?? this.timestamp,
      eventHistory: eventHistory ?? this.eventHistory,
    );
  }
}

/// Event handler function type
typedef EventHandler<TState, TEvent> = TState Function(TState state, TEvent event);

/// Structured state manager (Bloc-like pattern)
class StructuredStore<TState, TEvent> extends Rx<StructuredState<TState, TEvent>> {
  final Map<Type, EventHandler<TState, TEvent>> _handlers = {};
  final TState _initialState;
  int _maxHistorySize = 50;

  StructuredStore(this._initialState)
      : super(StructuredState<TState, TEvent>(state: _initialState));

  /// Register event handler
  void on<T extends TEvent>(EventHandler<TState, T> handler) {
    _handlers[T] = (state, event) => handler(state, event as T);
  }

  /// Dispatch event
  void dispatch(TEvent event) {
    final handler = _handlers[event.runtimeType];
    if (handler == null) {
      Logger.warning('No handler registered for event type: ${event.runtimeType}');
      return;
    }

    try {
      final newState = handler(value.state, event);
      final newHistory = List<TEvent>.from(value.eventHistory);
      newHistory.add(event);
      
      // Limit history size
      if (newHistory.length > _maxHistorySize) {
        newHistory.removeAt(0);
      }

      Transaction.run(() {
        value = value.copyWith(
          state: newState,
          lastEvent: event,
          timestamp: DateTime.now(),
          eventHistory: newHistory,
        );
      });

      Logger.debug('Event dispatched: ${event.runtimeType}', event);
    } catch (e) {
      Logger.error('Error handling event: ${event.runtimeType}', e);
      rethrow;
    }
  }

  /// Get current state
  TState get currentState => value.state;

  /// Get last event
  TEvent? get lastEvent => value.lastEvent;

  /// Get event history
  List<TEvent> get eventHistory => List.unmodifiable(value.eventHistory);

  /// Reset to initial state
  void reset() {
    Transaction.run(() {
      value = StructuredState<TState, TEvent>(
        state: _initialState,
        eventHistory: [],
      );
    });
  }

  /// Set max history size
  void setMaxHistorySize(int size) {
    _maxHistorySize = size;
    if (value.eventHistory.length > size) {
      final newHistory = value.eventHistory.sublist(
        value.eventHistory.length - size,
      );
      value = value.copyWith(eventHistory: newHistory);
    }
  }
}

/// Opinionated state management helper
/// Provides common patterns out of the box
class OpinionatedStore<T> extends Rx<T> {
  final List<Function(T, T)> _middlewares = [];
  final List<Function(T)> _sideEffects = [];

  OpinionatedStore(super.value);

  /// Add middleware (runs before state update)
  void addMiddleware(void Function(T oldState, T newState) middleware) {
    _middlewares.add(middleware);
  }

  /// Add side effect (runs after state update)
  void addSideEffect(void Function(T state) sideEffect) {
    _sideEffects.add(sideEffect);
  }

  @override
  set value(T newValue) {
    final oldValue = value;
    
    // Run middlewares
    for (final middleware in _middlewares) {
      middleware(oldValue, newValue);
    }

    super.value = newValue;

    // Run side effects
    for (final sideEffect in _sideEffects) {
      sideEffect(newValue);
    }
  }

  /// Update with side effects
  void updateWithEffects(T newValue) {
    value = newValue;
  }
}

/// Builder for creating opinionated stores
class OpinionatedStoreBuilder<T> {
  final T _initialState;
  final List<Function(T, T)> _middlewares = [];
  final List<Function(T)> _sideEffects = [];

  OpinionatedStoreBuilder(this._initialState);

  /// Add middleware
  OpinionatedStoreBuilder<T> withMiddleware(
    void Function(T oldState, T newState) middleware,
  ) {
    _middlewares.add(middleware);
    return this;
  }

  /// Add side effect
  OpinionatedStoreBuilder<T> withSideEffect(void Function(T state) sideEffect) {
    _sideEffects.add(sideEffect);
    return this;
  }

  /// Build the store
  OpinionatedStore<T> build() {
    final store = OpinionatedStore<T>(_initialState);
    for (final middleware in _middlewares) {
      store.addMiddleware(middleware);
    }
    for (final sideEffect in _sideEffects) {
      store.addSideEffect(sideEffect);
    }
    return store;
  }
}

/// Common opinionated patterns
class OpinionatedPatterns {
  /// Create a store with logging
  static OpinionatedStore<T> withLogging<T>(T initialState) {
    return OpinionatedStoreBuilder<T>(initialState)
        .withMiddleware((old, new_) {
          Logger.debug('State changed', {'old': old, 'new': new_});
        })
        .build();
  }

  /// Create a store with persistence
  static OpinionatedStore<T> withPersistence<T>(
    T initialState,
    void Function(T) save,
  ) {
    return OpinionatedStoreBuilder<T>(initialState)
        .withSideEffect((state) => save(state))
        .build();
  }

  /// Create a store with validation
  static OpinionatedStore<T> withValidation<T>(
    T initialState,
    bool Function(T) validator,
  ) {
    return OpinionatedStoreBuilder<T>(initialState)
        .withMiddleware((old, new_) {
          if (!validator(new_)) {
            throw ArgumentError('State validation failed: $new_');
          }
        })
        .build();
  }
}

