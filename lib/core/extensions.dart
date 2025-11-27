import 'rx.dart';
import 'currency.dart';

/// Swift-like extension methods for common Dart types.
///
/// This file provides convenient extension methods inspired by Swift's API,
/// making Dart code more expressive and concise.
///
/// Example usage:
/// ```dart
/// import 'package:swift_flutter/swift_flutter.dart';
///
/// // Bool toggle
/// bool flag = true;
/// flag = flag.toggle(); // false
///
/// // Number operations
/// int count = 10;
/// count = count.add(5); // 15
/// count = count.sub(3); // 12
/// count = count.clamped(min: 0, max: 100); // 12
///
/// // String operations
/// String name = 'hello';
/// name = name.capitalized; // 'Hello'
/// name = name.add(' world'); // 'Hello world'
/// name = name.dropFirst(); // 'ello world'
/// name = name.dropLast(); // 'ello worl'
///
/// // List operations
/// List<int> numbers = [1, 2, 3, 4, 5];
/// numbers = numbers.dropFirst(); // [2, 3, 4, 5]
/// numbers = numbers.dropLast(); // [2, 3, 4]
/// numbers.containsWhere((n) => n > 3); // true (Swift-like contains(where:))
///
/// // Reactive operations
/// final counter = swift(10);
/// counter.add(5); // counter.value is now 15
/// counter.sub(3); // counter.value is now 12
///
/// final name = swift('hello');
/// name.add(' world'); // name.value is now 'hello world'
///
/// final flag = swift(true);
/// flag.toggle(); // flag.value is now false
/// ```

/// Extension methods for [bool] type.
extension BoolExtensions on bool {
  /// Toggles the boolean value.
  ///
  /// Returns the opposite of the current value.
  ///
  /// Example:
  /// ```dart
  /// bool flag = true;
  /// flag = flag.toggle(); // false
  /// flag = flag.toggle(); // true
  /// ```
  bool toggle() => !this;
}

/// Extension methods for [int] type.
extension IntExtensions on int {
  /// Adds a value to this integer.
  ///
  /// Example:
  /// ```dart
  /// int count = 10;
  /// count = count.add(5); // 15
  /// ```
  int add(int value) => this + value;

  /// Subtracts a value from this integer.
  ///
  /// Example:
  /// ```dart
  /// int count = 10;
  /// count = count.sub(3); // 7
  /// ```
  int sub(int value) => this - value;

  /// Multiplies this integer by a value.
  ///
  /// Example:
  /// ```dart
  /// int count = 10;
  /// count = count.mul(3); // 30
  /// ```
  int mul(int value) => this * value;

  /// Divides this integer by a value.
  /// Returns a double since division may result in a fractional value.
  ///
  /// Example:
  /// ```dart
  /// int count = 10;
  /// double result = count.div(3); // 3.333...
  /// ```
  double div(int value) => this / value;

  /// Calculates what percentage this number is of another number.
  ///
  /// Example:
  /// ```dart
  /// int value = 25;
  /// double percentage = value.percent(of: 100); // 25.0
  /// ```
  double percent({required int of}) => (this / of) * 100;

  /// Applies a percentage to this number (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// int price = 100;
  /// double result = price.applyPercent(20); // 120.0 (100 + 20%)
  /// ```
  double applyPercent(double percent) => this * (1 + percent / 100);

  /// Applies a discount percentage to this number (subtracts percentage).
  ///
  /// Example:
  /// ```dart
  /// int price = 100;
  /// double result = price.discount(20); // 80.0 (100 - 20%)
  /// ```
  double discount(double percent) => this * (1 - percent / 100);

  /// Applies a tax percentage to this number (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// int price = 100;
  /// double result = price.tax(10); // 110.0 (100 + 10%)
  /// ```
  double tax(double percent) => this * (1 + percent / 100);

  /// Adds GST to this number.
  ///
  /// Example:
  /// ```dart
  /// int price = 100;
  /// double result = price.addGST(10); // 110.0
  /// ```
  double addGST(double percent) => this * (1 + percent / 100);

  /// Removes GST from this number.
  ///
  /// Example:
  /// ```dart
  /// double priceWithGST = 110.0;
  /// double result = priceWithGST.removeGST(10); // 100.0
  /// ```
  double removeGST(double percent) => this / (1 + percent / 100);

  /// Rounds this integer to the nearest value.
  ///
  /// Note: For integers, this returns the same value unless decimals is 0 or negative.
  ///
  /// Example:
  /// ```dart
  /// int value = 123;
  /// value = value.roundTo(0); // 123
  /// ```
  int roundTo(int decimals) => decimals <= 0 ? this : this;

  /// Ceils this integer to the nearest value.
  int ceilTo(int decimals) => decimals <= 0 ? this : this;

  /// Floors this integer to the nearest value.
  int floorTo(int decimals) => decimals <= 0 ? this : this;

  /// Checks if this integer is between [min] and [max] (inclusive).
  ///
  /// Example:
  /// ```dart
  /// int value = 50;
  /// bool isInRange = value.isBetween(0, 100); // true
  /// ```
  bool isBetween(int min, int max) => this >= min && this <= max;

  /// Clamps this integer between [min] and [max].
  ///
  /// Returns a value that is at least [min] and at most [max].
  ///
  /// Example:
  /// ```dart
  /// int value = 150;
  /// value = value.clamped(min: 0, max: 100); // 100
  /// ```
  int clamped({required int min, required int max}) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Linear interpolation between this value and [end] at [t].
  ///
  /// Example:
  /// ```dart
  /// int start = 10;
  /// double result = start.lerp(20, 0.5); // 15.0
  /// ```
  double lerp(int end, double t) => this + (end - this) * t;

  /// Maps this value from one range [fromMin, fromMax] to another [toMin, toMax].
  ///
  /// Example:
  /// ```dart
  /// int value = 50;
  /// double mapped = value.mapRange(fromMin: 0, fromMax: 100, toMin: 0.0, toMax: 1.0); // 0.5
  /// ```
  double mapRange({
    required int fromMin,
    required int fromMax,
    required double toMin,
    required double toMax,
  }) {
    if (fromMax == fromMin) return toMin;
    final normalized = (this - fromMin) / (fromMax - fromMin);
    return toMin + normalized * (toMax - toMin);
  }

  /// Formats this integer as currency.
  ///
  /// Example:
  /// ```dart
  /// int price = 1234;
  /// String formatted = price.toCurrency(); // '$1,234.00'
  /// ```
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return '$symbol${(this / 1).toStringAsFixed(decimals).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        )}';
  }

  /// Formats this integer as Indian Rupee (INR).
  ///
  /// Example:
  /// ```dart
  /// int price = 10000;
  /// String formatted = price.toINR(); // '₹10,000'
  /// ```
  String toINR() => Currency.inr.format(toDouble());


  /// Formats this integer using a specific currency.
  ///
  /// Example:
  /// ```dart
  /// int price = 1000;
  /// String formatted = price.toCurrencyType(Currency.inr); // '₹1,000.00'
  /// ```
  String toCurrencyType(Currency currency) => currency.format(toDouble());

  /// Formats this integer as a readable number with K, M, B, T suffixes.
  /// Automatically chooses the appropriate suffix based on value.
  ///
  /// Example:
  /// ```dart
  /// int value = 1500;
  /// String readable = value.toReadable(); // '1.5K'
  /// 1500000.toReadable(); // '1.5M'
  /// 1500000000.toReadable(); // '1.5B'
  /// 1500000000000.toReadable(); // '1.5T'
  /// ```
  String toReadable() {
    final absValue = this.abs();
    final isNegative = this < 0;
    final sign = isNegative ? '-' : '';
    
    if (absValue < 1000) return '$sign$absValue';
    if (absValue < 1000000) return '$sign${(absValue / 1000).toStringAsFixed(1)}K';
    if (absValue < 1000000000) return '$sign${(absValue / 1000000).toStringAsFixed(1)}M';
    if (absValue < 1000000000000) return '$sign${(absValue / 1000000000).toStringAsFixed(1)}B';
    return '$sign${(absValue / 1000000000000).toStringAsFixed(1)}T';
  }

  /// Converts this integer to an ordinal string (1st, 2nd, 3rd, etc.).
  ///
  /// Example:
  /// ```dart
  /// int value = 1;
  /// String ordinal = value.toOrdinal(); // '1st'
  /// ```
  String toOrdinal() {
    final suffix = _getOrdinalSuffix(this);
    return '$this$suffix';
  }

  String _getOrdinalSuffix(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    
    if (lastTwo >= 11 && lastTwo <= 13) {
      return 'th';
    }
    
    switch (lastOne) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

/// Extension methods for [double] type.
extension DoubleExtensions on double {
  /// Adds a value to this double.
  ///
  /// Example:
  /// ```dart
  /// double price = 10.5;
  /// price = price.add(5.5); // 16.0
  /// ```
  double add(double value) => this + value;

  /// Subtracts a value from this double.
  ///
  /// Example:
  /// ```dart
  /// double price = 10.5;
  /// price = price.sub(3.2); // 7.3
  /// ```
  double sub(double value) => this - value;

  /// Multiplies this double by a value.
  ///
  /// Example:
  /// ```dart
  /// double price = 10.5;
  /// price = price.mul(2.0); // 21.0
  /// ```
  double mul(double value) => this * value;

  /// Divides this double by a value.
  ///
  /// Example:
  /// ```dart
  /// double price = 10.5;
  /// double result = price.div(2.0); // 5.25
  /// ```
  double div(double value) => this / value;

  /// Calculates what percentage this number is of another number.
  ///
  /// Example:
  /// ```dart
  /// double value = 25.0;
  /// double percentage = value.percent(of: 100.0); // 25.0
  /// ```
  double percent({required double of}) => (this / of) * 100;

  /// Applies a percentage to this number (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// double price = 100.0;
  /// double result = price.applyPercent(20); // 120.0 (100 + 20%)
  /// ```
  double applyPercent(double percent) => this * (1 + percent / 100);

  /// Applies a discount percentage to this number (subtracts percentage).
  ///
  /// Example:
  /// ```dart
  /// double price = 100.0;
  /// double result = price.discount(20); // 80.0 (100 - 20%)
  /// ```
  double discount(double percent) => this * (1 - percent / 100);

  /// Applies a tax percentage to this number (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// double price = 100.0;
  /// double result = price.tax(10); // 110.0 (100 + 10%)
  /// ```
  double tax(double percent) => this * (1 + percent / 100);

  /// Adds GST to this number.
  ///
  /// Example:
  /// ```dart
  /// double price = 100.0;
  /// double result = price.addGST(10); // 110.0
  /// ```
  double addGST(double percent) => this * (1 + percent / 100);

  /// Removes GST from this number.
  ///
  /// Example:
  /// ```dart
  /// double priceWithGST = 110.0;
  /// double result = priceWithGST.removeGST(10); // 100.0
  /// ```
  double removeGST(double percent) => this / (1 + percent / 100);

  /// Rounds this double to a specified number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// double value = 3.14159;
  /// double rounded = value.roundTo(2); // 3.14
  /// ```
  double roundTo(int decimals) {
    final multiplier = _powerOf10(decimals);
    return (this * multiplier).round() / multiplier;
  }

  /// Ceils this double to a specified number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// double value = 3.14159;
  /// double ceiled = value.ceilTo(2); // 3.15
  /// ```
  double ceilTo(int decimals) {
    final multiplier = _powerOf10(decimals);
    return (this * multiplier).ceil() / multiplier;
  }

  /// Floors this double to a specified number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// double value = 3.14159;
  /// double floored = value.floorTo(2); // 3.14
  /// ```
  double floorTo(int decimals) {
    final multiplier = _powerOf10(decimals);
    return (this * multiplier).floor() / multiplier;
  }

  /// Helper method to calculate power of 10.
  double _powerOf10(int exponent) {
    if (exponent <= 0) return 1.0;
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= 10.0;
    }
    return result;
  }

  /// Checks if this double is between [min] and [max] (inclusive).
  ///
  /// Example:
  /// ```dart
  /// double value = 50.5;
  /// bool isInRange = value.isBetween(0.0, 100.0); // true
  /// ```
  bool isBetween(double min, double max) => this >= min && this <= max;

  /// Clamps this double between [min] and [max].
  ///
  /// Returns a value that is at least [min] and at most [max].
  ///
  /// Example:
  /// ```dart
  /// double value = 150.5;
  /// value = value.clamped(min: 0.0, max: 100.0); // 100.0
  /// ```
  double clamped({required double min, required double max}) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Linear interpolation between this value and [end] at [t].
  ///
  /// Example:
  /// ```dart
  /// double start = 10.0;
  /// double result = start.lerp(20.0, 0.5); // 15.0
  /// ```
  double lerp(double end, double t) => this + (end - this) * t;

  /// Maps this value from one range [fromMin, fromMax] to another [toMin, toMax].
  ///
  /// Example:
  /// ```dart
  /// double value = 50.0;
  /// double mapped = value.mapRange(fromMin: 0.0, fromMax: 100.0, toMin: 0.0, toMax: 1.0); // 0.5
  /// ```
  double mapRange({
    required double fromMin,
    required double fromMax,
    required double toMin,
    required double toMax,
  }) {
    if (fromMax == fromMin) return toMin;
    final normalized = (this - fromMin) / (fromMax - fromMin);
    return toMin + normalized * (toMax - toMin);
  }

  /// Formats this double as currency.
  ///
  /// Example:
  /// ```dart
  /// double price = 1234.56;
  /// String formatted = price.toCurrency(); // '$1,234.56'
  /// ```
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    final parts = toStringAsFixed(decimals).split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';
    
    final formattedInteger = integerPart.replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    
    return '$symbol$formattedInteger${decimalPart.isNotEmpty ? '.$decimalPart' : ''}';
  }

  /// Formats this double as Indian Rupee (INR).
  ///
  /// Example:
  /// ```dart
  /// double price = 10000.50;
  /// String formatted = price.toINR(); // '₹10,000.50'
  /// ```
  String toINR() => Currency.inr.format(this);


  /// Formats this double using a specific currency.
  ///
  /// Example:
  /// ```dart
  /// double price = 1000.50;
  /// String formatted = price.toCurrencyType(Currency.inr); // '₹1,000.50'
  /// ```
  String toCurrencyType(Currency currency) => currency.format(this);

  /// Formats this double as a readable number with K, M, B, T suffixes.
  /// Automatically chooses the appropriate suffix based on value.
  ///
  /// Example:
  /// ```dart
  /// double value = 1500.0;
  /// String readable = value.toReadable(); // '1.5K'
  /// 1500000.0.toReadable(); // '1.5M'
  /// 1500000000.0.toReadable(); // '1.5B'
  /// 1500000000000.0.toReadable(); // '1.5T'
  /// ```
  String toReadable() {
    final absValue = abs();
    final isNegative = this < 0;
    final sign = isNegative ? '-' : '';
    
    if (absValue < 1000) {
      return '$sign${toStringAsFixed(absValue % 1 == 0 ? 0 : 2)}';
    }
    if (absValue < 1000000) return '$sign${(absValue / 1000).toStringAsFixed(1)}K';
    if (absValue < 1000000000) return '$sign${(absValue / 1000000).toStringAsFixed(1)}M';
    if (absValue < 1000000000000) return '$sign${(absValue / 1000000000).toStringAsFixed(1)}B';
    return '$sign${(absValue / 1000000000000).toStringAsFixed(1)}T';
  }

  /// Converts this double to an ordinal string (1st, 2nd, 3rd, etc.).
  ///
  /// Example:
  /// ```dart
  /// double value = 1.0;
  /// String ordinal = value.toOrdinal(); // '1st'
  /// ```
  String toOrdinal() {
    final intValue = round();
    final suffix = _getOrdinalSuffix(intValue);
    return '$intValue$suffix';
  }

  String _getOrdinalSuffix(int n) {
    final lastTwo = n % 100;
    final lastOne = n % 10;
    
    if (lastTwo >= 11 && lastTwo <= 13) {
      return 'th';
    }
    
    switch (lastOne) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }
}

/// Extension methods for [String] type.
extension StringExtensions on String {
  /// Capitalizes only the first letter of the string.
  ///
  /// Returns a new string with the first character capitalized and the rest unchanged.
  ///
  /// Example:
  /// ```dart
  /// String name = 'hello';
  /// name = name.capitalized; // 'Hello'
  ///
  /// String title = 'HELLO WORLD';
  /// title = title.capitalized; // 'HELLO WORLD' (only first letter)
  /// ```
  String get capitalized {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Adds (concatenates) a string to this string.
  ///
  /// Example:
  /// ```dart
  /// String name = 'Hello';
  /// name = name.add(' World'); // 'Hello World'
  /// ```
  String add(String value) => this + value;

  /// Returns a new string with the first character removed.
  ///
  /// Returns an empty string if the string is empty.
  ///
  /// Example:
  /// ```dart
  /// String name = 'Hello';
  /// name = name.dropFirst(); // 'ello'
  /// ```
  String dropFirst() {
    if (isEmpty) return this;
    return length > 1 ? substring(1) : '';
  }

  /// Returns a new string with the last character removed.
  ///
  /// Returns an empty string if the string is empty.
  ///
  /// Example:
  /// ```dart
  /// String name = 'Hello';
  /// name = name.dropLast(); // 'Hell'
  /// ```
  String dropLast() {
    if (isEmpty) return this;
    return length > 1 ? substring(0, length - 1) : '';
  }

  /// Removes all characters except digits (0-9).
  ///
  /// Example:
  /// ```dart
  /// String text = 'abc123def456';
  /// String numbers = text.numbersOnly; // '123456'
  /// ```
  String get numbersOnly => replaceAll(RegExp(r'[^0-9]'), '');

  /// Removes all characters except letters (a-z, A-Z).
  ///
  /// Example:
  /// ```dart
  /// String text = 'abc123def456';
  /// String letters = text.lettersOnly; // 'abcdef'
  /// ```
  String get lettersOnly => replaceAll(RegExp(r'[^a-zA-Z]'), '');

  /// Removes all characters except digits and decimal point (0-9 and .).
  ///
  /// This is useful for parsing numeric input that may contain commas or other formatting.
  ///
  /// Example:
  /// ```dart
  /// String text = '11,111.50';
  /// String cleaned = text.numbersWithDecimal; // '11111.50'
  /// 
  /// String price = '\$1,234.56';
  /// String numeric = price.numbersWithDecimal; // '1234.56'
  /// ```
  String get numbersWithDecimal {
    // Remove everything except digits and decimal point
    String cleaned = replaceAll(RegExp(r'[^0-9.]'), '');
    // Ensure only one decimal point
    final parts = cleaned.split('.');
    if (parts.length > 2) {
      // If multiple decimal points, keep only the first one
      cleaned = '${parts[0]}.${parts.sublist(1).join()}';
    }
    return cleaned;
  }

  /// Removes commas from the string.
  ///
  /// Useful for cleaning formatted numbers before parsing.
  ///
  /// Example:
  /// ```dart
  /// String text = '11,111';
  /// String cleaned = text.removeCommas; // '11111'
  /// ```
  String get removeCommas => replaceAll(',', '');

  /// Converts this string to a double, removing commas and other formatting first.
  ///
  /// Returns null if the string cannot be parsed as a number.
  ///
  /// Example:
  /// ```dart
  /// String text = '11,111.50';
  /// double? value = text.toDoubleSafe(); // 11111.50
  /// ```
  double? toDoubleSafe() {
    final cleaned = numbersWithDecimal;
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  /// Converts this string to an int, removing commas and other formatting first.
  ///
  /// Returns null if the string cannot be parsed as an integer.
  ///
  /// Example:
  /// ```dart
  /// String text = '11,111';
  /// int? value = text.toIntSafe(); // 11111
  /// ```
  int? toIntSafe() {
    final cleaned = numbersOnly;
    if (cleaned.isEmpty) return null;
    return int.tryParse(cleaned);
  }

  /// Parses a readable number string with K, M, B, T suffixes to a double.
  /// Automatically handles K (thousand), M (million), B (billion), T (trillion).
  ///
  /// Example:
  /// ```dart
  /// String text = '1.5K';
  /// double? value = text.fromReadable(); // 1500.0
  /// '1.5M'.fromReadable(); // 1500000.0
  /// '1.5B'.fromReadable(); // 1500000000.0
  /// '1.5T'.fromReadable(); // 1500000000000.0
  /// ```
  double? fromReadable() {
    if (isEmpty) return null;
    
    // Remove whitespace and convert to uppercase for case-insensitive matching
    final cleaned = trim().toUpperCase();
    
    // Check for negative sign
    final isNegative = cleaned.startsWith('-');
    final positiveValue = isNegative ? cleaned.substring(1) : cleaned;
    
    // Remove any non-numeric characters except decimal point and suffix letters
    final numberPart = positiveValue.replaceAll(RegExp(r'[^0-9.]'), '');
    if (numberPart.isEmpty) return null;
    
    // Try to parse the base number
    final baseValue = double.tryParse(numberPart);
    if (baseValue == null) return null;
    
    // Check for suffix (K, M, B, T)
    if (positiveValue.endsWith('K')) {
      return (isNegative ? -1 : 1) * baseValue * 1000;
    } else if (positiveValue.endsWith('M')) {
      return (isNegative ? -1 : 1) * baseValue * 1000000;
    } else if (positiveValue.endsWith('B')) {
      return (isNegative ? -1 : 1) * baseValue * 1000000000;
    } else if (positiveValue.endsWith('T')) {
      return (isNegative ? -1 : 1) * baseValue * 1000000000000;
    }
    
    // No suffix, return as-is
    return isNegative ? -baseValue : baseValue;
  }

  /// Parses a readable number string with K, M, B, T suffixes to an int.
  /// Returns null if the string cannot be parsed.
  ///
  /// Example:
  /// ```dart
  /// String text = '1.5K';
  /// int? value = text.fromReadableInt(); // 1500
  /// ```
  int? fromReadableInt() {
    final doubleValue = fromReadable();
    return doubleValue?.round();
  }
}

/// Extension methods for [List] type.
extension ListExtensions<T> on List<T> {
  /// Returns a new list with the first element removed.
  ///
  /// Returns an empty list if the list is empty or has only one element.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// numbers = numbers.dropFirst(); // [2, 3, 4, 5]
  /// ```
  List<T> dropFirst() {
    if (isEmpty) return [];
    if (length == 1) return [];
    return sublist(1);
  }

  /// Returns a new list with the last element removed.
  ///
  /// Returns an empty list if the list is empty or has only one element.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// numbers = numbers.dropLast(); // [1, 2, 3, 4]
  /// ```
  List<T> dropLast() {
    if (isEmpty) return [];
    if (length == 1) return [];
    return sublist(0, length - 1);
  }

  /// Checks whether any element satisfies the test function.
  ///
  /// Returns true if at least one element matches the condition.
  ///
  /// This is a Swift-like alias for Dart's `any` method.
  /// The `where` parameter is a function that takes an element and returns a boolean.
  ///
  /// Example:
  /// ```dart
  /// List<int> numbers = [1, 2, 3, 4, 5];
  /// bool hasLargeNumber = numbers.containsWhere((n) => n > 3); // true
  /// bool hasNegativeNumber = numbers.containsWhere((n) => n < 0); // false
  /// ```
  bool containsWhere(bool Function(T element) test) {
    return any(test);
  }
}

/// Extension methods for [Iterable] type (works for Lists, Sets, etc.).
extension IterableExtensions<T> on Iterable<T> {
  /// Returns a new iterable with the first element removed.
  ///
  /// Example:
  /// ```dart
  /// Iterable<int> numbers = [1, 2, 3];
  /// numbers = numbers.dropFirst(); // [2, 3]
  /// ```
  Iterable<T> dropFirst() {
    if (isEmpty) return [];
    return skip(1);
  }

  /// Returns a new iterable with the last element removed.
  ///
  /// Note: This creates a new iterable. For lists, prefer [ListExtensions.dropLast].
  ///
  /// Example:
  /// ```dart
  /// Iterable<int> numbers = [1, 2, 3];
  /// numbers = numbers.dropLast(); // [1, 2]
  /// ```
  Iterable<T> dropLast() {
    if (isEmpty) return [];
    if (length == 1) return [];
    return take(length - 1);
  }

  /// Checks whether any element satisfies the test function.
  ///
  /// This is a Swift-like alias for Dart's `any` method.
  ///
  /// Example:
  /// ```dart
  /// Iterable<int> numbers = [1, 2, 3, 4, 5];
  /// bool hasLargeNumber = numbers.containsWhere((n) => n > 3); // true
  /// ```
  bool containsWhere(bool Function(T element) test) {
    return any(test);
  }
}

/// Extension methods for Rx<int> to support arithmetic and financial operations on reactive values.
extension RxIntExtensions on Rx<int> {
  /// Adds a value to the reactive integer and updates it.
  ///
  /// Example:
  /// ```dart
  /// final counter = swift(10);
  /// counter.add(5); // counter.value is now 15
  /// ```
  void add(int value) {
    this.value = this.value + value;
  }

  /// Subtracts a value from the reactive integer and updates it.
  ///
  /// Example:
  /// ```dart
  /// final counter = swift(10);
  /// counter.sub(3); // counter.value is now 7
  /// ```
  void sub(int value) {
    this.value = this.value - value;
  }

  /// Multiplies the reactive integer by a value and updates it.
  ///
  /// Example:
  /// ```dart
  /// final counter = swift(10);
  /// counter.mul(3); // counter.value is now 30
  /// ```
  void mul(int value) {
    this.value = this.value * value;
  }

  /// Applies a percentage to the reactive integer (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100);
  /// price.applyPercent(20); // price.value is now 120
  /// ```
  void applyPercent(double percent) {
    value = (value * (1 + percent / 100)).round();
  }

  /// Applies a discount percentage to the reactive integer (subtracts percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100);
  /// price.discount(20); // price.value is now 80
  /// ```
  void discount(double percent) {
    value = (value * (1 - percent / 100)).round();
  }

  /// Applies a tax percentage to the reactive integer (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100);
  /// price.tax(10); // price.value is now 110
  /// ```
  void tax(double percent) {
    value = (value * (1 + percent / 100)).round();
  }

  /// Adds GST to the reactive integer.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100);
  /// price.addGST(10); // price.value is now 110
  /// ```
  void addGST(double percent) {
    value = (value * (1 + percent / 100)).round();
  }
}

/// Extension methods for Rx<double> to support arithmetic and financial operations on reactive values.
extension RxDoubleExtensions on Rx<double> {
  /// Adds a value to the reactive double and updates it.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(10.5);
  /// price.add(5.5); // price.value is now 16.0
  /// ```
  void add(double value) {
    this.value = this.value + value;
  }

  /// Subtracts a value from the reactive double and updates it.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(10.5);
  /// price.sub(3.2); // price.value is now 7.3
  /// ```
  void sub(double value) {
    this.value = this.value - value;
  }

  /// Multiplies the reactive double by a value and updates it.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(10.5);
  /// price.mul(2.0); // price.value is now 21.0
  /// ```
  void mul(double value) {
    this.value = this.value * value;
  }

  /// Applies a percentage to the reactive double (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100.0);
  /// price.applyPercent(20); // price.value is now 120.0
  /// ```
  void applyPercent(double percent) {
    this.value = this.value * (1 + percent / 100);
  }

  /// Applies a discount percentage to the reactive double (subtracts percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100.0);
  /// price.discount(20); // price.value is now 80.0
  /// ```
  void discount(double percent) {
    this.value = this.value * (1 - percent / 100);
  }

  /// Applies a tax percentage to the reactive double (adds percentage).
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100.0);
  /// price.tax(10); // price.value is now 110.0
  /// ```
  void tax(double percent) {
    this.value = this.value * (1 + percent / 100);
  }

  /// Adds GST to the reactive double.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(100.0);
  /// price.addGST(10); // price.value is now 110.0
  /// ```
  void addGST(double percent) {
    this.value = this.value * (1 + percent / 100);
  }

  /// Removes GST from the reactive double.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(110.0);
  /// price.removeGST(10); // price.value is now 100.0
  /// ```
  void removeGST(double percent) {
    this.value = this.value / (1 + percent / 100);
  }

  /// Rounds the reactive double to a specified number of decimal places.
  ///
  /// Example:
  /// ```dart
  /// final price = swift(3.14159);
  /// price.roundTo(2); // price.value is now 3.14
  /// ```
  void roundTo(int decimals) {
    final multiplier = _powerOf10(decimals);
    this.value = (this.value * multiplier).round() / multiplier;
  }

  double _powerOf10(int exponent) {
    if (exponent <= 0) return 1.0;
    double result = 1.0;
    for (int i = 0; i < exponent; i++) {
      result *= 10.0;
    }
    return result;
  }
}

/// Extension methods for Rx<String> to support string operations on reactive values.
extension RxStringExtensions on Rx<String> {
  /// Adds (concatenates) a string to the reactive string and updates it.
  ///
  /// Example:
  /// ```dart
  /// final name = swift('Hello');
  /// name.add(' World'); // name.value is now 'Hello World'
  /// ```
  void add(String value) {
    this.value = this.value + value;
  }
}

/// Extension methods for Rx<bool> to support toggle operation on reactive values.
extension RxBoolExtensions on Rx<bool> {
  /// Toggles the reactive boolean value.
  ///
  /// Example:
  /// ```dart
  /// final flag = swift(true);
  /// flag.toggle(); // flag.value is now false
  /// flag.toggle(); // flag.value is now true
  /// ```
  void toggle() {
    value = !value;
  }
}

