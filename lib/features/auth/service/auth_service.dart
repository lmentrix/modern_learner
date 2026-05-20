import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/auth/model/auth_user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  Stream<AuthState> get authStateChanges => supabase.auth.onAuthStateChange;

  AuthUserModel? get currentUser {
    final user = supabase.auth.currentUser;
    return user == null ? null : AuthUserModel.fromSupabase(user);
  }

  bool get isAuthenticated => supabase.auth.currentUser != null;

  Future<AuthUserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: displayName != null ? {'display_name': displayName} : null,
    );

    final user = response.user;
    if (user == null) throw Exception('Sign-up failed — no user returned.');
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
    if (user == null) throw Exception('Sign-in failed — no user returned.');
    return AuthUserModel.fromSupabase(user);
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
