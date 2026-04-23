import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final MockBankApi mockBankApi;

  const AuthRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await mockBankApi.login(
        email: email,
        password: password,
      );
      return UserModel.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      throw const ServerException(message: 'Error al iniciar sesión');
    }
  }
}
