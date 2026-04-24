import 'package:equatable/equatable.dart';

class TransferRecipient extends Equatable {
  final String accountNumber;
  final String holderName;
  final String bankName;
  final String? alias;

  const TransferRecipient({
    required this.accountNumber,
    required this.holderName,
    required this.bankName,
    this.alias,
  });

  @override
  List<Object?> get props => [accountNumber, holderName, bankName, alias];
}
