import 'package:bloc/bloc.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc()
    : super(
        const GlobalState(
          xp: 0,
          xpGoal: 0,
          level: 0,
          streak: 0,
          lessonsCompleted: 0,
          hoursStudied: 0,
          notesCount: 0,
          skillNodes: skillTree,
          bestWeekDays: 0,
          thisWeekDays: 0,
          totalActiveDays: 0,
          voiceNotesCount: 0,
          uploadedNotesCount: 0,
        ),
      ) {
    on<UpdateXp>(_onUpdateXp);
    on<UpdateStreak>(_onUpdateStreak);
    on<UpdateStudyStats>(_onUpdateStudyStats);
    on<UpdateNotesCount>(_onUpdateNotesCount);
    on<UpdateSkillNode>(_onUpdateSkillNode);
    on<UpdateActivityWeeks>(_onUpdateActivityWeeks);
    on<AddVoiceNote>(_onAddVoiceNote);
    on<RemoveVoiceNote>(_onRemoveVoiceNote);
    on<AddUploadedNote>(_onAddUploadedNote);
    on<RemoveUploadedNote>(_onRemoveUploadedNote);
    on<UpdateActivityDays>(_onUpdateActivityDays);
  }

  void _onUpdateXp(UpdateXp event, Emitter<GlobalState> emit) {
    emit(
      state.copyWith(xp: event.xp, level: event.level, xpGoal: event.xpGoal),
    );
  }

  void _onUpdateStreak(UpdateStreak event, Emitter<GlobalState> emit) {
    emit(state.copyWith(streak: event.streak));
  }

  void _onUpdateStudyStats(UpdateStudyStats event, Emitter<GlobalState> emit) {
    emit(
      state.copyWith(
        lessonsCompleted: event.lessonsCompleted,
        hoursStudied: event.hoursStudied,
      ),
    );
  }

  void _onUpdateNotesCount(UpdateNotesCount event, Emitter<GlobalState> emit) {
    emit(state.copyWith(notesCount: event.notesCount));
  }

  void _onUpdateSkillNode(UpdateSkillNode event, Emitter<GlobalState> emit) {
    final updated = state.skillNodes.map((node) {
      if (node.id == event.nodeId) {
        return SkillNode(
          id: node.id,
          title: node.title,
          description: node.description,
          icon: node.icon,
          tier: node.tier,
          state: event.newState,
          xpReward: node.xpReward,
          prerequisiteIds: node.prerequisiteIds,
        );
      }
      return node;
    }).toList();
    emit(state.copyWith(skillNodes: updated));
  }

  void _onUpdateActivityWeeks(
    UpdateActivityWeeks event,
    Emitter<GlobalState> emit,
  ) {
    emit(
      state.copyWith(
        bestWeekDays: event.bestWeekDays,
        thisWeekDays: event.thisWeekDays,
        totalActiveDays: event.totalActiveDays,
      ),
    );
  }

  void _onAddVoiceNote(AddVoiceNote event, Emitter<GlobalState> emit) {
    emit(state.copyWith(voiceNotesCount: state.voiceNotesCount + 1));
  }

  void _onRemoveVoiceNote(RemoveVoiceNote event, Emitter<GlobalState> emit) {
    if (state.voiceNotesCount > 0) {
      emit(state.copyWith(voiceNotesCount: state.voiceNotesCount - 1));
    }
  }

  void _onAddUploadedNote(AddUploadedNote event, Emitter<GlobalState> emit) {
    emit(state.copyWith(uploadedNotesCount: state.uploadedNotesCount + 1));
  }

  void _onRemoveUploadedNote(
    RemoveUploadedNote event,
    Emitter<GlobalState> emit,
  ) {
    if (state.uploadedNotesCount > 0) {
      emit(state.copyWith(uploadedNotesCount: state.uploadedNotesCount - 1));
    }
  }

  void _onUpdateActivityDays(
    UpdateActivityDays event,
    Emitter<GlobalState> emit,
  ) {
    emit(state.copyWith(activityDays: event.activityDays));
  }
}
