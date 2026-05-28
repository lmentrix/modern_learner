import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CourseService {
  CourseService._();
  static final CourseService instance = CourseService._();

  SupabaseClient get _client => Supabase.instance.client;
  static const _table = 'user_courses';

  // Fetch all courses for the current user.
  Future<List<UserCourseModel>> fetchCourses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final rows = await _client
        .from(_table)
        .select()
        .eq('user_id', userId)
        .order('created_at');

    return rows.map((r) => UserCourseModel.fromJson(r)).toList();
  }

  // Fetch a single course by ID. Returns null if not found.
  Future<UserCourseModel?> fetchCourse(String courseId) async {
    final rows = await _client
        .from(_table)
        .select()
        .eq('id', courseId)
        .limit(1);

    if (rows.isEmpty) return null;
    return UserCourseModel.fromJson(rows.first);
  }

  // Insert a new course. Returns the created model with its generated UUID.
  Future<UserCourseModel> createCourse(CreateUserCourseRequest request) async {
    final rows = await _client.from(_table).insert(request.toJson()).select();

    return UserCourseModel.fromJson(rows.first);
  }

  // Upsert: finds an existing course matching (user_id, title, topic, level, native_language)
  // or creates a new one. Returns the UUID either way.
  Future<String> upsertCourse(CreateUserCourseRequest request) async {
    final existing = await _client
        .from(_table)
        .select('id')
        .eq('user_id', request.userId)
        .eq('title', request.title)
        .eq('topic', request.topic)
        .eq('level', request.level)
        .eq('native_language', request.nativeLanguage)
        .limit(1);

    if (existing.isNotEmpty) {
      return existing.first['id'] as String;
    }

    final created = await createCourse(request);
    return created.id;
  }

  // Update specific fields on a course. No-op if [request.isEmpty].
  Future<UserCourseModel?> updateCourse(
    String courseId,
    UpdateUserCourseRequest request,
  ) async {
    if (request.isEmpty) return fetchCourse(courseId);

    final rows = await _client
        .from(_table)
        .update(request.toJson())
        .eq('id', courseId)
        .select();

    if (rows.isEmpty) return null;
    return UserCourseModel.fromJson(rows.first);
  }

  // Delete a single course. CASCADE in the DB removes associated XP/achievements.
  Future<void> deleteCourse(String courseId) async {
    await _client.from(_table).delete().eq('id', courseId);
  }

  // Delete multiple courses by ID in one request.
  Future<void> deleteCourses(List<String> courseIds) async {
    if (courseIds.isEmpty) return;
    await _client.from(_table).delete().inFilter('id', courseIds);
  }

  // Delete all courses for the current user.
  Future<void> deleteAllCourses() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return;
    await _client.from(_table).delete().eq('user_id', userId);
  }
}
