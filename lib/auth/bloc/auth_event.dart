part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {
  const AuthEvent();
}

final class SignInUser extends AuthEvent {
  const SignInUser({required this.email, required this.password});
  final String email;
  final String password;
}

final class SignUpUser extends AuthEvent {
  const SignUpUser({
    required this.name,
    required this.email,
    required this.password,
  });
  final String name;
  final String email;
  final String password;
}

final class SignOutUser extends AuthEvent {
  const SignOutUser();
}

final class AuthStatusChanged extends AuthEvent {
  const AuthStatusChanged(this.user);
  final AuthUserModel? user;
}
