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

      emit(
        GlobalLoaded(
          displayName: _emailToName(profile?.email ?? ''),
          xp: 1000,
          level: 0,
          streak: 0,
          lessons: 0,
          hours: 0,
          notes: 0,
          files: 0,
          xpGoal: 0,
          joinDate: beautifyCreatedAt(createdAt ?? ''),
        ),
      );
    } catch (e) {
      emit(GlobalError(e.toString()));
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
