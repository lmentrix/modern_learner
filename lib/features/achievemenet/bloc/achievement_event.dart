part of 'achievement_bloc.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object?> get props => [];
}

class AchievementsLoadRequested extends AchievementEvent {
  const AchievementsLoadRequested();
}

class AchievementSignalRecorded extends AchievementEvent {
  const AchievementSignalRecorded(this.signal);

  final AchievementSignal signal;

  @override
  List<Object?> get props => [signal];
}

class AchievementCategoryChanged extends AchievementEvent {
  const AchievementCategoryChanged(this.category);

  final AchievementCategory? category;

  @override
  List<Object?> get props => [category];
}

class AchievementUnlockedSeen extends AchievementEvent {
  const AchievementUnlockedSeen(this.achievementIds);

  final List<String> achievementIds;

  @override
  List<Object?> get props => [achievementIds];
}
