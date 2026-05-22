import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'xp_event.dart';
part 'xp_state.dart';

class XpBloc extends Bloc<XpEvent, XpState> {
  XpBloc() : super(const XpState()) {
    on<XpEarned>(_onXpEarned);
  }

  static const int xpPerExercise = 100;

  void _onXpEarned(XpEarned event, Emitter<XpState> emit) {
    emit(state.copyWith(
      totalXp: state.totalXp + event.amount,
      exercisesCompleted: state.exercisesCompleted + 1,
    ));
  }
}
