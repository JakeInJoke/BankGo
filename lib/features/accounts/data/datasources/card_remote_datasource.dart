import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/accounts/domain/entities/card_details.dart';

abstract class CardRemoteDataSource {
  Future<CardDetails> getCardDetails(String accountId);

  Future<String> requestSecurityToken({String? accountId});

  Future<void> toggleCardFreeze({
    required String accountId,
    required bool freeze,
    required String token,
  });
}

class CardRemoteDataSourceImpl implements CardRemoteDataSource {
  final MockBankApi mockBankApi;

  const CardRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<CardDetails> getCardDetails(String accountId) async {
    try {
      final details = await mockBankApi.getCardDetails(accountId);
      return CardDetails(
        cardNumber: details['card_number'] as String,
        cardHolder: details['card_holder'] as String?,
        expirationDate: details['expiration_date'] as String,
        cvv: details['cvv'] as String,
        type: details['type'] as String?,
        isEnabled: details['is_enabled'] as bool? ?? true,
      );
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException(
        message: 'Error al obtener los detalles de la tarjeta.',
      );
    }
  }

  @override
  Future<String> requestSecurityToken({String? accountId}) async {
    try {
      return await mockBankApi.requestSecurityToken(accountId: accountId);
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException(
        message: 'Error al solicitar el token de seguridad.',
      );
    }
  }

  @override
  Future<void> toggleCardFreeze({
    required String accountId,
    required bool freeze,
    required String token,
  }) async {
    try {
      await mockBankApi.toggleCardFreeze(
        accountId: accountId,
        freeze: freeze,
        token: token,
      );
    } on ServerException {
      rethrow;
    } catch (_) {
      throw const ServerException(
        message: 'Error al actualizar el estado de la tarjeta.',
      );
    }
  }
}
