import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
  Future<void> logout();
}

@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      if (response.user == null) {
        throw const ServerException(message: 'Login failed.');
      }
      final profile = await _fetchProfile(response.user!.id);
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profile?['name'] as String? ?? '',
        avatarUrl: profile?['avatar_url'] as String?,
        accessToken: response.session?.accessToken,
        refreshToken: response.session?.refreshToken,
      );
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      if (response.user == null) {
        throw const ServerException(message: 'Registration failed.');
      }
      if (response.session == null) {
        throw EmailConfirmationRequiredException(email: email);
      }
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: name,
        avatarUrl: null,
        accessToken: response.session?.accessToken,
        refreshToken: response.session?.refreshToken,
      );
    } on EmailConfirmationRequiredException {
      rethrow;
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }

  Future<Map<String, dynamic>?> _fetchProfile(String userId) async {
    try {
      final data = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
    } on AuthException catch (e) {
      throw ServerException(message: e.message);
    }
  }
}
