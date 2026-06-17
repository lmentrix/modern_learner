part of 'auth_bloc.dart';

sealed class AuthEvent {}

final class AuthSignInRequested extends AuthEvent {
  AuthSignInRequested({required this.email, required this.password});
  final String email;
  final String password;
}

final class AuthSignUpRequested extends AuthEvent {
  AuthSignUpRequested({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}
