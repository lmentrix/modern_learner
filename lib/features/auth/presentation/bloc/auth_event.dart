part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

final class AuthLoginRequested extends AuthEvent {
  const AuthLoginRequested({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

final class AuthRegisterRequested extends AuthEvent {
  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
  });

  final String name;
  final String email;
  final String password;

  @override
  List<Object?> get props => [name, email, password];
}

final class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

final class AuthLoadUserInfoRequested extends AuthEvent {
  const AuthLoadUserInfoRequested();
}

final class AuthUpdateUserInfoRequested extends AuthEvent {
  const AuthUpdateUserInfoRequested({required this.name, this.avatarUrl});

  final String name;
  final String? avatarUrl;

  @override
  List<Object?> get props => [name, avatarUrl];
}
