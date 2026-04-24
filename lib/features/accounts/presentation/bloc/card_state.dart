import 'package:equatable/equatable.dart';

class CardState extends Equatable {
  final bool isLoading;
  final bool isFrozen;
  final bool isSensitiveVisible;
  final String? cardNumber;
  final String? cvv;
  final String? expirationDate;
  final int remainingSeconds;
  final String? securityToken;
  final String? error;

  const CardState({
    this.isLoading = false,
    this.isFrozen = false,
    this.isSensitiveVisible = false,
    this.cardNumber,
    this.cvv,
    this.expirationDate,
    this.remainingSeconds = 0,
    this.securityToken,
    this.error,
  });

  CardState copyWith({
    bool? isLoading,
    bool? isFrozen,
    bool? isSensitiveVisible,
    String? cardNumber,
    String? cvv,
    String? expirationDate,
    int? remainingSeconds,
    String? Function()? securityToken,
    String? error,
  }) {
    return CardState(
      isLoading: isLoading ?? this.isLoading,
      isFrozen: isFrozen ?? this.isFrozen,
      isSensitiveVisible: isSensitiveVisible ?? this.isSensitiveVisible,
      cardNumber: cardNumber ?? this.cardNumber,
      cvv: cvv ?? this.cvv,
      expirationDate: expirationDate ?? this.expirationDate,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      securityToken: securityToken != null ? securityToken() : this.securityToken,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isFrozen,
        isSensitiveVisible,
        cardNumber,
        cvv,
        expirationDate,
        remainingSeconds,
        securityToken,
        error,
      ];
}
