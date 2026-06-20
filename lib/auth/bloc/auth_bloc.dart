import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/auth/model/auth_user_model.dart';
import 'package:modern_learner_production/auth/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(const AuthInitial()) {
    on<AuthStatusChanged>(_onStatusChanged);
    on<SignInUser>(_onSignIn);
    on<SignUpUser>(_onSignUp);
    on<SignOutUser>(_onSignOut);

    _authSubscription = _authService.authStateChanges.listen((user) {
      add(AuthStatusChanged(user));
    });
  }

  final AuthService _authService;
  StreamSubscription<AuthUserModel?>? _authSubscription;

  void _onStatusChanged(AuthStatusChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onSignIn(SignInUser event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUp(SignUpUser event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authService.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignOut(SignOutUser event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      await _authService.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    return super.close();
  }
}
