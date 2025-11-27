import 'rx.dart';
import 'computed.dart';

/// Type-safe reactive value with compile-time checks
/// Provides better type safety than plain Rx&lt;T&gt;
class TypedRx<T> extends Rx<T> {
  TypedRx(super.value);

  /// Create a typed Rx with validation
  factory TypedRx.withValidator(
    T value,
    bool Function(T) validator,
  ) {
    if (!validator(value)) {
      throw ArgumentError('Invalid value for TypedRx: $value');
    }
    return TypedRx<T>(value);
  }

  /// Set value with type checking
  @override
  set value(T newValue) {
    // Runtime type check - note: this is a runtime check, compile-time type is already enforced
    // The type is already enforced at compile time, so we can just set it
    super.value = newValue;
  }

  /// Update with type-safe transformation
  TypedRx<R> map<R>(R Function(T) transform) {
    return TypedRx<R>(transform(value));
  }

  /// Chain operations with type safety
  TypedRx<R> chain<R>(R Function(T) transform) {
    return TypedRx<R>(transform(value));
  }
}

/// Type-safe computed value
class TypedComputed<T> extends Computed<T> {
  final bool _enableMemoization;
  
  TypedComputed(super.compute, {super.enableMemoization = false})
      : _enableMemoization = enableMemoization;

  /// Create with type validation
  factory TypedComputed.withValidator(
    T Function() compute,
    bool Function(T) validator, {
    bool enableMemoization = false,
  }) {
    return TypedComputed<T>(
      () {
        final result = compute();
        if (!validator(result)) {
          throw StateError('Computed value failed validation: $result');
        }
        return result;
      },
      enableMemoization: enableMemoization,
    );
  }

  /// Chain with type safety
  TypedComputed<R> chain<R>(R Function(T) transform) {
    return TypedComputed<R>(
      () => transform(value),
      enableMemoization: _enableMemoization,
    );
  }
}

/// Type guard for runtime type checking
class TypeGuard {
  /// Check if value is of type T
  static bool isType<T>(dynamic value) {
    return value is T;
  }

  /// Assert value is of type T, throw if not
  static T assertType<T>(dynamic value, [String? message]) {
    if (value is! T) {
      final errorMsg = message ?? 'Expected type $T, got ${value.runtimeType}';
      throw ArgumentError(errorMsg);
    }
    return value;
  }

  /// Safe cast with fallback
  static T? safeCast<T>(dynamic value) {
    return value is T ? value : null;
  }
}

/// Type-safe reactive chain builder
class ReactiveChain<T> {
  final dynamic _source; // Can be Rx<T> or Computed<T>

  ReactiveChain(this._source);

  /// Map to another type
  ReactiveChain<R> map<R>(R Function(T) transform) {
    final computed = Computed<R>(() {
      final val = _source is Rx<T> ? (_source as Rx<T>).value : (_source as Computed<T>).value;
      return transform(val);
    });
    return ReactiveChain<R>(computed);
  }

  /// Filter values
  ReactiveChain<T> where(bool Function(T) test) {
    final computed = Computed<T>(() {
      final val = _source is Rx<T> ? (_source as Rx<T>).value : (_source as Computed<T>).value;
      if (!test(val)) {
        throw StateError('Value $val does not pass filter');
      }
      return val;
    });
    return ReactiveChain<T>(computed);
  }

  /// Get the underlying reactive value
  dynamic get source => _source;
  
  /// Get value
  T get value {
    if (_source is Rx<T>) {
      return (_source as Rx<T>).value;
    } else if (_source is Computed<T>) {
      return (_source as Computed<T>).value;
    }
    throw StateError('Invalid source type');
  }
}

/// Extension for better type safety on Rx
extension RxTypeSafety<T> on Rx<T> {
  /// Create a typed version
  TypedRx<T> toTyped() => TypedRx<T>(value);

  /// Create a reactive chain
  ReactiveChain<T> chain() => ReactiveChain<T>(this);

  /// Assert type at runtime
  Rx<T> assertType([String? message]) {
    // Runtime type check for dynamic Rx values
    // ignore: unnecessary_type_check
    if (value is! T) {
      final errorMsg = message ?? 'Type assertion failed for Rx<$T>';
      throw ArgumentError(errorMsg);
    }
    return this;
  }
}

