part of 'global_bloc.dart';

@immutable
sealed class GlobalState {
  const GlobalState();
}

final class GlobalInitial extends GlobalState {}

final class GlobalLoading extends GlobalState {}

final class GlobalLoaded extends GlobalState {
  const GlobalLoaded({required this.displayName});

  final String displayName;
}

final class GlobalError extends GlobalState {
  const GlobalError(this.message);
  final String message;
}
