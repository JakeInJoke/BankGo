import 'package:bank_go/features/auth/domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatarUrl,
    super.token,
    super.accessToken,
    super.idToken,
    super.tokenType,
    super.expiresIn,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      token: json['token'] as String?,
      accessToken: json['access_token'] as String?,
      idToken: json['id_token'] as String?,
      tokenType: json['token_type'] as String?,
      expiresIn: json['expires_in'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'token': token,
      'access_token': accessToken,
      'id_token': idToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      avatarUrl: user.avatarUrl,
      token: user.token,
      accessToken: user.accessToken,
      idToken: user.idToken,
      tokenType: user.tokenType,
      expiresIn: user.expiresIn,
    );
  }
}
