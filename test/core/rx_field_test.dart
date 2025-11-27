import 'package:flutter_test/flutter_test.dart';
import 'package:swift_flutter/core/rx_field.dart';

void main() {
  group('RxField', () {
    test('should initialize with value', () {
      final field = RxField<String>('test');
      expect(field.value, 'test');
      expect(field.error, null);
      expect(field.isValid, true);
    });

    test('should validate with required validator', () {
      final field = RxField<String>('');
      field.addValidator(Validators.required());
      
      expect(field.validate(), false);
      expect(field.error, 'This field is required');
      expect(field.isValid, false);
    });

    test('should validate with minLength', () {
      final field = RxField<String>('ab');
      field.addValidator(Validators.minLength(5));
      
      expect(field.validate(), false);
      expect(field.error, 'Must be at least 5 characters');
    });

    test('should validate with email', () {
      final field = RxField<String>('invalid-email');
      field.addValidator(Validators.email());
      
      expect(field.validate(), false);
      expect(field.error, 'Invalid email address');
      
      field.value = 'test@example.com';
      expect(field.validate(), true);
      expect(field.error, null);
    });

    test('should mark as touched', () {
      final field = RxField<String>('');
      field.addValidator(Validators.required());
      
      expect(field.touched, false);
      field.markAsTouched();
      expect(field.touched, true);
      expect(field.error, isNotNull);
    });

    test('should auto-validate after touch', () {
      final field = RxField<String>('');
      field.addValidator(Validators.required());
      field.markAsTouched();
      
      field.value = 'new value';
      expect(field.error, null); // Should auto-validate
    });

    test('should reset field', () {
      final field = RxField<String>('');
      field.addValidator(Validators.required());
      field.markAsTouched();
      
      field.reset();
      expect(field.touched, false);
      expect(field.error, null);
    });
  });
}

