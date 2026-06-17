part of 'global_bloc.dart';

class GlobalState {
  const GlobalState({
    required this.xp,
    required this.xpGoal,
    required this.level,
    required this.streak,
    required this.lessonsCompleted,
    required this.hoursStudied,
    required this.notesCount,
    required this.skillNodes,
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.voiceNotesCount,
    required this.uploadedNotesCount,
    this.activityDays = const <ActivityDay>[],
  });

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

  int get weeksTracked => activityDays.length ~/ 7;

  GlobalState copyWith({
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
  }) {
    return GlobalState(
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
      activityDays: activityDays ?? this.activityDays ?? const <ActivityDay>[],
    );
  }
}
