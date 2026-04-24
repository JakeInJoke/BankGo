import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for valid emails', () {
        expect(Validators.validateEmail('test@example.com'), isNull);
        expect(Validators.validateEmail('user.name+tag@domain.co'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
        expect(Validators.validateEmail('   '), isNotNull);
      });

      test('returns error for invalid email formats', () {
        expect(Validators.validateEmail('plainaddress'), isNotNull);
        expect(Validators.validateEmail('@missingusername.com'), isNotNull);
        expect(Validators.validateEmail('username@.com'), isNotNull);
        expect(Validators.validateEmail('username@domain.'), isNotNull);
      });
    });

    group('validatePassword', () {
      test('returns null for valid passwords (>= 8 chars)', () {
        expect(Validators.validatePassword('Password123!'), isNull);
      });

      test('returns error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('returns error for password < 8 characters', () {
        expect(Validators.validatePassword('pass1!A'), isNotNull);
        expect(Validators.validatePassword('1234567'), isNotNull);
      });
    });

    group('validateRequired', () {
      test('returns null for non-empty string', () {
        expect(Validators.validateRequired('value'), isNull);
      });

      test('returns error for empty string', () {
        expect(Validators.validateRequired(''), isNotNull);
        expect(Validators.validateRequired(null), isNotNull);
        expect(Validators.validateRequired('   '), isNotNull);
      });

      test('includes field name in error message if provided', () {
        final error = Validators.validateRequired('', fieldName: 'Nombre');
        expect(error, contains('Nombre'));
      });
    });

    group('validateAmount', () {
      test('returns null for valid amounts', () {
        expect(Validators.validateAmount('100'), isNull);
        expect(Validators.validateAmount('10.50'), isNull);
        expect(Validators.validateAmount('1,000.50'), isNull);
      });

      test('returns error for empty amount', () {
        expect(Validators.validateAmount(''), isNotNull);
        expect(Validators.validateAmount(null), isNotNull);
      });

      test('returns error for zero or negative amounts', () {
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('0.0'), isNotNull);
        expect(Validators.validateAmount('-50'), isNotNull);
      });

      test('returns error for non-numeric input', () {
        expect(Validators.validateAmount('abc'), isNotNull);
        expect(Validators.validateAmount('10a'), isNotNull);
      });
    });

    group('validatePhone', () {
      test('returns null for valid phone numbers', () {
        expect(Validators.validatePhone('1234567890'), isNull);
        expect(Validators.validatePhone('+123456789012'), isNull);
      });

      test('returns error for empty phone', () {
        expect(Validators.validatePhone(''), isNotNull);
        expect(Validators.validatePhone(null), isNotNull);
      });

      test('returns error for invalid phone formats', () {
        expect(Validators.validatePhone('12345'), isNotNull); // too short
        expect(Validators.validatePhone('1234567890123456'),
            isNotNull); // too long
        expect(Validators.validatePhone('abcdefghij'), isNotNull); // not digits
      });
    });

    group('isValidEmail', () {
      test('returns true for valid emails', () {
        expect(Validators.isValidEmail('test@example.com'), isTrue);
      });

      test('returns false for invalid emails', () {
        expect(Validators.isValidEmail('invalid'), isFalse);
      });
    });

    group('isValidPassword', () {
      test('returns true for passwords >= 8 chars', () {
        expect(Validators.isValidPassword('Password123!'), isTrue);
      });

      test('returns false for passwords < 8 chars', () {
        expect(Validators.isValidPassword('pass'), isFalse);
      });
    });
  });
}
