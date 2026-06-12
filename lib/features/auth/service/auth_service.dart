import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/auth/model/auth_user_model.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  AuthUserModel? get currentUser {
    final user = supabase.auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabase(user);
  }

  bool get isAuthenticated => supabase.auth.currentSession != null;

  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final normalizedDisplayName = displayName?.trim();
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        if (normalizedDisplayName != null && normalizedDisplayName.isNotEmpty)
          'display_name': normalizedDisplayName,
      },
    );

    final user = response.user;
    if (user == null) throw Exception('Sign-up failed: no user returned.');

    // Local Supabase has email confirmations disabled by default, so new
    // signups should return a session immediately. A null session usually
    // means the email already exists.
    if (response.session == null) {
      throw Exception('Email already registered. Please sign in instead.');
    }

    await _ensureLocalProfile(user, displayName: normalizedDisplayName);
    return AuthUserModel.fromSupabase(user);
  }

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign-in failed: no user returned.');

    await _ensureLocalProfile(user);
    return AuthUserModel.fromSupabase(user);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<void> _ensureLocalProfile(User user, {String? displayName}) async {
    final email = user.email ?? '';
    if (email.isEmpty) return;

    final metadataName = (user.userMetadata?['display_name'] as String?)
        ?.trim();
    final resolvedName = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : metadataName?.isNotEmpty == true
        ? metadataName!
        : email.split('@').first;

    try {
      final service = ProfileService();
      final existing = await service.getCurrentProfile();
      if (existing != null) return;

      await service.createProfile(
        id: user.id,
        email: email,
        name: resolvedName,
      );
    } catch (error, stackTrace) {
      debugPrint('Local profile bootstrap skipped: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }
}
