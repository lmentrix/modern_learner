import 'dart:developer';

import 'package:modern_learner_production/auth/model/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  SupabaseClient get _supabase => Supabase.instance.client;

  // ── Current user ───────────────────────────────────────────────────────────

  AuthUserModel? get currentUser {
    final user = _supabase.auth.currentUser;
    return user != null ? AuthUserModel.fromUser(user) : null;
  }

  Stream<AuthUserModel?> get authStateChanges {
    return _supabase.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? AuthUserModel.fromUser(user) : null;
    });
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    if (response.user == null) {
      throw const AuthException(
        'Sign in failed. Please check your credentials.',
      );
    }
    return AuthUserModel.fromUser(response.user!);
  }

  // ── Sign up ────────────────────────────────────────────────────────────────

  Future<AuthUserModel> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    log('  [AuthService] auth.signUp → email: $email');
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: {'name': name},
    );
    log(
      '  [AuthService] auth.signUp response — user: ${response.user?.id}, session: ${response.session != null}',
    );

    if (response.user == null) {
      throw const AuthException('Sign up failed. Please try again.');
    }

    // Email confirmation required (e.g. cloud Supabase with confirmations on).
    if (response.session == null) {
      throw const AuthException('Check your email for a confirmation link.');
    }

    // When autoconfirm is enabled, Supabase silently signs in an already-registered
    // email instead of rejecting the request. Detect this by checking if the account
    // was created more than 30 seconds ago — a genuinely new account is always fresh.
    final createdAt = DateTime.tryParse(response.user!.createdAt);
    if (createdAt != null &&
        DateTime.now().toUtc().difference(createdAt.toUtc()) >
            const Duration(seconds: 30)) {
      await _supabase.auth.signOut();
      throw const AuthException(
        'This email is already registered. Please sign in instead.',
      );
    }

    return AuthUserModel.fromUser(response.user!);
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() => _supabase.auth.signOut();
}
