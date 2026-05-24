import 'package:modern_learner_production/features/profile/data/profile_activity_day.dart';

class LearningActivitySummary {
  const LearningActivitySummary({required this.days, required this.todayIndex});

  factory LearningActivitySummary.emptyForCurrentWeek({DateTime? now}) {
    final current = now ?? DateTime.now();
    final start = DateTime(
      current.year,
      current.month,
      current.day,
    ).subtract(Duration(days: current.weekday - DateTime.monday));

    return LearningActivitySummary(
      todayIndex: current.weekday - DateTime.monday,
      days: List.generate(7, (index) {
        final date = start.add(Duration(days: index));
        return ProfileActivityDay(
          label: _weekdayLabel(date),
          minutes: 0,
          date: date,
        );
      }),
    );
  }

  final List<ProfileActivityDay> days;
  final int todayIndex;

  int get totalMinutes => days.fold(0, (sum, day) => sum + day.minutes);

  int get bestDayMinutes {
    if (days.isEmpty) return 0;
    return days
        .map((day) => day.minutes)
        .reduce((left, right) => left > right ? left : right);
  }

  int get dailyAverageMinutes {
    if (days.isEmpty) return 0;
    return (totalMinutes / days.length).round();
  }

  int get daysActive => days.where((day) => day.minutes > 0).length;

  String get totalFormatted => formatMinutes(totalMinutes);

  static String formatMinutes(int minutes) {
    final hours = minutes ~/ 60;
    final remainder = minutes % 60;
    return hours > 0 ? '${hours}h ${remainder}m' : '${remainder}m';
  }

  static String weekdayLabel(DateTime date) => _weekdayLabel(date);
}

String _weekdayLabel(DateTime date) {
  return switch (date.weekday) {
    DateTime.monday => 'M',
    DateTime.tuesday => 'T',
    DateTime.wednesday => 'W',
    DateTime.thursday => 'T',
    DateTime.friday => 'F',
    DateTime.saturday => 'S',
    DateTime.sunday => 'S',
    _ => '',
  };
}
