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

final class SaveGlobalStats extends GlobalEvent {}

final class LearningActivity extends GlobalEvent {
  const LearningActivity(this.userId);

  final String userId;
}

final class StartLearningActivityMonitoring extends GlobalEvent {
  const StartLearningActivityMonitoring(this.userId);

  final String userId;
}

final class SyncLearningActivity extends GlobalEvent {
  const SyncLearningActivity(this.userId, {this.stopTracking = false});

  final String userId;
  final bool stopTracking;
}
