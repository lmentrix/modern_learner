import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc() : super(GlobalInitial()) {
    on<FetchGlobalStats>(_onFetch);
    on<RefreshGlobalStats>(_onRefresh);
    on<SaveGlobalStats>(_onSave);

    //learning activity
    on<LearningActivity>(_onLearningActivity);
  }

  Future<void> _onFetch(
    FetchGlobalStats event,
    Emitter<GlobalState> emit,
  ) async {
    emit(GlobalLoading());
    await _load(emit, expectedUserId: event.userId);
  }

  Future<void> _onRefresh(
    RefreshGlobalStats event,
    Emitter<GlobalState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _onLearningActivity(
    LearningActivity event,
    Emitter<GlobalState> emit,
  ) async {
    if (state is! GlobalLoaded) {
      emit(GlobalLoading());
    }
    await _loadLearningActivity(emit, event.userId);
  }

  Future<void> _load(
    Emitter<GlobalState> emit, {
    String? expectedUserId,
  }) async {
    try {
      final client = Supabase.instance.client;

      final profile = client.auth.currentUser;
      final userId = profile?.id ?? '';
      final createdAt = profile?.createdAt;

      if (userId.isEmpty) {
        emit(const GlobalError('Not authenticated'));
        return;
      }
      if (expectedUserId != null && expectedUserId != userId) {
        emit(const GlobalError('Authenticated user does not match request'));
        return;
      }

      final Map<String, dynamic> userInfo = await client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .single(); // .single() returns Future<Map<String, dynamic>>

      final activityInfo = await _ensureAndFetchLearningActivity(
        client,
        userId,
      );

      emit(
        GlobalLoaded(
          displayName: _emailToName(profile?.email ?? ''),
          xp: userInfo['total_xp'] as int? ?? 0,
          xpGoal: userInfo['xp_goal'] as int? ?? 5000,
          level: userInfo['level'] as int? ?? 0,
          streak: userInfo['streak'] as int? ?? 0,
          lessons: (userInfo['completed_lessons'] as Map?)?.length ?? 0,
          hours: userInfo['hours_studied'] as int? ?? 0,
          notes: userInfo['notes_count'] as int? ?? 0,
          files: userInfo['uploaded_notes_count'] as int? ?? 0,
          joinDate: beautifyCreatedAt(createdAt ?? ''),
          bestWeekDays: activityInfo.bestWeekDays,
          thisWeekDays: activityInfo.thisWeekDays,
          totalActiveDays: activityInfo.totalActiveDays,
          activityDays: activityInfo.activityDays,
          weeksTracked: activityInfo.weeksTracked,
        ),
      );
    } catch (e) {
      emit(GlobalError(e.toString()));
    }
  }

  Future<void> _loadLearningActivity(
    Emitter<GlobalState> emit,
    String userId,
  ) async {
    await _load(emit, expectedUserId: userId);
  }

  Future<_LearningActivityData> _ensureAndFetchLearningActivity(
    SupabaseClient client,
    String userId,
  ) async {
    await client
        .from('learning_activity')
        .upsert(
          {
            'user_id': userId,
            'best_week_days': 0,
            'this_week_days': 0,
            'total_active_days': 0,
            'activity_days': <Map<String, Object>>[],
            'weeks_tracked': 0,
          },
          onConflict: 'user_id',
          ignoreDuplicates: true,
        );

    final row = await client
        .from('learning_activity')
        .select(
          'best_week_days, this_week_days, total_active_days, '
          'activity_days, weeks_tracked',
        )
        .eq('user_id', userId)
        .single();

    return _LearningActivityData.fromJson(row);
  }

  Future<void> _onSave(SaveGlobalStats event, Emitter<GlobalState> emit) async {
    final currentState = state;
    if (currentState is! GlobalLoaded) {
      emit(const GlobalError('Cannot save: No local user data loaded.'));
      return;
    }

    try {
      final client = Supabase.instance.client;
      final userId = client.auth.currentUser?.id;

      if (userId == null || userId.isEmpty) {
        emit(const GlobalError('Cannot save: User is not authenticated.'));
        return;
      }

      await client.from('user_progress').upsert({
        'user_id': userId,
        'total_xp': currentState.xp,
        'xp_goal': currentState.xpGoal,
        'level': currentState.level,
        'streak': currentState.streak,
        'completed_lessons': {},
        'hours_studied': currentState.hours,
        'notes_count': currentState.notes,
        'uploaded_notes_count': currentState.files,
        'last_updated': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');
    } catch (e) {
      emit(GlobalError('Failed to save: ${e.toString()}'));
    }
  }

  String _emailToName(String email) {
    if (!email.contains('@')) return email.isEmpty ? 'Learner' : email;
    return email.split('@').first;
  }

  String beautifyCreatedAt(String createdAt) {
    if (createdAt.isEmpty) return '';
    final date = DateTime.parse(createdAt);
    return '${date.day}/${date.month}/${date.year}';
  }
}

final class _LearningActivityData {
  const _LearningActivityData({
    required this.bestWeekDays,
    required this.thisWeekDays,
    required this.totalActiveDays,
    required this.activityDays,
    required this.weeksTracked,
  });

  factory _LearningActivityData.fromJson(Map<String, dynamic> json) {
    final rawDays = json['activity_days'];
    final activityDays = rawDays is List
        ? rawDays
              .whereType<Map>()
              .map(
                (day) => ActivityDay.fromJson(Map<String, dynamic>.from(day)),
              )
              .toList(growable: false)
        : const <ActivityDay>[];

    return _LearningActivityData(
      bestWeekDays: json['best_week_days'] as int? ?? 0,
      thisWeekDays: json['this_week_days'] as int? ?? 0,
      totalActiveDays: json['total_active_days'] as int? ?? 0,
      activityDays: activityDays,
      weeksTracked: json['weeks_tracked'] as int? ?? 0,
    );
  }

  final int bestWeekDays;
  final int thisWeekDays;
  final int totalActiveDays;
  final List<ActivityDay> activityDays;
  final int weeksTracked;
}
