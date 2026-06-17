part of 'global_bloc.dart';

sealed class GlobalEvent {}

/// Directly set XP (and optionally level/xpGoal).
final class UpdateXp extends GlobalEvent {
  UpdateXp({required this.xp, this.level, this.xpGoal});
  final int xp;
  final int? level;
  final int? xpGoal;
}

/// Increment or reset the daily streak.
final class UpdateStreak extends GlobalEvent {
  UpdateStreak({required this.streak});
  final int streak;
}

/// Update lesson and/or hour counters.
final class UpdateStudyStats extends GlobalEvent {
  UpdateStudyStats({this.lessonsCompleted, this.hoursStudied});
  final int? lessonsCompleted;
  final int? hoursStudied;
}

/// Update the notes count shown on the profile page.
final class UpdateNotesCount extends GlobalEvent {
  UpdateNotesCount({required this.notesCount});
  final int notesCount;
}

/// Change the state of a single skill-tree node.
final class UpdateSkillNode extends GlobalEvent {
  UpdateSkillNode({required this.nodeId, required this.newState});
  final String nodeId;
  final NodeState newState;
}

/// Update weekly activity numbers (pass only the fields that changed).
final class UpdateActivityWeeks extends GlobalEvent {
  UpdateActivityWeeks({this.bestWeekDays, this.thisWeekDays, this.totalActiveDays});
  final int? bestWeekDays;
  final int? thisWeekDays;
  final int? totalActiveDays;
}

/// Add a new voice note recorded on the mic page.
final class AddVoiceNote extends GlobalEvent {}

/// Remove a voice note from the mic page.
final class RemoveVoiceNote extends GlobalEvent {}

/// Add an uploaded note from the home page.
final class AddUploadedNote extends GlobalEvent {}

/// Remove an uploaded note from the home page.
final class RemoveUploadedNote extends GlobalEvent {}

/// Replace the full activity grid data (e.g. after a data load).
final class UpdateActivityDays extends GlobalEvent {
  UpdateActivityDays({required this.activityDays});
  final List<ActivityDay> activityDays;
}
