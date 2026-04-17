import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/supabase/supabase_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthLoading()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
    on<AuthSignOutRequested>(_onSignOut);
    on<_AuthStateChanged>(_onAuthStateChanged);

    // Bootstrap from persisted session and listen for future changes.
    _sub = SupabaseService.authStateChanges.listen(
      (s) => add(_AuthStateChanged(s.session?.user)),
    );
  }

  // ignore: cancel_subscriptions
  late final StreamSubscription<dynamic> _sub;

  @override
  Future<void> close() {
    _sub.cancel();
    return super.close();
  }

  // ── Handlers ──────────────────────────────────────────────────────────────

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());
    try {
      final response = await SupabaseService.signIn(
        email: event.email.trim(),
        password: event.password,
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!));
      } else {
        emit(const AuthError('Sign in failed. Please try again.'));
      }
    } on AuthException catch (e) {
      emit(AuthError(_friendly(e.message)));
    } catch (_) {
      emit(const AuthError('Something went wrong. Check your connection.'));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthSubmitting());
    try {
      final response = await SupabaseService.client.auth.signUp(
        email: event.email.trim(),
        password: event.password,
        data: {'name': event.name.trim()},
      );
      if (response.user != null) {
        emit(AuthAuthenticated(response.user!));
      } else {
        // Email confirmation required
        emit(const AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(_friendly(e.message)));
    } catch (_) {
      emit(const AuthError('Something went wrong. Check your connection.'));
    }
  }

  Future<void> _onSignOut(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await SupabaseService.signOut();
    emit(const AuthUnauthenticated());
  }

  void _onAuthStateChanged(
    _AuthStateChanged event,
    Emitter<AuthState> emit,
  ) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendly(String raw) {
    final lower = raw.toLowerCase();
    if (lower.contains('invalid login')) return 'Incorrect email or password.';
    if (lower.contains('already registered')) return 'An account with this email already exists.';
    if (lower.contains('password')) return 'Password must be at least 6 characters.';
    if (lower.contains('email')) return 'Please enter a valid email address.';
    return raw;
  }
}
