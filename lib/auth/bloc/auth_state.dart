part of 'auth_bloc.dart';

sealed class AuthState {}

final class AuthInitial extends AuthState {}

final class AuthLoading extends AuthState {}

final class AuthSuccess extends AuthState {
  AuthSuccess({required this.userId});
  final String userId;
}

final class AuthFailure extends AuthState {
  AuthFailure({required this.message});
  final String message;
}
