import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/progress/data/models/progress_course_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

/// Handles Supabase persistence for the `user_courses` table.
///
/// All methods are safe to call when unauthenticated — they no-op or return
/// empty lists without throwing.
class UserCoursesService {
  const UserCoursesService({required this.supabase});

  final SupabaseClient supabase;

  String? get _uid => supabase.auth.currentUser?.id;

  // ── Read ───────────────────────────────────────────────────────────────────

  /// Returns all courses persisted for the current user, newest first.
  Future<List<ProgressCourseSelection>> fetchCourses() async {
    final uid = _uid;
    if (uid == null) return [];
    try {
      final rows = await supabase
          .from('user_courses')
          .select()
          .eq('user_id', uid)
          .order('created_at', ascending: false);
      return (rows as List)
          .map((r) => ProgressCourseModel.fromRow(r as Map<String, dynamic>)
              .toEntity())
          .toList();
    } catch (_) {
      return [];
    }
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  /// Upserts [course] for the current user.
  /// Conflict key: `user_id, title, topic, level, native_language`.
  Future<void> upsertCourse(ProgressCourseSelection course) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await supabase.from('user_courses').upsert(
        ProgressCourseModel.fromEntity(course).toRow(uid),
        onConflict: 'user_id,title,topic,level,native_language',
      );
    } catch (_) {}
  }

  /// Deletes [course] belonging to the current user.
  Future<void> deleteCourse(ProgressCourseSelection course) async {
    final uid = _uid;
    if (uid == null) return;
    try {
      await supabase
          .from('user_courses')
          .delete()
          .eq('user_id', uid)
          .eq('title', course.title)
          .eq('topic', course.topic)
          .eq('level', course.level)
          .eq('native_language', course.nativeLanguage);
    } catch (_) {}
  }
}
