// test/unit_test/validation_test.dart

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Form Validation Tests', () {
    // Simulate the validator function from settings_screen.dart
    String? validateDisplayName(String? value) {
      if (value == null || value.isEmpty) {
        return 'Name is required';
      }
      if (value.length < 6) {
        return 'Minimum 6 characters';
      }
      return null;
    }

    test('should return error when value is null', () {
      final result = validateDisplayName(null);
      expect(result, 'Name is required');
    });

    test('should return error when value is empty', () {
      final result = validateDisplayName('');
      expect(result, 'Name is required');
    });

    test('should return error when value is less than 6 characters', () {
      final result = validateDisplayName('John');
      expect(result, 'Minimum 6 characters');
    });

    test('should return null when value is exactly 6 characters', () {
      final result = validateDisplayName('Johnny');
      expect(result, isNull);
    });

    test('should return null when value is more than 6 characters', () {
      final result = validateDisplayName('Johnny123');
      expect(result, isNull);
    });

    test('should count spaces as characters', () {
      final result = validateDisplayName('John D');
      expect(result, isNull); // 7 characters including space
    });
  });
}