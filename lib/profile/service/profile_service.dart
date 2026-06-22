import 'package:modern_learner_production/profile/model/profile_models.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _client = Supabase.instance.client;

Future<UserProfile> fetchProfile(String userId) async {
  final currentUser = _client.auth.currentUser;
  if (currentUser == null) {
    throw Exception('Not authenticated');
  }

  final response = await _client
      .from('profiles')
      .select('*, user_progress(*)')
      .eq('id', currentUser.id)
      .single();

  return UserProfile.fromJson(response);
}

Future<UserProfile> saveData() async {
  final currentUser = _client.auth.currentUser;
  if (currentUser == null) {
    throw Exception('Not authenticated');
  }

  await _client.from('user_progress').upsert({
    'user_id': currentUser.id,
    'total_xp': 0,
    'xp_goal': 0,
    'level': 0,
    'streak': 0,
    'completed_lessons': 0,
    'hours_studied': 0,
    'notes_count': 0,
    'voice_notes_count': 0,
    'uploaded_notes_count': 0,
    'last_updated': DateTime.now().toIso8601String(),
  });

  return fetchProfile(currentUser.id);
}

Future<List<ActivityDay>> fetchActivityDays() async {
  final currentUser = _client.auth.currentUser;
  if (currentUser == null) {
    throw Exception('Not authenticated');
  }

  final response = await _client
      .from('learning_activity_days')
      .select()
      .eq('user_id', currentUser.id)
      .order('activity_date', ascending: true);

  return (response as List<dynamic>)
      .map((row) => ActivityDay.fromJson(row as Map<String, dynamic>))
      .toList();
}

Future<void> upsertActivityDay(ActivityDay day) async {
  final currentUser = _client.auth.currentUser;
  if (currentUser == null) {
    throw Exception('Not authenticated');
  }

  await _client.from('learning_activity_days').upsert({
    'user_id': currentUser.id,
    'activity_date': day.date.toIso8601String().split('T').first,
  });
}
