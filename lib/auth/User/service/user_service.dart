import 'package:modern_learner_production/auth/User/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<UserModel> fetchUser() async {
    final identities = await _client.auth.getUserIdentities();
    if (identities.isEmpty) {
      throw Exception('No identities found for current user');
    }
    return UserModel.fromIdentity(identities.first);
  }

  Future<List<UserModel>> fetchAllUsers() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('created_at');
    return (response as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(UserModel.fromMap)
        .toList();
  }

  Future<UserModel> createProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _client.from('profiles').insert({
      'id': id,
      'name': name,
      'email': email,
      'created_at': now,
      'updated_at': now,
    });
    return UserModel(
      id: id,
      name: name,
      email: email,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  Future<void> deleteProfile(String userId) async {
    await _client.from('profiles').delete().eq('id', userId);
  }
}
