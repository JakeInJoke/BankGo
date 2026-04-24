import 'package:equatable/equatable.dart';
import 'package:bank_go/features/accounts/domain/entities/account.dart';

abstract class TransferEvent extends Equatable {
  const TransferEvent();
  @override
  List<Object?> get props => [];
}

class UpdateDestinationAccount extends TransferEvent {
  final String accountNumber;
  const UpdateDestinationAccount(this.accountNumber);
}

class UpdateTransferDetails extends TransferEvent {
  final Account sourceAccount;
  final double amount;
  const UpdateTransferDetails(this.sourceAccount, this.amount);
}

class RequestToken extends TransferEvent {
  const RequestToken();
}

class SubmitTransfer extends TransferEvent {
  final String token;
  const SubmitTransfer(this.token);
}

class ResetTransfer extends TransferEvent {
  const ResetTransfer();
}

enum TransferStatus { initial, validatingAccount, accountValid, error, processing, success, tokenRequested }

class TransferState extends Equatable {
  final TransferStatus status;
  final String? destinationAccount;
  final Account? sourceAccount;
  final double amount;
  final String? securityToken;
  final String? error;

  const TransferState({
    this.status = TransferStatus.initial,
    this.destinationAccount,
    this.sourceAccount,
    this.amount = 0,
    this.securityToken,
    this.error,
  });

  TransferState copyWith({
    TransferStatus? status,
    String? destinationAccount,
    Account? sourceAccount,
    double? amount,
    String? securityToken,
    String? error,
  }) {
    return TransferState(
      status: status ?? this.status,
      destinationAccount: destinationAccount ?? this.destinationAccount,
      sourceAccount: sourceAccount ?? this.sourceAccount,
      amount: amount ?? this.amount,
      securityToken: securityToken ?? this.securityToken,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, destinationAccount, sourceAccount, amount, securityToken, error];
}
