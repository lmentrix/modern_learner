import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';

const _table = 'lessons';

Future<AddLesson> addLessonService({
  required String userId,
  required String title,
  required Map<String, dynamic> content,
  required LessonType lessonType,
  LessonStatus status = LessonStatus.draft,
}) async {
  final row = await supabase
      .from(_table)
      .insert({
        'user_id': userId,
        'title': title,
        'content': content,
        'lesson_type': lessonType.name,
        'status': status.name,
      })
      .select()
      .single();

  return AddLesson.fromRow(row);
}

Future<List<AddLesson>> getLessonsService({required String userId}) async {
  final rows = await supabase
      .from(_table)
      .select()
      .eq('user_id', userId)
      .order('created_at', ascending: false);

  return rows.map(AddLesson.fromRow).toList();
}

Future<AddLesson?> getLessonByIdService({required String id}) async {
  final rows = await supabase.from(_table).select().eq('id', id).limit(1);

  if (rows.isEmpty) return null;
  return AddLesson.fromRow(rows.first);
}

Future<AddLesson> updateLessonService({
  required String id,
  String? title,
  Map<String, dynamic>? content,
  LessonType? lessonType,
  LessonStatus? status,
}) async {
  final row = await supabase
      .from(_table)
      .update({
        if (title != null) 'title': title,
        if (content != null) 'content': content,
        if (lessonType != null) 'lesson_type': lessonType.name,
        if (status != null) 'status': status.name,
        'updated_at': DateTime.now().toIso8601String(),
      })
      .eq('id', id)
      .select()
      .single();

  return AddLesson.fromRow(row);
}

Future<void> deleteLessonService({required String id}) async {
  await supabase.from(_table).delete().eq('id', id);
}
