import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/core/utils/pkce_helper.dart';
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
      // Generate PKCE code_verifier and code_challenge
      final pkceCodePair = PkceHelper.generatePkceCodePair();
      final codeChallenge = pkceCodePair['challenge']!;

      // In a real OAuth2 flow, the code_verifier would be stored securely
      // and sent later during token exchange. For this mock, we store it
      // as a demonstration of PKCE flow.
      _storedCodeVerifier = pkceCodePair['verifier'];

      final response = await mockBankApi.login(
        email: email,
        password: password,
        codeChallenge: codeChallenge,
      );
      return UserModel.fromJson(response);
    } on UnauthorizedException {
      rethrow;
    } catch (_) {
      throw const ServerException(message: 'Error al iniciar sesión');
    }
  }

  // Simulated storage for PKCE code_verifier (in production, use flutter_secure_storage)
  static String? _storedCodeVerifier;
}
