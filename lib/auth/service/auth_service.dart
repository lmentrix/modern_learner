import 'dart:developer';

import 'package:modern_learner_production/auth/model/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService(this._client);

  final SupabaseClient _client;

  // ── Current user ───────────────────────────────────────────────────────────

  AuthUserModel? get currentUser {
    final user = _client.auth.currentUser;
    return user != null ? AuthUserModel.fromUser(user) : null;
  }

  Stream<AuthUserModel?> get authStateChanges {
    return _client.auth.onAuthStateChange.map((event) {
      final user = event.session?.user;
      return user != null ? AuthUserModel.fromUser(user) : null;
    });
  }

  // ── Sign in ────────────────────────────────────────────────────────────────

  Future<AuthUserModel> signIn({
    required String email,
    required String password,
  }) async {
    final response = await _client.auth.signInWithPassword(
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
    // Pass name in data so the handle_new_user trigger picks it up and
    // inserts it into profiles automatically (along with user_progress).
    final response = await _client.auth.signUp(
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
    // Supabase returns user_repeated_signup (HTTP 200, session: null) when the
    // email is already registered. Treat this as a sign-in prompt rather than
    // silently emitting AuthSuccess with no active session.
    if (response.session == null) {
      throw const AuthException(
        'This email is already registered. Please sign in instead.',
      );
    }

    return AuthUserModel.fromUser(response.user!);
  }

  // ── Sign out ───────────────────────────────────────────────────────────────

  Future<void> signOut() => _client.auth.signOut();
}
