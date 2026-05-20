import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/features/profile/data/profile_identity.dart';

class LocalProfileService {
  LocalProfileService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences,
      _identity = ValueNotifier<ProfileIdentity>(
        _loadIdentity(sharedPreferences),
      );

  static const _displayNameKey = 'local_profile_display_name';
  static const _profileLabelKey = 'local_profile_label';
  static const _defaultDisplayName = 'Learner';
  static const _defaultProfileLabel = 'On-device profile';

  final SharedPreferences _sharedPreferences;
  final ValueNotifier<ProfileIdentity> _identity;

  ValueListenable<ProfileIdentity> get identityListenable => _identity;

  ProfileIdentity get currentIdentity => _identity.value;

  Future<void> updateProfile({
    required String displayName,
    String? profileLabel,
  }) async {
    final nextIdentity = ProfileIdentity(
      displayName: _sanitize(displayName, fallback: _defaultDisplayName),
      email: _sanitize(
        profileLabel ?? currentIdentity.email,
        fallback: _defaultProfileLabel,
      ),
    );

    await _sharedPreferences.setString(
      _displayNameKey,
      nextIdentity.displayName,
    );
    await _sharedPreferences.setString(_profileLabelKey, nextIdentity.email);

    _identity.value = nextIdentity;
  }

  static ProfileIdentity _loadIdentity(SharedPreferences sharedPreferences) {
    return ProfileIdentity(
      displayName: _sanitize(
        sharedPreferences.getString(_displayNameKey),
        fallback: _defaultDisplayName,
      ),
      email: _sanitize(
        sharedPreferences.getString(_profileLabelKey),
        fallback: _defaultProfileLabel,
      ),
    );
  }

  static String _sanitize(String? value, {required String fallback}) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return fallback;
    return trimmed;
  }
}
