import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> cacheUser(UserModel user);
  Future<UserModel?> getCachedUser();
  Future<void> clearCache();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  const AuthLocalDataSourceImpl(this._storage);

  final FlutterSecureStorage _storage;

  static const _userKey = 'cached_user';

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      await _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
    } catch (_) {
      throw const CacheException(message: 'Failed to cache user.');
    }
  }

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final json = await _storage.read(key: _userKey);
      if (json == null) return null;
      return UserModel.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      throw const CacheException(message: 'Failed to read cached user.');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _storage.delete(key: _userKey);
    } catch (_) {
      throw const CacheException(message: 'Failed to clear cache.');
    }
  }
}
