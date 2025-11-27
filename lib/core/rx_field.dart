import 'rx.dart';
import '../ui/mark.dart';

/// Validation function type
typedef Validator<T> = String? Function(T value);

/// Form field with validation
class SwiftField<T> extends Rx<T> {
  final List<Validator<T>> _validators = [];
  final Rx<String?> _error = Rx<String?>(null);
  bool _touched = false;

  SwiftField(super.initialValue);

  /// Current error message
  String? get error {
    final mark = MarkRegistry.current;
    if (mark != null) {
      mark.register(_error);
    }
    return _error.value;
  }

  /// Whether the field has been touched
  bool get touched => _touched;

  /// Whether the field is valid
  bool get isValid => _error.value == null;

  /// Add a validator
  void addValidator(Validator<T> validator) {
    _validators.add(validator);
  }

  /// Validate the field
  bool validate() {
    _touched = true;
    for (final validator in _validators) {
      final error = validator(value);
      if (error != null) {
        _error.value = error;
        return false;
      }
    }
    _error.value = null;
    return true;
  }

  /// Mark as touched
  void markAsTouched() {
    _touched = true;
    validate();
  }

  /// Reset field
  void reset() {
    _touched = false;
    _error.value = null;
  }

  @override
  set value(T newValue) {
    super.value = newValue;
    if (_touched) {
      validate();
    }
  }

  @override
  void update(T newValue) {
    super.update(newValue);
    if (_touched) {
      validate();
    }
  }

  @override
  void dispose() {
    _error.dispose();
    super.dispose();
  }
}

/// Common validators
class Validators {
  static Validator<String> required([String? message]) {
    return (value) => value.isEmpty ? (message ?? 'This field is required') : null;
  }

  static Validator<String> minLength(int length, [String? message]) {
    return (value) => value.length < length
        ? (message ?? 'Must be at least $length characters')
        : null;
  }

  static Validator<String> maxLength(int length, [String? message]) {
    return (value) => value.length > length
        ? (message ?? 'Must be at most $length characters')
        : null;
  }

  static Validator<String> email([String? message]) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return (value) => !emailRegex.hasMatch(value)
        ? (message ?? 'Invalid email address')
        : null;
  }

  static Validator<String> pattern(RegExp pattern, [String? message]) {
    return (value) => !pattern.hasMatch(value)
        ? (message ?? 'Invalid format')
        : null;
  }

  static Validator<T> custom<T>(bool Function(T) test, [String? message]) {
    return (value) => !test(value) ? (message ?? 'Invalid value') : null;
  }
}

