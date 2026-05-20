import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/features/profile/data/profile_entity.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._localProfileService) : super(const ProfileState()) {
    on<ProfileLoadRequested>(_onLoadRequested);
    on<ProfileUpdateRequested>(_onUpdateRequested);
  }

  final LocalProfileService _localProfileService;

  ProfileEntity _currentProfile() {
    final identity = _localProfileService.currentIdentity;
    return ProfileEntity(
      displayName: identity.displayName,
      email: identity.email,
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
    await _localProfileService.updateProfile(displayName: event.name);
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
