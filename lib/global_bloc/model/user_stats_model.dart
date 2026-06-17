import 'package:modern_learner_production/profile/model/profile_models.dart';

class UserStatsModel {
  const UserStatsModel({
    required this.xp,
    required this.xpGoal,
    required this.level,
    required this.streak,
    required this.lessonsCompleted,
    required this.hoursStudied,
    required this.notesCount,
    required this.voiceNotesCount,
    required this.uploadedNotesCount,
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.activityDays,
    required this.displayName,
    required this.email,
    required this.avatarInitials,
    required this.joinedDate,
  });

  final int xp;
  final int xpGoal;
  final int level;
  final int streak;
  final int lessonsCompleted;
  final int hoursStudied;
  final int notesCount;
  final int voiceNotesCount;
  final int uploadedNotesCount;
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final List<ActivityDay> activityDays;
  final String displayName;
  final String email;
  final String avatarInitials;
  final String joinedDate;

  static String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  static String _formatJoinDate(String? raw) {
    if (raw == null) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return '';
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.year}';
  }

  factory UserStatsModel.fromSupabase({
    required Map<String, dynamic> progress,
    required List<Map<String, dynamic>> activityRows,
    Map<String, dynamic> profile = const {},
  }) {
    final days = _buildActivityDays(activityRows);
    final completedLessons =
        (progress['completed_lessons'] as Map<String, dynamic>? ?? {}).length;

    final weekStats = _computeWeekStats(days);

    final name = (profile['name'] as String?) ?? '';
    return UserStatsModel(
      xp: (progress['total_xp'] as int?) ?? 0,
      xpGoal: (progress['xp_goal'] as int?) ?? 5000,
      level: (progress['level'] as int?) ?? 0,
      streak: (progress['streak'] as int?) ?? 0,
      lessonsCompleted: completedLessons,
      hoursStudied: (progress['hours_studied'] as int?) ?? 0,
      notesCount: (progress['notes_count'] as int?) ?? 0,
      voiceNotesCount: (progress['voice_notes_count'] as int?) ?? 0,
      uploadedNotesCount: (progress['uploaded_notes_count'] as int?) ?? 0,
      bestWeekDays: weekStats.bestWeekDays,
      thisWeekDays: weekStats.thisWeekDays,
      totalActiveDays: weekStats.totalActiveDays,
      activityDays: days,
      displayName: name,
      email: (profile['email'] as String?) ?? '',
      avatarInitials: name.isNotEmpty ? _initials(name) : '?',
      joinedDate: _formatJoinDate(profile['created_at'] as String?),
    );
  }

  static List<ActivityDay> _buildActivityDays(List<Map<String, dynamic>> rows) {
    final Map<DateTime, int> activityMap = {};
    for (final row in rows) {
      final date = DateTime.parse(row['activity_date'] as String);
      final seconds = (row['active_seconds'] as int?) ?? 0;
      final intensity = seconds <= 0
          ? 0
          : seconds <= 600
          ? 1
          : seconds <= 1800
          ? 2
          : 3;
      activityMap[DateTime(date.year, date.month, date.day)] = intensity;
    }

    final now = DateTime.now();
    final days = <ActivityDay>[];
    for (var i = 69; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      days.add(ActivityDay(date: key, intensity: activityMap[key] ?? 0));
    }
    return days;
  }

  static _WeekStats _computeWeekStats(List<ActivityDay> days) {
    int totalActiveDays = 0;
    int bestWeekDays = 0;
    int thisWeekDays = 0;

    final now = DateTime.now();
    final startOfThisWeek = now.subtract(Duration(days: now.weekday - 1));

    // Group by week buckets
    final Map<int, int> weekActiveDays = {};
    for (final day in days) {
      if (day.intensity > 0) {
        totalActiveDays++;
        final weekIndex = day.date.difference(days.first.date).inDays ~/ 7;
        weekActiveDays[weekIndex] = (weekActiveDays[weekIndex] ?? 0) + 1;

        final isThisWeek = !day.date.isBefore(
          DateTime(
            startOfThisWeek.year,
            startOfThisWeek.month,
            startOfThisWeek.day,
          ),
        );
        if (isThisWeek) thisWeekDays++;
      }
    }
    bestWeekDays = weekActiveDays.values.fold(0, (a, b) => a > b ? a : b);

    return _WeekStats(
      bestWeekDays: bestWeekDays,
      thisWeekDays: thisWeekDays,
      totalActiveDays: totalActiveDays,
    );
  }
}

class _WeekStats {
  const _WeekStats({
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
  });
  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
}
