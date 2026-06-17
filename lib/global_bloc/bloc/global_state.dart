part of 'global_bloc.dart';

enum GlobalStatus { initial, loading, success, failure }

class GlobalState {
  const GlobalState({
    this.status = GlobalStatus.initial,
    this.userId,
    this.xp = 0,
    this.xpGoal = 0,
    this.level = 0,
    this.streak = 0,
    this.lessonsCompleted = 0,
    this.hoursStudied = 0,
    this.notesCount = 0,
    this.skillNodes = skillTree,
    this.bestWeekDays = 0,
    this.thisWeekDays = 0,
    this.totalActiveDays = 0,
    this.voiceNotesCount = 0,
    this.uploadedNotesCount = 0,
    this.activityDays = const <ActivityDay>[],
    this.displayName = '',
    this.email = '',
    this.avatarInitials = '',
    this.joinedDate = '',
    this.errorMessage,
  });

  final GlobalStatus status;
  final String? userId;
  final int xp;
  final int xpGoal;
  final int level;
  final int streak;
  final int lessonsCompleted;
  final int hoursStudied;
  final int notesCount;
  final List<SkillNode> skillNodes;
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final int voiceNotesCount;
  final int uploadedNotesCount;
  final List<ActivityDay> activityDays;
  final String displayName;
  final String email;
  final String avatarInitials;
  final String joinedDate;
  final String? errorMessage;

  int get weeksTracked => activityDays.length ~/ 7;

  GlobalState copyWith({
    GlobalStatus? status,
    String? userId,
    int? xp,
    int? xpGoal,
    int? level,
    int? streak,
    int? lessonsCompleted,
    int? hoursStudied,
    int? notesCount,
    List<SkillNode>? skillNodes,
    int? bestWeekDays,
    int? thisWeekDays,
    int? totalActiveDays,
    int? voiceNotesCount,
    int? uploadedNotesCount,
    List<ActivityDay>? activityDays,
    String? displayName,
    String? email,
    String? avatarInitials,
    String? joinedDate,
    String? errorMessage,
  }) {
    return GlobalState(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      xp: xp ?? this.xp,
      xpGoal: xpGoal ?? this.xpGoal,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      lessonsCompleted: lessonsCompleted ?? this.lessonsCompleted,
      hoursStudied: hoursStudied ?? this.hoursStudied,
      notesCount: notesCount ?? this.notesCount,
      skillNodes: skillNodes ?? this.skillNodes,
      bestWeekDays: bestWeekDays ?? this.bestWeekDays,
      thisWeekDays: thisWeekDays ?? this.thisWeekDays,
      totalActiveDays: totalActiveDays ?? this.totalActiveDays,
      voiceNotesCount: voiceNotesCount ?? this.voiceNotesCount,
      uploadedNotesCount: uploadedNotesCount ?? this.uploadedNotesCount,
      activityDays: activityDays ?? this.activityDays,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarInitials: avatarInitials ?? this.avatarInitials,
      joinedDate: joinedDate ?? this.joinedDate,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
