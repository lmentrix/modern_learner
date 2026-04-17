import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

/// Pure static utility that computes which achievement IDs should be unlocked
/// for a given [UserProgress]. Contains no state and requires no DI registration.
abstract final class AchievementEvaluator {
  // Social achievements that require a backend leaderboard — always locked.
  static const _alwaysLocked = {'top_10', 'top_3', 'number_one', 'referral'};

  /// Returns the set of achievement IDs that [progress] qualifies for.
  static Set<String> evaluate(UserProgress progress) {
    final unlocked = <String>{};
    final lessons = progress.completedLessons;
    final lessonCount = lessons.length;

    // ── Streaks ───────────────────────────────────────────────────────────────
    final streak = progress.streak;
    if (streak >= 7) unlocked.add('week_streak');
    if (streak >= 14) unlocked.add('fortnight_streak');
    if (streak >= 30) unlocked.add('month_streak');
    if (streak >= 100) unlocked.add('century_streak');
    if (streak >= 365) unlocked.add('year_streak');

    // ── Experience ────────────────────────────────────────────────────────────
    final xp = progress.totalXp;
    if (xp >= 100) unlocked.add('first_xp');
    if (xp >= 500) unlocked.add('xp_hunter');
    if (xp >= 2000) unlocked.add('xp_master');
    if (xp >= 10000) unlocked.add('xp_legend');
    if (xp >= 50000) unlocked.add('xp_champion');

    // ── Learning ──────────────────────────────────────────────────────────────
    if (lessonCount >= 1) {
      unlocked.add('first_lesson');
      // No per-lesson accuracy tracked; treat first completion as "perfect".
      unlocked.add('perfectionist');
    }
    if (_lessonsCompletedToday(lessons) >= 5) unlocked.add('quick_learner');
    if (lessonCount >= 5) unlocked.add('no_mistakes');
    if (lessonCount >= 25) unlocked.add('bookworm');
    if (lessonCount >= 50) unlocked.add('scholar');
    if (lessonCount >= 100) unlocked.add('century_learner');

    // ── Special ───────────────────────────────────────────────────────────────
    unlocked.add('early_adopter'); // every user qualifies
    if (_hasNightOwlLesson(lessons)) unlocked.add('night_owl');
    if (lessonCount >= 3) unlocked.add('speed_demon');
    if (_hasComebackKid(lessons)) unlocked.add('comeback_kid');

    // Remove any always-locked IDs that may have leaked in.
    unlocked.removeAll(_alwaysLocked);

    return unlocked;
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  static int _lessonsCompletedToday(Map<String, DateTime> lessons) {
    final now = DateTime.now();
    return lessons.values.where((dt) {
      return dt.year == now.year && dt.month == now.month && dt.day == now.day;
    }).length;
  }

  static bool _hasNightOwlLesson(Map<String, DateTime> lessons) {
    return lessons.values.any((dt) => dt.hour >= 0 && dt.hour < 5);
  }

  static bool _hasComebackKid(Map<String, DateTime> lessons) {
    if (lessons.length < 2) return false;
    final sorted = lessons.values.toList()..sort();
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].difference(sorted[i - 1]).inDays >= 7) return true;
    }
    return false;
  }
}
