import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:bank_go/core/errors/exceptions.dart';
import 'package:bank_go/features/auth/data/models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> getCachedUser();
  UserModel? getUserSync();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

const String _kCachedUser = 'CACHED_USER';
const String _kAccessToken = 'ACCESS_TOKEN';
const String _kIdToken = 'ID_TOKEN';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;
  final FlutterSecureStorage secureStorage;

  const AuthLocalDataSourceImpl({
    required this.sharedPreferences,
    required this.secureStorage,
  });

  @override
  Future<UserModel> getCachedUser() async {
    final user = getUserSync();
    if (user == null) {
      throw const CacheException(message: 'No hay usuario en caché');
    }
    return user;
  }

  @override
  UserModel? getUserSync() {
    final jsonString = sharedPreferences.getString(_kCachedUser);
    if (jsonString == null) {
      return null;
    }
    return UserModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    // Save user data in SharedPreferences
    await sharedPreferences.setString(
      _kCachedUser,
      jsonEncode(user.toJson()),
    );

    // Save sensitive tokens in secure storage
    if (user.accessToken != null) {
      await secureStorage.write(
        key: _kAccessToken,
        value: user.accessToken,
      );
    }
    if (user.idToken != null) {
      await secureStorage.write(
        key: _kIdToken,
        value: user.idToken,
      );
    }
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_kCachedUser);
    // Clear secure storage
    await secureStorage.delete(key: _kAccessToken);
    await secureStorage.delete(key: _kIdToken);
  }
}
