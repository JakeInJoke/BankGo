import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/transactions/domain/entities/transfer_recipient.dart';

abstract class TransferRemoteDataSource {
  Future<TransferRecipient> validateDestinationAccount(String accountNumber);

  Future<String> requestSecurityToken();

  Future<void> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  });
}

class TransferRemoteDataSourceImpl implements TransferRemoteDataSource {
  final MockBankApi mockBankApi;

  const TransferRemoteDataSourceImpl({required this.mockBankApi});

  @override
  Future<TransferRecipient> validateDestinationAccount(
    String accountNumber,
  ) async {
    final isValid = await mockBankApi.validateAccount(accountNumber);
    if (!isValid) {
      throw const ServerException(
        message:
            'Cuenta no verificada o inexistente. Valida la informacion y vuelve a intentarlo',
      );
    }
    final recipient =
        await mockBankApi.getVerifiedDestinationAccount(accountNumber);
    if (recipient == null) {
      throw const ServerException(
        message:
            'Cuenta no verificada o inexistente. Valida la informacion y vuelve a intentarlo',
      );
    }
    return TransferRecipient(
      accountNumber: recipient['account_number'] ?? accountNumber,
      holderName: recipient['holder_name'] ?? 'Destinatario verificado',
      bankName: recipient['bank_name'] ?? 'Banco mock',
      alias: recipient['alias'],
    );
  }

  @override
  Future<String> requestSecurityToken() => mockBankApi.requestSecurityToken();

  @override
  Future<void> submitTransfer({
    required String beneficiary,
    required String sourceAccountId,
    required double amount,
    required String token,
  }) async {
    await mockBankApi.submitTransfer(
      beneficiary: beneficiary,
      sourceAccountId: sourceAccountId,
      amount: amount,
      token: token,
    );
  }
}
