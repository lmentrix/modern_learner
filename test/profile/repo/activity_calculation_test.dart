import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/profile/repo/activity_calculation.dart';

void main() {
  group('ActivityCalculation.summarize', () {
    test('fills a 70-day grid and maps online time to intensity', () {
      final today = DateTime(2026, 6, 21);
      final result = ActivityCalculation.summarize(
        today: today,
        records: [
          ActivityRecord(
            date: today.subtract(const Duration(days: 2)),
            activeSeconds: 5 * 60,
          ),
          ActivityRecord(
            date: today.subtract(const Duration(days: 1)),
            activeSeconds: 20 * 60,
          ),
          ActivityRecord(date: today, activeSeconds: 45 * 60),
        ],
      );

      expect(result.activityDays, hasLength(70));
      expect(
        result.activityDays.skip(67).map((day) => day.intensity).toList(),
        [1, 2, 3],
      );
      expect(result.todayActiveSeconds, 45 * 60);
      expect(result.totalActiveDays, 3);
    });

    test('calculates this week and best week active-day counts', () {
      final today = DateTime(2026, 6, 21); // Sunday
      final thisMonday = DateTime(2026, 6, 15);
      final previousMonday = DateTime(2026, 6, 8);
      final records = <ActivityRecord>[
        for (var day = 0; day < 3; day++)
          ActivityRecord(
            date: thisMonday.add(Duration(days: day)),
            activeSeconds: 60,
          ),
        for (var day = 0; day < 5; day++)
          ActivityRecord(
            date: previousMonday.add(Duration(days: day)),
            activeSeconds: 60,
          ),
      ];

      final result = ActivityCalculation.summarize(
        records: records,
        today: today,
      );

      expect(result.thisWeekDays, 3);
      expect(result.bestWeekDays, 5);
      expect(result.totalActiveDays, 8);
      expect(result.weeksTracked, 2);
    });

    test('returns empty summary when no time has been recorded', () {
      final result = ActivityCalculation.summarize(
        records: const [],
        today: DateTime(2026, 6, 21),
      );

      expect(result.bestWeekDays, 0);
      expect(result.thisWeekDays, 0);
      expect(result.totalActiveDays, 0);
      expect(result.weeksTracked, 0);
      expect(
        result.activityDays,
        everyElement(
          isA<ActivityDay>().having((day) => day.intensity, 'intensity', 0),
        ),
      );
    });
  });
}
