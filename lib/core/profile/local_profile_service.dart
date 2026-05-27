import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalProfileService {
  LocalProfileService({
    required SharedPreferences sharedPreferences,
    ProfileService? profileService,
    String? supabaseName,
    String? supabaseEmail,
  }) : _sharedPreferences = sharedPreferences,
       _profileService = profileService ?? ProfileService(),
       _identity = ValueNotifier<ProfileIdentity>(
         _loadIdentity(
           sharedPreferences,
           supabaseName: supabaseName,
           supabaseEmail: supabaseEmail,
         ),
       ) {
    _refreshFromRemoteSilently();
  }

  static const _displayNameKey = 'local_profile_display_name';
  static const _profileLabelKey = 'local_profile_label';
  static const _defaultDisplayName = 'Learner';
  static const _defaultProfileLabel = 'On-device profile';

  final SharedPreferences _sharedPreferences;
  final ProfileService _profileService;
  final ValueNotifier<ProfileIdentity> _identity;

  ValueListenable<ProfileIdentity> get identityListenable => _identity;

  ProfileIdentity get currentIdentity => _identity.value;

  Future<void> updateProfile({
    required String displayName,
    String? profileLabel,
  }) async {
    final sanitizedName = _sanitize(displayName, fallback: _defaultDisplayName);

    if (_profileService.currentUserId != null) {
      final profile = await _profileService.updateCurrentProfile(
        name: sanitizedName,
      );
      final nextIdentity = ProfileIdentity(
        displayName: _sanitize(profile.name, fallback: _defaultDisplayName),
        email: _sanitize(profile.email, fallback: _defaultProfileLabel),
      );
      await _cacheIdentity(nextIdentity);
      _identity.value = nextIdentity;
      return;
    }

    final nextIdentity = ProfileIdentity(
      displayName: sanitizedName,
      email: _sanitize(
        profileLabel ?? currentIdentity.email,
        fallback: _defaultProfileLabel,
      ),
    );

    await _cacheIdentity(nextIdentity);
    _identity.value = nextIdentity;
  }

  Future<void> refreshFromRemote() async {
    final profile = await _profileService.getCurrentProfile();
    if (profile == null) return;

    final nextIdentity = ProfileIdentity(
      displayName: _sanitize(profile.name, fallback: _defaultDisplayName),
      email: _sanitize(profile.email, fallback: _defaultProfileLabel),
    );

    await _cacheIdentity(nextIdentity);
    _identity.value = nextIdentity;
  }

  static ProfileIdentity _loadIdentity(
    SharedPreferences sharedPreferences, {
    String? supabaseName,
    String? supabaseEmail,
  }) {
    // If no name has been saved locally yet, fall back to the Supabase
    // user's registered name so it shows immediately without an edit.
    final storedName = sharedPreferences.getString(_displayNameKey);
    final displayName = _sanitize(
      storedName?.isNotEmpty == true ? storedName : supabaseName,
      fallback: _defaultDisplayName,
    );
    final storedLabel = sharedPreferences.getString(_profileLabelKey);
    final email = _sanitize(
      storedLabel?.isNotEmpty == true ? storedLabel : supabaseEmail,
      fallback: _defaultProfileLabel,
    );
    return ProfileIdentity(displayName: displayName, email: email);
  }

  /// Re-seeds the identity from Supabase metadata without overwriting any
  /// name the user has explicitly saved via [updateProfile].
  void seedFromSupabase({String? name, String? email}) {
    _refreshFromRemoteSilently();

    if (_profileService.currentUserId != null) return;
    final seeded = ProfileIdentity(
      displayName: _sanitize(name, fallback: _defaultDisplayName),
      email: _sanitize(
        email ?? currentIdentity.email,
        fallback: _defaultProfileLabel,
      ),
    );
    _identity.value = seeded;
  }

  void _refreshFromRemoteSilently() {
    unawaited(refreshFromRemote().catchError((Object _) {}));
  }

  Future<void> _cacheIdentity(ProfileIdentity identity) async {
    await _sharedPreferences.setString(_displayNameKey, identity.displayName);
    await _sharedPreferences.setString(_profileLabelKey, identity.email);
  }

  static String _sanitize(String? value, {required String fallback}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }
}
