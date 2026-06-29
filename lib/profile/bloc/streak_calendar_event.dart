part of 'streak_calendar_bloc.dart';

@immutable
sealed class StreakCalendarEvent {
  const StreakCalendarEvent();
}

final class LoadStreakCalendar extends StreakCalendarEvent {
  const LoadStreakCalendar({
    required this.userId,
    this.month,
    this.recordToday = true,
  });

  final String userId;
  final DateTime? month;
  final bool recordToday;
}

final class ChangeStreakCalendarMonth extends StreakCalendarEvent {
  const ChangeStreakCalendarMonth({
    required this.userId,
    required this.monthDelta,
  });

  final String userId;
  final int monthDelta;
}

final class SelectStreakCalendarDay extends StreakCalendarEvent {
  const SelectStreakCalendarDay(this.day);

  final StreakCalendarDay day;
}
