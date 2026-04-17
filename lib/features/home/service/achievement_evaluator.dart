import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

/// Pure static utility. Evaluates [UserProgress] and returns a map of
/// achievement ID → earned level (1–5). IDs absent from the result = level 0.
abstract final class AchievementEvaluator {
  /// Level thresholds for each achievement, mirroring [AchievementBloc.allAchievements].
  static const _thresholds = {
    'streak_master': [3, 7, 14, 30, 100],
    'xp_collector': [100, 500, 2000, 10000, 50000],
    'lesson_warrior': [1, 10, 25, 50, 100],
    'daily_champion': [2, 3, 5, 7, 10],
    'chapter_ace': [1, 3, 7, 15, 30],
    'level_legend': [2, 5, 10, 20, 50],
    'night_owl': [1, 3, 7, 15, 30],
    'pioneer': [1, 2, 5, 10, 20],
    'gem_hoarder': [10, 50, 200, 750, 2000],
    'early_bird': [1, 3, 7, 14, 30],
    'study_days': [3, 7, 14, 30, 100],
    'weekly_warrior': [5, 7, 10, 15, 20],
  };

  /// Returns the achieved level for each achievement given current [progress].
  static Map<String, int> evaluate(UserProgress progress) {
    final lessons = progress.completedLessons;

    final metrics = <String, int>{
      'streak_master': progress.streak,
      'xp_collector': progress.totalXp,
      'lesson_warrior': lessons.length,
      'daily_champion': _maxLessonsInOneDay(lessons),
      'chapter_ace': progress.completedChapters.length,
      'level_legend': progress.level,
      'night_owl': _nightOwlCount(lessons),
      'pioneer': progress.level,
      'gem_hoarder': progress.gems,
      'early_bird': _earlyBirdCount(lessons),
      'study_days': _uniqueStudyDays(lessons),
      'weekly_warrior': _maxLessonsInSevenDays(lessons),
    };

    final result = <String, int>{};
    for (final entry in _thresholds.entries) {
      final id = entry.key;
      final thresholds = entry.value;
      final value = metrics[id] ?? 0;
      final level = _levelFor(value, thresholds);
      if (level > 0) result[id] = level;
    }
    return result;
  }

  /// Returns the raw progress value for a given achievement ID.
  /// Used to populate [AchievementEntity.currentProgress].
  static int progressFor(String id, UserProgress progress) {
    final lessons = progress.completedLessons;
    switch (id) {
      case 'streak_master':
        return progress.streak;
      case 'xp_collector':
        return progress.totalXp;
      case 'lesson_warrior':
        return lessons.length;
      case 'daily_champion':
        return _maxLessonsInOneDay(lessons);
      case 'chapter_ace':
        return progress.completedChapters.length;
      case 'level_legend':
        return progress.level;
      case 'night_owl':
        return _nightOwlCount(lessons);
      case 'pioneer':
        return progress.level;
      case 'gem_hoarder':
        return progress.gems;
      case 'early_bird':
        return _earlyBirdCount(progress.completedLessons);
      case 'study_days':
        return _uniqueStudyDays(progress.completedLessons);
      case 'weekly_warrior':
        return _maxLessonsInSevenDays(progress.completedLessons);
      default:
        return 0;
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Highest level index (1–5) whose threshold is met by [value], or 0.
  static int _levelFor(int value, List<int> thresholds) {
    int level = 0;
    for (var i = 0; i < thresholds.length; i++) {
      if (value >= thresholds[i]) level = i + 1;
    }
    return level;
  }

  static int _maxLessonsInOneDay(Map<String, DateTime> lessons) {
    if (lessons.isEmpty) return 0;
    final counts = <String, int>{};
    for (final dt in lessons.values) {
      final key =
          '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      counts[key] = (counts[key] ?? 0) + 1;
    }
    return counts.values.reduce((a, b) => a > b ? a : b);
  }

  static int _nightOwlCount(Map<String, DateTime> lessons) =>
      lessons.values.where((dt) => dt.hour >= 0 && dt.hour < 5).length;

  /// Lessons completed between 5 AM and 9 AM.
  static int _earlyBirdCount(Map<String, DateTime> lessons) =>
      lessons.values.where((dt) => dt.hour >= 5 && dt.hour < 9).length;

  /// Number of distinct calendar days on which at least one lesson was completed.
  static int _uniqueStudyDays(Map<String, DateTime> lessons) {
    if (lessons.isEmpty) return 0;
    final days = <String>{};
    for (final dt in lessons.values) {
      days.add(
        '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}',
      );
    }
    return days.length;
  }

  /// Maximum number of lessons completed within any rolling 7-day window.
  static int _maxLessonsInSevenDays(Map<String, DateTime> lessons) {
    if (lessons.isEmpty) return 0;
    final sorted = lessons.values.toList()..sort();
    var best = 0;
    for (var i = 0; i < sorted.length; i++) {
      final windowEnd = sorted[i].add(const Duration(days: 7));
      var count = 0;
      for (var j = i; j < sorted.length; j++) {
        if (sorted[j].isBefore(windowEnd)) {
          count++;
        } else {
          break;
        }
      }
      if (count > best) best = count;
    }
    return best;
  }
}
