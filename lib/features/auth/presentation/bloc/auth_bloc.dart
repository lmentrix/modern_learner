import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'package:modern_learner_production/core/errors/failures.dart';
import 'package:modern_learner_production/features/auth/data/models/user_model.dart';
import 'package:modern_learner_production/features/auth/domain/entities/user_entity.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/login_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/logout_usecase.dart';
import 'package:modern_learner_production/features/auth/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

@injectable
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(
    this._loginUseCase,
    this._registerUseCase,
    this._logoutUseCase,
    this._getCurrentUserUseCase,
  ) : super(const AuthState()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthLoadUserInfoRequested>(_onLoadUserInfoRequested);
    on<AuthUpdateUserInfoRequested>(_onUpdateUserInfoRequested);
  }

  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        password: event.password,
      ),
    );
    result.fold(
      (failure) {
        if (failure is EmailConfirmationPendingFailure) {
          emit(state.copyWith(
            status: AuthStatus.unauthenticated,
            errorMessage: 'Email confirmation required. Please check your inbox.',
          ));
        } else {
          emit(state.copyWith(
            status: AuthStatus.error,
            errorMessage: failure.message,
          ));
        }
      },
      (user) => emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _logoutUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.error,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onLoadUserInfoRequested(
    AuthLoadUserInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _getCurrentUserUseCase();
    result.fold(
      (failure) => emit(state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
      )),
      (user) => emit(state.copyWith(
        status: user != null
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        user: user,
        errorMessage: null,
      )),
    );
  }

  Future<void> _onUpdateUserInfoRequested(
    AuthUpdateUserInfoRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.user == null) return;
    
    final currentUser = state.user as UserModel;
    final updatedUser = UserModel(
      id: currentUser.id,
      email: currentUser.email,
      name: event.name,
      avatarUrl: event.avatarUrl ?? currentUser.avatarUrl,
      role: currentUser.role,
      accessToken: currentUser.accessToken,
      refreshToken: currentUser.refreshToken,
    );
    
    emit(state.copyWith(
      user: updatedUser,
    ));
  }
}
