import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final String? token;
  final String? accessToken;
  final String? idToken;
  final String? tokenType;
  final int? expiresIn;

  const User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.token,
    this.accessToken,
    this.idToken,
    this.tokenType,
    this.expiresIn,
  });

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? avatarUrl,
    String? token,
    String? accessToken,
    String? idToken,
    String? tokenType,
    int? expiresIn,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      token: token ?? this.token,
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
      tokenType: tokenType ?? this.tokenType,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        avatarUrl,
        token,
        accessToken,
        idToken,
        tokenType,
        expiresIn,
      ];
}
