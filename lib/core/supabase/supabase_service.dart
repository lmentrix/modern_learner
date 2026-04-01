import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around the Supabase client.
/// Access via [SupabaseService.client] or the [supabase] shorthand getter.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  // ── Auth helpers ────────────────────────────────────────────────────────────

  static User? get currentUser => client.auth.currentUser;

  static bool get isSignedIn => currentUser != null;

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
  }) =>
      client.auth.signUp(email: email, password: password);

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) =>
      client.auth.signInWithPassword(email: email, password: password);

  static Future<void> signOut() => client.auth.signOut();
}

/// Convenience getter — mirrors the `supabase` global in supabase_flutter.
SupabaseClient get supabase => SupabaseService.client;
