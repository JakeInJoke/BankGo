import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';

void main() {
  group('User entity', () {
    const user = User(
      id: '1',
      name: 'Juan Pérez',
      email: 'juan@example.com',
      phone: '+521234567890',
    );

    test('copyWith returns updated instance', () {
      final updated = user.copyWith(name: 'María García');
      expect(updated.name, 'María García');
      expect(updated.email, user.email);
      expect(updated.id, user.id);
    });

    test('equality is based on props', () {
      const sameUser = User(
        id: '1',
        name: 'Juan Pérez',
        email: 'juan@example.com',
        phone: '+521234567890',
      );
      expect(user, equals(sameUser));
    });

    test('inequality when id differs', () {
      const differentUser = User(
        id: '2',
        name: 'Juan Pérez',
        email: 'juan@example.com',
      );
      expect(user, isNot(equals(differentUser)));
    });
  });
}
