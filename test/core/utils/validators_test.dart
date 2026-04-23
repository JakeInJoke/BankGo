import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('validateEmail', () {
      test('returns null for a valid email', () {
        expect(Validators.validateEmail('user@example.com'), isNull);
        expect(Validators.validateEmail('test.user+tag@domain.co'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.validateEmail(''), isNotNull);
        expect(Validators.validateEmail(null), isNotNull);
      });

      test('returns error for invalid email format', () {
        expect(Validators.validateEmail('invalid'), isNotNull);
        expect(Validators.validateEmail('no@domain'), isNotNull);
        expect(Validators.validateEmail('@domain.com'), isNotNull);
      });
    });

    group('validatePassword', () {
      test('returns null for a valid password (>= 8 chars)', () {
        expect(Validators.validatePassword('securePass1'), isNull);
        expect(Validators.validatePassword('12345678'), isNull);
      });

      test('returns error for empty password', () {
        expect(Validators.validatePassword(''), isNotNull);
        expect(Validators.validatePassword(null), isNotNull);
      });

      test('returns error for password shorter than 8 characters', () {
        expect(Validators.validatePassword('abc'), isNotNull);
        expect(Validators.validatePassword('1234567'), isNotNull);
      });
    });

    group('validateAmount', () {
      test('returns null for a valid amount', () {
        expect(Validators.validateAmount('100'), isNull);
        expect(Validators.validateAmount('0.01'), isNull);
      });

      test('returns error for empty amount', () {
        expect(Validators.validateAmount(''), isNotNull);
        expect(Validators.validateAmount(null), isNotNull);
      });

      test('returns error for zero or negative amounts', () {
        expect(Validators.validateAmount('0'), isNotNull);
        expect(Validators.validateAmount('-10'), isNotNull);
      });

      test('returns error for non-numeric strings', () {
        expect(Validators.validateAmount('abc'), isNotNull);
      });
    });

    group('isValidEmail', () {
      test('returns true for valid emails', () {
        expect(Validators.isValidEmail('valid@email.com'), isTrue);
      });

      test('returns false for invalid emails', () {
        expect(Validators.isValidEmail('not-an-email'), isFalse);
      });
    });

    group('isValidPassword', () {
      test('returns true when password has 8+ chars', () {
        expect(Validators.isValidPassword('password1'), isTrue);
      });

      test('returns false when password is shorter than 8 chars', () {
        expect(Validators.isValidPassword('pass'), isFalse);
      });
    });
  });
}
