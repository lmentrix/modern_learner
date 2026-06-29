final class StreakCalendarDay {
  const StreakCalendarDay({
    required this.date,
    required this.activeSeconds,
    required this.sessionsCount,
    required this.isInMonth,
    required this.isToday,
    required this.isStreakDay,
  });

  final DateTime date;
  final int activeSeconds;
  final int sessionsCount;
  final bool isInMonth;
  final bool isToday;
  final bool isStreakDay;

  bool get isActive => activeSeconds > 0;
  int get intensity => switch (activeSeconds) {
    <= 0 => 0,
    < 10 * 60 => 1,
    < 30 * 60 => 2,
    _ => 3,
  };
}

final class StreakCalendarMonth {
  const StreakCalendarMonth({
    required this.visibleMonth,
    required this.days,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDaysThisMonth,
    required this.totalActiveSecondsThisMonth,
    required this.igniteToday,
  });

  final DateTime visibleMonth;
  final List<StreakCalendarDay> days;
  final int currentStreak;
  final int longestStreak;
  final int activeDaysThisMonth;
  final int totalActiveSecondsThisMonth;
  final bool igniteToday;

  StreakCalendarDay? get today {
    for (final day in days) {
      if (day.isToday) return day;
    }
    return null;
  }
}
