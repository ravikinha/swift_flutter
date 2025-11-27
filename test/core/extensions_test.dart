import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/extensions.dart';
import 'package:swift_flutter/core/rx.dart';

void main() {
  group('BoolExtensions', () {
    test('toggle() should return false when true', () {
      bool flag = true;
      expect(flag.toggle(), false);
    });

    test('toggle() should return true when false', () {
      bool flag = false;
      expect(flag.toggle(), true);
    });

    test('toggle() should not mutate the original value', () {
      bool flag = true;
      flag.toggle(); // This returns a new value
      expect(flag, true); // Original is unchanged
    });
  });

  group('IntExtensions', () {
    test('add() should add values correctly', () {
      int count = 10;
      expect(count.add(5), 15);
      expect(count.add(-3), 7);
      expect(count.add(0), 10);
    });

    test('sub() should subtract values correctly', () {
      int count = 10;
      expect(count.sub(5), 5);
      expect(count.sub(-3), 13);
      expect(count.sub(0), 10);
    });

    test('clamped() should clamp values within range', () {
      expect(150.clamped(min: 0, max: 100), 100);
      expect(50.clamped(min: 0, max: 100), 50);
      expect((-10).clamped(min: 0, max: 100), 0);
      expect(0.clamped(min: 0, max: 100), 0);
      expect(100.clamped(min: 0, max: 100), 100);
    });

    test('clamped() should not mutate the original value', () {
      int value = 150;
      value.clamped(min: 0, max: 100);
      expect(value, 150); // Original is unchanged
    });
  });

  group('DoubleExtensions', () {
    test('add() should add values correctly', () {
      double price = 10.5;
      expect(price.add(5.5), 16.0);
      expect(price.add(-3.2), 7.3);
      expect(price.add(0.0), 10.5);
    });

    test('sub() should subtract values correctly', () {
      double price = 10.5;
      expect(price.sub(5.5), 5.0);
      expect(price.sub(-3.2), 13.7);
      expect(price.sub(0.0), 10.5);
    });

    test('clamped() should clamp values within range', () {
      expect(150.5.clamped(min: 0.0, max: 100.0), 100.0);
      expect(50.5.clamped(min: 0.0, max: 100.0), 50.5);
      expect((-10.5).clamped(min: 0.0, max: 100.0), 0.0);
    });
  });


  group('StringExtensions', () {
    test('capitalized should capitalize only first letter', () {
      expect('hello'.capitalized, 'Hello');
      expect('HELLO'.capitalized, 'HELLO'); // Only first letter
      expect('hello world'.capitalized, 'Hello world');
      expect('h'.capitalized, 'H');
    });

    test('capitalized should handle empty string', () {
      expect(''.capitalized, '');
    });

    test('capitalized should not mutate the original string', () {
      String name = 'hello';
      name.capitalized; // This returns a new value
      expect(name, 'hello'); // Original is unchanged
    });

    test('add() should concatenate strings', () {
      String name = 'Hello';
      expect(name.add(' World'), 'Hello World');
      expect(name.add(''), 'Hello');
      expect(name.add('!'), 'Hello!');
    });

    test('dropFirst() should remove first character', () {
      expect('Hello'.dropFirst(), 'ello');
      expect('H'.dropFirst(), '');
      expect(''.dropFirst(), '');
    });

    test('dropLast() should remove last character', () {
      expect('Hello'.dropLast(), 'Hell');
      expect('H'.dropLast(), '');
      expect(''.dropLast(), '');
    });

    test('dropFirst() and dropLast() should not mutate original', () {
      String name = 'Hello';
      name.dropFirst();
      name.dropLast();
      expect(name, 'Hello'); // Original is unchanged
    });
  });

  group('ListExtensions', () {
    test('dropFirst() should remove first element', () {
      List<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.dropFirst(), [2, 3, 4, 5]);
      
      List<String> strings = ['a', 'b', 'c'];
      expect(strings.dropFirst(), ['b', 'c']);
    });

    test('dropFirst() should handle edge cases', () {
      expect([1].dropFirst(), []);
      expect(<int>[].dropFirst(), []);
    });

    test('dropLast() should remove last element', () {
      List<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.dropLast(), [1, 2, 3, 4]);
      
      List<String> strings = ['a', 'b', 'c'];
      expect(strings.dropLast(), ['a', 'b']);
    });

    test('dropLast() should handle edge cases', () {
      expect([1].dropLast(), []);
      expect(<int>[].dropLast(), []);
    });

    test('dropFirst() and dropLast() should not mutate original list', () {
      List<int> numbers = [1, 2, 3, 4, 5];
      numbers.dropFirst();
      numbers.dropLast();
      expect(numbers, [1, 2, 3, 4, 5]); // Original is unchanged
    });

    test('containsWhere() should find matching elements', () {
      List<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.containsWhere((n) => n > 3), true);
      expect(numbers.containsWhere((n) => n > 10), false);
      expect(numbers.containsWhere((n) => n == 3), true);
    });

    test('containsWhere() should work with strings', () {
      List<String> names = ['John', 'Jane', 'Bob'];
      expect(names.containsWhere((n) => n.startsWith('J')), true);
      expect(names.containsWhere((n) => n.length > 10), false);
    });
  });

  group('IterableExtensions', () {
    test('dropFirst() should work with iterables', () {
      Iterable<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.dropFirst().toList(), [2, 3, 4, 5]);
    });

    test('dropLast() should work with iterables', () {
      Iterable<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.dropLast().toList(), [1, 2, 3, 4]);
    });

    test('containsWhere() should work with iterables', () {
      Iterable<int> numbers = [1, 2, 3, 4, 5];
      expect(numbers.containsWhere((n) => n > 3), true);
      expect(numbers.containsWhere((n) => n > 10), false);
    });

    test('dropFirst() and dropLast() should work with Sets', () {
      Set<int> numbers = {1, 2, 3, 4, 5};
      // Note: Sets are unordered, so we check length
      expect(numbers.dropFirst().length, 4);
      expect(numbers.dropLast().length, 4);
    });
  });

  group('RxIntExtensions', () {
    test('add() should update reactive integer', () {
      final counter = swift(10);
      counter.add(5);
      expect(counter.value, 15);
      
      counter.add(-3);
      expect(counter.value, 12);
    });

    test('sub() should update reactive integer', () {
      final counter = swift(10);
      counter.sub(3);
      expect(counter.value, 7);
      
      counter.sub(-5);
      expect(counter.value, 12);
    });
  });

  group('RxDoubleExtensions', () {
    test('add() should update reactive double', () {
      final price = swift(10.5);
      price.add(5.5);
      expect(price.value, 16.0);
      
      price.add(-3.2);
      expect(price.value, 12.8);
    });

    test('sub() should update reactive double', () {
      final price = swift(10.5);
      price.sub(3.2);
      expect(price.value, 7.3);
      
      price.sub(-2.5);
      expect(price.value, 9.8);
    });
  });

  group('RxStringExtensions', () {
    test('add() should concatenate reactive string', () {
      final name = swift('Hello');
      name.add(' World');
      expect(name.value, 'Hello World');
      
      name.add('!');
      expect(name.value, 'Hello World!');
    });

    test('add() should work with empty string', () {
      final name = swift('Hello');
      name.add('');
      expect(name.value, 'Hello');
    });
  });

  group('RxBoolExtensions', () {
    test('toggle() should toggle reactive boolean', () {
      final flag = swift(true);
      flag.toggle();
      expect(flag.value, false);
      
      flag.toggle();
      expect(flag.value, true);
    });

    test('toggle() should work with false initial value', () {
      final flag = swift(false);
      flag.toggle();
      expect(flag.value, true);
    });
  });

  group('String Cleaning Extensions', () {
    test('numbersOnly should keep only digits', () {
      expect('abc123def456'.numbersOnly, '123456');
      expect('hello'.numbersOnly, '');
      expect('12345'.numbersOnly, '12345');
      expect('abc123!@#456'.numbersOnly, '123456');
    });

    test('lettersOnly should keep only letters', () {
      expect('abc123def456'.lettersOnly, 'abcdef');
      expect('hello'.lettersOnly, 'hello');
      expect('12345'.lettersOnly, '');
      expect('Hello World 123!'.lettersOnly, 'HelloWorld');
    });

    test('numbersWithDecimal should keep digits and decimal point', () {
      expect('11,111.50'.numbersWithDecimal, '11111.50');
      expect('\$1,234.56'.numbersWithDecimal, '1234.56');
      expect('123.45.67'.numbersWithDecimal, '123.4567');
      expect('abc123.45def'.numbersWithDecimal, '123.45');
      expect('hello'.numbersWithDecimal, '');
      expect('123'.numbersWithDecimal, '123');
    });

    test('numbersWithDecimal should handle multiple decimal points', () {
      expect('12.34.56'.numbersWithDecimal, '12.3456');
      expect('.123'.numbersWithDecimal, '.123');
      expect('123.'.numbersWithDecimal, '123.');
    });

    test('removeCommas should remove all commas', () {
      expect('11,111'.removeCommas, '11111');
      expect('1,234,567'.removeCommas, '1234567');
      expect('123'.removeCommas, '123');
      expect('hello,world'.removeCommas, 'helloworld');
    });

    test('toDoubleSafe should parse strings with commas', () {
      expect('11,111.50'.toDoubleSafe(), 11111.50);
      expect('\$1,234.56'.toDoubleSafe(), 1234.56);
      expect('1234'.toDoubleSafe(), 1234.0);
      expect('abc'.toDoubleSafe(), null);
      expect(''.toDoubleSafe(), null);
    });

    test('toIntSafe should parse strings with commas', () {
      expect('11,111'.toIntSafe(), 11111);
      expect('1,234,567'.toIntSafe(), 1234567);
      expect('123'.toIntSafe(), 123);
      expect('abc'.toIntSafe(), null);
      expect(''.toIntSafe(), null);
    });
  });

  group('Readable Format Extensions', () {
    test('toReadable() should format with K suffix', () {
      expect(1500.toReadable(), '1.5K');
      expect(1000.toReadable(), '1.0K');
      expect(999.toReadable(), '999');
      expect(150000.toReadable(), '150.0K');
    });

    test('toReadable() should format with M suffix', () {
      expect(1500000.toReadable(), '1.5M');
      expect(1000000.toReadable(), '1.0M');
      expect(999999.toReadable(), '1000.0K');
    });

    test('toReadable() should format with B suffix', () {
      expect(1500000000.toReadable(), '1.5B');
      expect(1000000000.toReadable(), '1.0B');
    });

    test('toReadable() should format with T suffix', () {
      expect(1500000000000.toReadable(), '1.5T');
      expect(1000000000000.toReadable(), '1.0T');
    });

    test('toReadable() should handle negative numbers', () {
      expect((-1500).toReadable(), '-1.5K');
      expect((-1500000).toReadable(), '-1.5M');
    });

    test('fromReadable() should parse K suffix', () {
      expect('1.5K'.fromReadable(), 1500.0);
      expect('1K'.fromReadable(), 1000.0);
      expect('150K'.fromReadable(), 150000.0);
      expect('1.5k'.fromReadable(), 1500.0); // Case insensitive
    });

    test('fromReadable() should parse M suffix', () {
      expect('1.5M'.fromReadable(), 1500000.0);
      expect('1M'.fromReadable(), 1000000.0);
      expect('1.5m'.fromReadable(), 1500000.0); // Case insensitive
    });

    test('fromReadable() should parse B suffix', () {
      expect('1.5B'.fromReadable(), 1500000000.0);
      expect('1B'.fromReadable(), 1000000000.0);
      expect('1.5b'.fromReadable(), 1500000000.0); // Case insensitive
    });

    test('fromReadable() should parse T suffix', () {
      expect('1.5T'.fromReadable(), 1500000000000.0);
      expect('1T'.fromReadable(), 1000000000000.0);
      expect('1.5t'.fromReadable(), 1500000000000.0); // Case insensitive
    });

    test('fromReadable() should handle negative numbers', () {
      expect('-1.5K'.fromReadable(), -1500.0);
      expect('-1.5M'.fromReadable(), -1500000.0);
    });

    test('fromReadable() should parse numbers without suffix', () {
      expect('1500'.fromReadable(), 1500.0);
      expect('1234.56'.fromReadable(), 1234.56);
    });

    test('fromReadable() should return null for invalid input', () {
      expect('abc'.fromReadable(), null);
      expect(''.fromReadable(), null);
      expect('K'.fromReadable(), null);
    });

    test('fromReadableInt() should parse to integer', () {
      expect('1.5K'.fromReadableInt(), 1500);
      expect('1.5M'.fromReadableInt(), 1500000);
      expect('1.5B'.fromReadableInt(), 1500000000);
      expect('1.5T'.fromReadableInt(), 1500000000000);
    });

    test('Round-trip: toReadable then fromReadable', () {
      final values = [1500, 1500000, 1500000000, 1500000000000];
      for (final value in values) {
        final readable = value.toReadable();
        final parsed = readable.fromReadable();
        expect(parsed, closeTo(value.toDouble(), 0.1));
      }
    });
  });

  group('Real-world examples', () {
    test('String cleanup example - dropFirst()', () {
      // Before: username = username.substring(1);
      // After: username = username.dropFirst();
      String username = 'hello';
      username = username.dropFirst();
      expect(username, 'ello');
    });

    test('Value count operations', () {
      int valueCount = 10;
      valueCount = valueCount.add(30);
      expect(valueCount, 40);
      
      valueCount = valueCount.sub(10);
      expect(valueCount, 30);
      
      valueCount = valueCount.clamped(min: 0, max: 50);
      expect(valueCount, 30);
    });

    test('Reactive value count operations', () {
      final valueCount = swift(10);
      valueCount.add(30);
      expect(valueCount.value, 40);
      
      valueCount.sub(10);
      expect(valueCount.value, 30);
    });

    test('String operations with reactive values', () {
      final username = swift('hello');
      username.add(' world');
      expect(username.value, 'hello world');
      
      username.value = username.value.dropFirst();
      expect(username.value, 'ello world');
      
      username.value = username.value.dropLast();
      expect(username.value, 'ello worl');
    });

    test('List operations with reactive values', () {
      final numbers = swift<List<int>>([1, 2, 3, 4, 5]);
      numbers.value = numbers.value.dropFirst();
      expect(numbers.value, [2, 3, 4, 5]);
      
      numbers.value = numbers.value.dropLast();
      expect(numbers.value, [2, 3, 4]);
      
      expect(numbers.value.containsWhere((n) => n > 3), true);
    });

    test('Bool toggle in UI scenario', () {
      final isVisible = swift(true);
      isVisible.toggle(); // Hide
      expect(isVisible.value, false);
      
      isVisible.toggle(); // Show
      expect(isVisible.value, true);
    });

    test('Clamped prevents unsafe values', () {
      int userScore = 150;
      int displayScore = userScore.clamped(min: 0, max: 100);
      expect(displayScore, 100);
      
      int negativeScore = -10;
      int safeScore = negativeScore.clamped(min: 0, max: 100);
      expect(safeScore, 0);
    });

    test('Capitalized for UI text formatting', () {
      String userName = 'john doe';
      String displayName = userName.capitalized;
      expect(displayName, 'John doe'); // Only first letter
      
      String title = 'hello world';
      String formattedTitle = title.capitalized;
      expect(formattedTitle, 'Hello world');
    });
  });
}

