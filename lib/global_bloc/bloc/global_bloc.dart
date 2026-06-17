import 'package:bloc/bloc.dart';
import 'package:modern_learner_production/global_bloc/model/user_stats_model.dart';
import 'package:modern_learner_production/global_bloc/service/user_stats_service.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc({required UserStatsService statsService})
      : _statsService = statsService,
        super(const GlobalState()) {
    on<FetchUserStats>(_onFetchUserStats);
    on<UpdateXp>(_onUpdateXp);
    on<UpdateStreak>(_onUpdateStreak);
    on<UpdateStudyStats>(_onUpdateStudyStats);
    on<UpdateNotesCount>(_onUpdateNotesCount);
    on<UpdateSkillNode>(_onUpdateSkillNode);
    on<UpdateActivityWeeks>(_onUpdateActivityWeeks);
    on<UpdateActivityDays>(_onUpdateActivityDays);
    on<AddVoiceNote>(_onAddVoiceNote);
    on<RemoveVoiceNote>(_onRemoveVoiceNote);
    on<AddUploadedNote>(_onAddUploadedNote);
    on<RemoveUploadedNote>(_onRemoveUploadedNote);
  }

  final UserStatsService _statsService;

  // ── Fetch ──────────────────────────────────────────────────────────────────

  Future<void> _onFetchUserStats(
    FetchUserStats event,
    Emitter<GlobalState> emit,
  ) async {
    emit(state.copyWith(status: GlobalStatus.loading));
    try {
      final stats = await _statsService.fetchStats(event.userId);
      // Ensure today appears in the activity grid (silent no-op on error).
      await _statsService.ensureTodayActivity(event.userId);
      emit(_stateFromModel(stats, event.userId));
    } catch (e) {
      emit(state.copyWith(
        status: GlobalStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  GlobalState _stateFromModel(UserStatsModel m, String userId) =>
      state.copyWith(
        status: GlobalStatus.success,
        userId: userId,
        xp: m.xp,
        xpGoal: m.xpGoal,
        level: m.level,
        streak: m.streak,
        lessonsCompleted: m.lessonsCompleted,
        hoursStudied: m.hoursStudied,
        notesCount: m.notesCount,
        voiceNotesCount: m.voiceNotesCount,
        uploadedNotesCount: m.uploadedNotesCount,
        bestWeekDays: m.bestWeekDays,
        thisWeekDays: m.thisWeekDays,
        totalActiveDays: m.totalActiveDays,
        activityDays: m.activityDays,
        displayName: m.displayName,
        email: m.email,
        avatarInitials: m.avatarInitials,
        joinedDate: m.joinedDate,
      );

  // ── Updates — emit locally then persist to Supabase (fire-and-forget) ──────

  void _onUpdateXp(UpdateXp event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    final newLevel = event.level ?? state.level;
    final newXpGoal = event.xpGoal ?? state.xpGoal;
    emit(state.copyWith(xp: event.xp, level: newLevel, xpGoal: newXpGoal));
    if (uid != null) {
      _statsService
          .updateProgress(uid, xp: event.xp, level: newLevel, xpGoal: newXpGoal)
          .ignore();
    }
  }

  void _onUpdateStreak(UpdateStreak event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    emit(state.copyWith(streak: event.streak));
    if (uid != null) {
      _statsService.updateProgress(uid, streak: event.streak).ignore();
    }
  }

  void _onUpdateStudyStats(UpdateStudyStats event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    final newLessons = event.lessonsCompleted ?? state.lessonsCompleted;
    final newHours = event.hoursStudied ?? state.hoursStudied;
    emit(state.copyWith(lessonsCompleted: newLessons, hoursStudied: newHours));
    if (uid != null) {
      _statsService.updateProgress(uid, hoursStudied: newHours).ignore();
    }
  }

  void _onUpdateNotesCount(UpdateNotesCount event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    emit(state.copyWith(notesCount: event.notesCount));
    if (uid != null) {
      _statsService.updateProgress(uid, notesCount: event.notesCount).ignore();
    }
  }

  void _onUpdateSkillNode(UpdateSkillNode event, Emitter<GlobalState> emit) {
    final updated = state.skillNodes.map((node) {
      if (node.id != event.nodeId) return node;
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
    }).toList();
    emit(state.copyWith(skillNodes: updated));
  }

  // Activity week stats are computed from learning_activity_days on fetch;
  // these local-only events update the display without touching Supabase.
  void _onUpdateActivityWeeks(
    UpdateActivityWeeks event,
    Emitter<GlobalState> emit,
  ) {
    emit(state.copyWith(
      bestWeekDays: event.bestWeekDays,
      thisWeekDays: event.thisWeekDays,
      totalActiveDays: event.totalActiveDays,
    ));
  }

  void _onUpdateActivityDays(
    UpdateActivityDays event,
    Emitter<GlobalState> emit,
  ) {
    emit(state.copyWith(activityDays: event.activityDays));
  }

  void _onAddVoiceNote(AddVoiceNote event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    final newCount = state.voiceNotesCount + 1;
    emit(state.copyWith(voiceNotesCount: newCount));
    if (uid != null) {
      _statsService.updateProgress(uid, voiceNotesCount: newCount).ignore();
    }
  }

  void _onRemoveVoiceNote(RemoveVoiceNote event, Emitter<GlobalState> emit) {
    if (state.voiceNotesCount <= 0) return;
    final uid = state.userId;
    final newCount = state.voiceNotesCount - 1;
    emit(state.copyWith(voiceNotesCount: newCount));
    if (uid != null) {
      _statsService.updateProgress(uid, voiceNotesCount: newCount).ignore();
    }
  }

  void _onAddUploadedNote(AddUploadedNote event, Emitter<GlobalState> emit) {
    final uid = state.userId;
    final newCount = state.uploadedNotesCount + 1;
    emit(state.copyWith(uploadedNotesCount: newCount));
    if (uid != null) {
      _statsService.updateProgress(uid, uploadedNotesCount: newCount).ignore();
    }
  }

  void _onRemoveUploadedNote(
    RemoveUploadedNote event,
    Emitter<GlobalState> emit,
  ) {
    if (state.uploadedNotesCount <= 0) return;
    final uid = state.userId;
    final newCount = state.uploadedNotesCount - 1;
    emit(state.copyWith(uploadedNotesCount: newCount));
    if (uid != null) {
      _statsService.updateProgress(uid, uploadedNotesCount: newCount).ignore();
    }
  }
}
