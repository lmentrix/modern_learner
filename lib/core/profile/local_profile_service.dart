import 'package:flutter/foundation.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';

class LocalProfileService {
  LocalProfileService._();
  static final LocalProfileService instance = LocalProfileService._();

  final ValueNotifier<ProfileIdentity> identityListenable = ValueNotifier(
    const ProfileIdentity(displayName: '', email: ''),
  );

  ProfileIdentity get currentIdentity => identityListenable.value;

  /// Call once after auth is confirmed to load the profile from Supabase.
  Future<void> init() async {
    final user = AuthService.instance.currentUser;
    if (user == null) return;

    final email = user.email;
    final profile = await ProfileService().getCurrentProfile();
    identityListenable.value = ProfileIdentity(
      displayName: profile?.name ?? email.split('@').first,
      email: email,
    );
  }

  Future<void> updateProfile({required String displayName}) async {
    await ProfileService().updateCurrentProfile(name: displayName);
    identityListenable.value = ProfileIdentity(
      displayName: displayName,
      email: currentIdentity.email,
    );
  }
}
