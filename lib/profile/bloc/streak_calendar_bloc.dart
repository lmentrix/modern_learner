import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/profile/model/streak_calendar.dart';
import 'package:modern_learner_production/profile/service/streak_calender.dart';

part 'streak_calendar_event.dart';
part 'streak_calendar_state.dart';

class StreakCalendarBloc
    extends Bloc<StreakCalendarEvent, StreakCalendarState> {
  StreakCalendarBloc({required StreakCalenderService service})
    : _service = service,
      super(const StreakCalendarInitial()) {
    on<LoadStreakCalendar>(_onLoad);
    on<ChangeStreakCalendarMonth>(_onChangeMonth);
    on<SelectStreakCalendarDay>(_onSelectDay);
  }

  final StreakCalenderService _service;

  Future<void> _onLoad(
    LoadStreakCalendar event,
    Emitter<StreakCalendarState> emit,
  ) async {
    emit(const StreakCalendarLoading());
    try {
      final month = await _service.loadMonth(
        userId: event.userId,
        month: event.month,
        recordToday: event.recordToday,
      );
      emit(
        StreakCalendarLoaded(
          month: month,
          selectedDay: month.today,
          igniteLogo: month.igniteToday,
        ),
      );
    } catch (error) {
      emit(StreakCalendarFailure(error.toString()));
    }
  }

  Future<void> _onChangeMonth(
    ChangeStreakCalendarMonth event,
    Emitter<StreakCalendarState> emit,
  ) async {
    final current = state;
    if (current is! StreakCalendarLoaded) return;
    emit(current.copyWith(isRefreshing: true, igniteLogo: false));
    try {
      final visibleMonth = DateTime(
        current.month.visibleMonth.year,
        current.month.visibleMonth.month + event.monthDelta,
      );
      final month = await _service.loadMonth(
        userId: event.userId,
        month: visibleMonth,
        recordToday: false,
      );
      emit(StreakCalendarLoaded(month: month, selectedDay: month.today));
    } catch (error) {
      emit(StreakCalendarFailure(error.toString()));
    }
  }

  void _onSelectDay(
    SelectStreakCalendarDay event,
    Emitter<StreakCalendarState> emit,
  ) {
    final current = state;
    if (current is! StreakCalendarLoaded) return;
    emit(current.copyWith(selectedDay: event.day, igniteLogo: false));
  }
}
