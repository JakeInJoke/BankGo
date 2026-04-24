import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bank_go/core/mocks/mock_bank_api.dart';
import 'package:bank_go/features/transactions/presentation/bloc/transfer_event_state.dart';

class TransferBloc extends Bloc<TransferEvent, TransferState> {
  final MockBankApi _api;

  TransferBloc(this._api) : super(const TransferState()) {
    on<UpdateDestinationAccount>(_onUpdateDestinationAccount);
    on<UpdateTransferDetails>(_onUpdateTransferDetails);
    on<RequestToken>(_onRequestToken);
    on<SubmitTransfer>(_onSubmitTransfer);
    on<ResetTransfer>(_onResetTransfer);
  }

  Future<void> _onUpdateDestinationAccount(
      UpdateDestinationAccount event, Emitter<TransferState> emit) async {
    emit(state.copyWith(
        status: TransferStatus.validatingAccount,
        destinationAccount: event.accountNumber,
        destinationAccountName: null,
        destinationBankName: null,
        isDestinationVerified: false,
        error: null));
    final isValid = await _api.validateAccount(event.accountNumber);
    if (isValid) {
      final recipient =
          await _api.getVerifiedDestinationAccount(event.accountNumber);
      emit(state.copyWith(
        status: TransferStatus.accountValid,
        destinationAccount: event.accountNumber,
        destinationAccountName: recipient?['holder_name'],
        destinationBankName: recipient?['bank_name'],
        isDestinationVerified: true,
        error: null,
      ));
    } else {
      emit(state.copyWith(
          status: TransferStatus.error,
          isDestinationVerified: false,
          error:
              'Cuenta no verificada. Usa una cuenta mock válida registrada.'));
    }
  }

  void _onUpdateTransferDetails(
      UpdateTransferDetails event, Emitter<TransferState> emit) {
    final availableAmount = event.sourceAccount.type.name == 'credit'
        ? event.sourceAccount.remainingCredit
        : event.sourceAccount.balance;

    if (availableAmount < event.amount) {
      emit(state.copyWith(
          status: TransferStatus.error,
          error: event.sourceAccount.type.name == 'credit'
              ? 'Línea de crédito insuficiente.'
              : 'Saldo insuficiente.'));
    } else {
      emit(state.copyWith(
        sourceAccount: event.sourceAccount,
        amount: event.amount,
        status: TransferStatus.accountValid, // Stay in this step
      ));
    }
  }

  Future<void> _onRequestToken(
      RequestToken event, Emitter<TransferState> emit) async {
    if (state.destinationAccount == null || state.destinationAccount!.isEmpty) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'Primero valida la cuenta de destino.',
      ));
      return;
    }
    if (!state.isDestinationVerified) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'La cuenta de destino aún no está verificada.',
      ));
      return;
    }
    if (state.sourceAccount == null) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'Selecciona una cuenta de origen.',
      ));
      return;
    }
    if (state.amount <= 0) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'Ingresa un monto válido.',
      ));
      return;
    }

    emit(state.copyWith(status: TransferStatus.processing));
    try {
      final token = await _api.requestSecurityToken();
      emit(state.copyWith(
          status: TransferStatus.tokenRequested, securityToken: token));
    } catch (e) {
      emit(state.copyWith(status: TransferStatus.error, error: e.toString()));
    }
  }

  Future<void> _onSubmitTransfer(
      SubmitTransfer event, Emitter<TransferState> emit) async {
    if (event.token.trim().isEmpty) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'Ingresa el token de seguridad.',
      ));
      return;
    }
    if (state.destinationAccount == null || state.destinationAccount!.isEmpty) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'Cuenta de destino inválida.',
      ));
      return;
    }
    if (!state.isDestinationVerified) {
      emit(state.copyWith(
        status: TransferStatus.error,
        error: 'No se puede transferir a una cuenta no verificada.',
      ));
      return;
    }

    emit(state.copyWith(status: TransferStatus.processing));
    try {
      await _api.submitTransfer(
        beneficiary: state.destinationAccount!,
        sourceAccountId: state.sourceAccount!.id,
        amount: state.amount,
        token: event.token.trim(),
      );
      emit(state.copyWith(status: TransferStatus.success));
    } catch (e) {
      emit(state.copyWith(status: TransferStatus.error, error: e.toString()));
    }
  }

  void _onResetTransfer(ResetTransfer event, Emitter<TransferState> emit) {
    emit(const TransferState());
  }
}
