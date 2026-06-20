part of 'global_bloc.dart';

@immutable
sealed class GlobalState {
  const GlobalState();
}

final class GlobalInitial extends GlobalState {}

final class GlobalLoading extends GlobalState {}

final class GlobalLoaded extends GlobalState {
  const GlobalLoaded({
    required this.streak,
    required this.xp,
    required this.level,
    required this.xpGoal,
    required this.hoursStudied,
    required this.lessonsCompleted,
    required this.notesCount,
    required this.weeksTracked,
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.displayName,
    required this.avatarInitials,
    required this.joinedDate,
    required this.activityDays,
  });

  final int streak;
  final int xp;
  final int level;
  final int xpGoal;
  final int hoursStudied;
  final int lessonsCompleted;
  final int notesCount;
  final int weeksTracked;
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final String displayName;
  final String avatarInitials;
  final String joinedDate;
  final List<ActivityDay> activityDays;
}

final class GlobalError extends GlobalState {
  const GlobalError(this.message);
  final String message;
}
