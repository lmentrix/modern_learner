import 'package:modern_learner_production/auth/User/model/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserService {
  SupabaseClient get _client => Supabase.instance.client;

  Future<UserModel> fetchUser(String userId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();
    return UserModel.fromMap(response);
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

  Future<UserModel> upsertProfile({
    required String id,
    required String name,
    required String email,
  }) async {
    final now = DateTime.now().toIso8601String();
    await _client.from('profiles').upsert({
      'id': id,
      'name': name,
      'email': email,
      'updated_at': now,
    }, onConflict: 'id');
    return fetchUser(id);
  }

  Future<UserModel> updateProfile({
    required String id,
    String? name,
    String? email,
  }) async {
    final data = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (name != null) data['name'] = name;
    if (email != null) data['email'] = email;

    await _client.from('profiles').update(data).eq('id', id);
    return fetchUser(id);
  }

  Future<void> deleteProfile(String userId) async {
    await _client.from('profiles').delete().eq('id', userId);
  }
}
