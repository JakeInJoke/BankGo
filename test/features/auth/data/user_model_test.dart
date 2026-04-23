import 'package:flutter_test/flutter_test.dart';
import 'package:bank_go/features/auth/data/models/user_model.dart';
import 'package:bank_go/features/auth/domain/entities/user.dart';

void main() {
  group('UserModel', () {
    const testJson = {
      'id': '1',
      'name': 'Juan Pérez',
      'email': 'juan@example.com',
      'phone': '+521234567890',
      'avatar_url': null,
      'token': 'abc123',
    };

    test('fromJson creates model with correct values', () {
      final model = UserModel.fromJson(testJson);
      expect(model.id, '1');
      expect(model.name, 'Juan Pérez');
      expect(model.email, 'juan@example.com');
      expect(model.phone, '+521234567890');
      expect(model.token, 'abc123');
    });

    test('toJson serializes correctly', () {
      final model = UserModel.fromJson(testJson);
      final json = model.toJson();
      expect(json['id'], '1');
      expect(json['email'], 'juan@example.com');
      expect(json['token'], 'abc123');
    });

    test('fromEntity creates model from User entity', () {
      const user = User(
        id: '2',
        name: 'María García',
        email: 'maria@example.com',
      );
      final model = UserModel.fromEntity(user);
      expect(model.id, user.id);
      expect(model.name, user.name);
      expect(model.email, user.email);
    });

    test('is a subtype of User', () {
      final model = UserModel.fromJson(testJson);
      expect(model, isA<User>());
    });
  });
}
