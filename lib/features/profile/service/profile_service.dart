import 'package:modern_learner_production/features/profile/model/profile_moderl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileService {
  final SupabaseClient _client = Supabase.instance.client;

  static const String _table = 'profiles';

  String? get currentUserId => _client.auth.currentUser?.id;

  Future<ProfileModel?> getCurrentProfile() async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    final data = await _client
        .from(_table)
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel?> getProfileById(String id) async {
    final data = await _client.from(_table).select().eq('id', id).maybeSingle();

    if (data == null) {
      return null;
    }

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> createProfile({
    required String id,
    required String email,
    String name = '',
    String? avatarUrl,
    String role = 'normal',
    String? topic = 'general programming',
    String? targetLanguage = 'English',
    String? proficiencyLevel = 'beginner',
    String? nativeLanguage = 'English',
  }) async {
    final data = await _client
        .from(_table)
        .insert({
          'id': id,
          'email': email,
          'name': name,
          'avatar_url': avatarUrl,
          'role': role,
          'topic': topic,
          'target_language': targetLanguage,
          'proficiency_level': proficiencyLevel,
          'native_language': nativeLanguage,
        })
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<String?> getCurrentUserName() async {
    final userId = currentUserId;

    if (userId == null) {
      return null;
    }

    final data = await _client
        .from(_table)
        .select('name')
        .eq('id', userId)
        .maybeSingle();

    if (data == null) {
      return null;
    }

    return data['name'] as String?;
  }

  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    final data = await _client
        .from(_table)
        .upsert(profile.toJson())
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<ProfileModel> updateCurrentProfile({
    String? name,
    String? avatarUrl,
    String? topic,
    String? targetLanguage,
    String? proficiencyLevel,
    String? nativeLanguage,
  }) async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    final updates = <String, dynamic>{};

    if (name != null) updates['name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    if (topic != null) updates['topic'] = topic;
    if (targetLanguage != null) updates['target_language'] = targetLanguage;
    if (proficiencyLevel != null) {
      updates['proficiency_level'] = proficiencyLevel;
    }
    if (nativeLanguage != null) {
      updates['native_language'] = nativeLanguage;
    }

    final data = await _client
        .from(_table)
        .update(updates)
        .eq('id', userId)
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  Future<void> deleteCurrentProfile() async {
    final userId = currentUserId;

    if (userId == null) {
      throw Exception('User is not authenticated');
    }

    await _client.from(_table).delete().eq('id', userId);
  }

  Future<bool> isCurrentUserVip() async {
    final profile = await getCurrentProfile();

    return profile?.role == 'vip';
  }
}
