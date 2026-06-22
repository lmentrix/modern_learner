import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:modern_learner_production/auth/User/service/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'global_event.dart';
part 'global_state.dart';

class GlobalBloc extends Bloc<GlobalEvent, GlobalState> {
  GlobalBloc({required UserService userService})
    : _userService = userService,
      super(GlobalInitial()) {
    on<FetchGlobalStats>(_onFetch);
    on<RefreshGlobalStats>(_onRefresh);
    on<SaveGlobalStats>(_onSave);
  }

  final UserService _userService;

  Future<void> _onFetch(
    FetchGlobalStats event,
    Emitter<GlobalState> emit,
  ) async {
    emit(GlobalLoading());
    await _load(emit);
  }

  Future<void> _onRefresh(
    RefreshGlobalStats event,
    Emitter<GlobalState> emit,
  ) async {
    await _load(emit);
  }

  Future<void> _load(Emitter<GlobalState> emit) async {
    try {
      final client = Supabase.instance.client;

      final profile = client.auth.currentUser;
      final userId = profile?.id ?? '';
      final createdAt = profile?.createdAt;

      if (userId.isEmpty) {
        emit(const GlobalError('Not authenticated'));
        return;
      }

      final Map<String, dynamic> userInfo = await client
          .from('user_progress')
          .select()
          .eq('user_id', userId)
          .single(); // .single() returns Future<Map<String, dynamic>>

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
        ),
      );
    } catch (e) {
      emit(GlobalError(e.toString()));
    }
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
