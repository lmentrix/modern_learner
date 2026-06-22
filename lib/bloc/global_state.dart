part of 'global_bloc.dart';

@immutable
sealed class GlobalState {
  const GlobalState();
}

final class GlobalInitial extends GlobalState {}

final class GlobalLoading extends GlobalState {}

final class GlobalLoaded extends GlobalState {
  const GlobalLoaded({
    required this.displayName,
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.activityDays,
    required this.weeksTracked,
    required this.todayActiveSeconds,
    required this.isActivityTracking,
    this.xp,
    this.level,
    this.streak,
    this.lessons,
    this.hours,
    this.notes,
    this.files,
    this.xpGoal,
    this.joinDate,
  });

  final String displayName;
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final List<ActivityDay> activityDays;
  final int weeksTracked;
  final int todayActiveSeconds;
  final bool isActivityTracking;
  final int? xp;
  final int? level;
  final int? streak;
  final int? lessons;
  final int? hours;
  final int? notes;
  final int? files;
  final int? xpGoal;
  final String? joinDate;

  GlobalLoaded copyWith({
    int? bestWeekDays,
    int? thisWeekDays,
    int? totalActiveDays,
    List<ActivityDay>? activityDays,
    int? weeksTracked,
    int? todayActiveSeconds,
    bool? isActivityTracking,
  }) {
    return GlobalLoaded(
      displayName: displayName,
      bestWeekDays: bestWeekDays ?? this.bestWeekDays,
      thisWeekDays: thisWeekDays ?? this.thisWeekDays,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      activityDays: activityDays ?? this.activityDays,
      weeksTracked: weeksTracked ?? this.weeksTracked,
      todayActiveSeconds: todayActiveSeconds ?? this.todayActiveSeconds,
      isActivityTracking: isActivityTracking ?? this.isActivityTracking,
      xp: xp,
      level: level,
      streak: streak,
      lessons: lessons,
      hours: hours,
      notes: notes,
      files: files,
      xpGoal: xpGoal,
      joinDate: joinDate,
    );
  }
}

final class GlobalError extends GlobalState {
  const GlobalError(this.message);
  final String message;
}
