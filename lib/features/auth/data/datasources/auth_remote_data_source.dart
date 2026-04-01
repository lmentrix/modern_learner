import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/user_entity.dart';
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
      final roleStr = profile?['role'] as String? ?? 'normal';
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: profile?['name'] as String? ?? '',
        avatarUrl: profile?['avatar_url'] as String?,
        role: roleStr == 'vip' ? UserRole.vip : UserRole.normal,
        accessToken: response.session?.accessToken,
        refreshToken: response.session?.refreshToken,
      );
    } on AuthException catch (e) {
      // Supabase returns "Invalid credentials" for both wrong password AND
      // unconfirmed email (for security reasons). Provide a more helpful message.
      final message = e.message.contains('Invalid')
          ? 'Invalid email or password. If you just signed up, please check your email to confirm your account.'
          : e.message;
      throw ServerException(message: message);
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
      // When email confirmation is enabled (default), session will be null.
      // This is expected behavior per Supabase docs - user needs to verify email.
      final requiresConfirmation = response.session == null;
      if (requiresConfirmation) {
        throw EmailConfirmationRequiredException(email: email);
      }
      return UserModel(
        id: response.user!.id,
        email: response.user!.email ?? '',
        name: name,
        avatarUrl: null,
        accessToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken,
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
