import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/profile/repo/streak_calculation.dart';

void main() {
  group('StreakCalculation.calculateCurrentStreak', () {
    test('counts consecutive online days ending today', () {
      final today = DateTime(2026, 6, 29);

      final streak = StreakCalculation.calculateCurrentStreak(
        today: today,
        activeDates: [
          today,
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
          today.subtract(const Duration(days: 4)),
        ],
      );

      expect(streak, 3);
    });

    test('returns zero when today is not an online day', () {
      final today = DateTime(2026, 6, 29);

      final streak = StreakCalculation.calculateCurrentStreak(
        today: today,
        activeDates: [
          today.subtract(const Duration(days: 1)),
          today.subtract(const Duration(days: 2)),
        ],
      );

      expect(streak, 0);
    });

    test('deduplicates dates and ignores time components', () {
      final today = DateTime(2026, 6, 29, 23, 59);

      final streak = StreakCalculation.calculateCurrentStreak(
        today: today,
        activeDates: [
          DateTime(2026, 6, 29, 8),
          DateTime(2026, 6, 29, 21),
          DateTime(2026, 6, 28, 12),
        ],
      );

      expect(streak, 2);
    });
  });
}
