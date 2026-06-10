import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/features/profile/service/streak_service.dart';

void main() {
  group('StreakService.computeStreakForDates', () {
    test('continues beyond one week', () {
      final now = DateTime(2026, 6, 9);
      final dates = List.generate(9, (index) {
        return _dateKey(now.subtract(Duration(days: index)));
      });

      final streak = StreakService.computeStreakForDates(dates, now: now);

      expect(streak, 9);
    });

    test('continues when latest activity was yesterday', () {
      final now = DateTime(2026, 6, 9);
      final dates = List.generate(4, (index) {
        return _dateKey(now.subtract(Duration(days: index + 1)));
      });

      final streak = StreakService.computeStreakForDates(dates, now: now);

      expect(streak, 4);
    });

    test('resets when the most recent activity is older than yesterday', () {
      final now = DateTime(2026, 6, 9);
      final dates = [
        _dateKey(now.subtract(const Duration(days: 2))),
        _dateKey(now.subtract(const Duration(days: 3))),
      ];

      final streak = StreakService.computeStreakForDates(dates, now: now);

      expect(streak, 0);
    });
  });
}

String _dateKey(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}
