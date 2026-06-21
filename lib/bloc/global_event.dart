part of 'global_bloc.dart';

@immutable
sealed class GlobalEvent {
  const GlobalEvent();
}

final class FetchGlobalStats extends GlobalEvent {
  const FetchGlobalStats(this.userId);
  final String userId;
}

final class RefreshGlobalStats extends GlobalEvent {}

