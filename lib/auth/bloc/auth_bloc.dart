import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:modern_learner_production/auth/service/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthService authService})
      : _authService = authService,
        super(AuthInitial()) {
    on<AuthSignInRequested>(_onSignIn);
    on<AuthSignUpRequested>(_onSignUp);
  }

  final AuthService _authService;

  Future<void> _onSignIn(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await _authService.signIn(
        email: event.email,
        password: event.password,
      );
      emit(AuthSuccess(userId: user.id));
    } on AuthException catch (e) {
      emit(AuthFailure(message: e.message));
    } on SocketException {
      emit(AuthFailure(
        message: 'Cannot reach server. Check your internet connection.',
      ));
    } catch (_) {
      emit(AuthFailure(message: 'Something went wrong. Please try again.'));
    }
  }

  Future<void> _onSignUp(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    log('▶ [AuthBloc] signUp called — email: ${event.email}, name: ${event.name}');
    emit(AuthLoading());
    try {
      log('  → calling AuthService.signUp...');
      final user = await _authService.signUp(
        name: event.name,
        email: event.email,
        password: event.password,
      );
      log('  ✓ signUp success — userId: ${user.id}');
      emit(AuthSuccess(userId: user.id));
    } on AuthException catch (e) {
      log('  ✗ AuthException: ${e.message}');
      emit(AuthFailure(message: e.message));
    } on SocketException catch (e) {
      log('  ✗ SocketException: $e');
      emit(AuthFailure(
        message: 'Cannot reach server. Check your internet connection.',
      ));
    } catch (e, st) {
      log('  ✗ Unknown error: $e', stackTrace: st);
      emit(AuthFailure(message: 'Something went wrong. Please try again.'));
    }
  }
}
