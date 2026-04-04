import 'package:modern_learner_production/features/profile/service/model/profile_model.dart';

abstract class ProfileRemoteDataSource {
  /// Get the current user's profile from Supabase
  Future<ProfileModel> getProfile();

  /// Update the current user's profile in Supabase
  Future<ProfileModel> updateProfile({
    required String name,
    String? avatarUrl,
  });
}
