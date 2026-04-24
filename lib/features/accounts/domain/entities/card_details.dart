import 'package:equatable/equatable.dart';

class CardDetails extends Equatable {
  final String cardNumber;
  final String? cardHolder;
  final String expirationDate;
  final String cvv;
  final String? type;
  final bool isEnabled;

  const CardDetails({
    required this.cardNumber,
    required this.expirationDate,
    required this.cvv,
    required this.isEnabled,
    this.cardHolder,
    this.type,
  });

  @override
  List<Object?> get props => [
        cardNumber,
        cardHolder,
        expirationDate,
        cvv,
        type,
        isEnabled,
      ];
}
