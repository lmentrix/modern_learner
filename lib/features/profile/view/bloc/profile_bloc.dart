import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modern_learner_production/features/profile/data/profile_entity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  ProfileEntity _currentProfile() {
    final user = Supabase.instance.client.auth.currentUser;
    final displayName = user?.userMetadata?['name'] as String? ?? 'User';
    final email = user?.email ?? '';
    final avatarUrl = user?.userMetadata?['avatar_url'] as String?;
    return ProfileEntity(
      displayName: displayName,
      email: email,
      avatarUrl: avatarUrl,
    );
  }

  Future<void> _onLoadRequested(
    ProfileLoadRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    emit(
      state.copyWith(
        status: ProfileStatus.success,
        profile: _currentProfile(),
        errorMessage: null,
      ),
    );
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    emit(
      state.copyWith(
        status: ProfileStatus.success,
        profile: (state.profile ?? _currentProfile()).copyWith(
          displayName: event.name,
          avatarUrl: event.avatarUrl,
        ),
        errorMessage: null,
      ),
    );
  }
}
