import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

part 'xp_event.dart';
part 'xp_state.dart';

class XpBloc extends Bloc<XpEvent, XpState> {
  XpBloc({required this.courseKey})
      : super(_initialState(courseKey)) {
    on<XpEarned>(_onXpEarned);
  }

  final String courseKey;

  static const int xpPerExercise = 100;

  static XpState _initialState(String courseKey) {
    final data = CourseXpService.instance.dataFor(courseKey);
    return XpState(
      totalXp: data.exerciseXp,
      exercisesCompleted: data.exercisesCompleted,
    );
  }

  void _onXpEarned(XpEarned event, Emitter<XpState> emit) {
    CourseXpService.instance.addXp(courseKey, event.amount);
    emit(state.copyWith(
      totalXp: state.totalXp + event.amount,
      exercisesCompleted: state.exercisesCompleted + 1,
    ));
  }
}
