import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

part 'xp_event.dart';
part 'xp_state.dart';

class XpBloc extends Bloc<XpEvent, XpState> {
  XpBloc({required this.courseKey}) : super(_initialState(courseKey)) {
    on<XpEarned>(_onXpEarned);
    on<_XpDataChanged>(_onXpDataChanged);
    _courseXpNotifier = CourseXpService.instance.notifierFor(courseKey)
      ..addListener(_syncFromService);
  }

  final String courseKey;
  late final ValueNotifier<CourseXpData> _courseXpNotifier;

  static const int xpPerExercise = 100;

  static XpState _initialState(String courseKey) {
    final data = CourseXpService.instance.dataFor(courseKey);
    return XpState(
      totalXp: data.exerciseXp,
      exercisesCompleted: data.exercisesCompleted,
      chaptersUnlocked: data.chaptersUnlocked,
    );
  }

  void _onXpEarned(XpEarned event, Emitter<XpState> emit) {
    CourseXpService.instance.addXp(courseKey, event.amount);
  }

  void _onXpDataChanged(_XpDataChanged event, Emitter<XpState> emit) {
    emit(
      XpState(
        totalXp: event.data.exerciseXp,
        exercisesCompleted: event.data.exercisesCompleted,
        chaptersUnlocked: event.data.chaptersUnlocked,
      ),
    );
  }

  void _syncFromService() {
    if (isClosed) return;
    add(_XpDataChanged(_courseXpNotifier.value));
  }

  @override
  Future<void> close() {
    _courseXpNotifier.removeListener(_syncFromService);
    return super.close();
  }
}
