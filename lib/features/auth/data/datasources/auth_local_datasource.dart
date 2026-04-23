import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
}

const String _kCachedUser = 'CACHED_USER';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  const AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel> getCachedUser() async {
    final jsonString = sharedPreferences.getString(_kCachedUser);
    if (jsonString == null) {
      throw CacheException(message: 'No hay usuario en caché');
    }
    return UserModel.fromJson(
      jsonDecode(jsonString) as Map<String, dynamic>,
    );
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    await sharedPreferences.setString(
      _kCachedUser,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<void> clearCache() async {
    await sharedPreferences.remove(_kCachedUser);
  }
}
