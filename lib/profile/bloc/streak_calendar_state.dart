part of 'streak_calendar_bloc.dart';

@immutable
sealed class StreakCalendarState {
  const StreakCalendarState();
}

final class StreakCalendarInitial extends StreakCalendarState {
  const StreakCalendarInitial();
}

final class StreakCalendarLoading extends StreakCalendarState {
  const StreakCalendarLoading();
}

final class StreakCalendarLoaded extends StreakCalendarState {
  const StreakCalendarLoaded({
    required this.month,
    this.selectedDay,
    this.igniteLogo = false,
    this.isRefreshing = false,
  });

  final StreakCalendarMonth month;
  final StreakCalendarDay? selectedDay;
  final bool igniteLogo;
  final bool isRefreshing;

  StreakCalendarLoaded copyWith({
    StreakCalendarMonth? month,
    StreakCalendarDay? selectedDay,
    bool? igniteLogo,
    bool? isRefreshing,
  }) {
    return StreakCalendarLoaded(
      month: month ?? this.month,
      selectedDay: selectedDay ?? this.selectedDay,
      igniteLogo: igniteLogo ?? this.igniteLogo,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

final class StreakCalendarFailure extends StreakCalendarState {
  const StreakCalendarFailure(this.message);

  final String message;
}
