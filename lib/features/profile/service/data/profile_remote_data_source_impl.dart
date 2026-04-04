import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/errors/exceptions.dart';
import 'package:modern_learner_production/features/profile/service/data/profile_remote_data_source.dart';
import 'package:modern_learner_production/features/profile/service/model/profile_model.dart';

@LazySingleton(as: ProfileRemoteDataSource)
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  const ProfileRemoteDataSourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<ProfileModel> getProfile() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException();
    }

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();

      return ProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to fetch profile: ${e.message}');
    }
  }

  @override
  Future<ProfileModel> updateProfile({
    required String name,
    String? avatarUrl,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException();
    }

    try {
      final updateData = <String, dynamic>{
        'name': name,
        // Note: updated_at is automatically handled by handle_updated_at() trigger
      };
      
      // Only include avatar_url if provided
      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      final response = await _supabase
          .from('profiles')
          .update(updateData)
          .eq('id', userId)
          .select()
          .single();

      return ProfileModel.fromMap(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update profile: ${e.message}');
    }
  }
}
