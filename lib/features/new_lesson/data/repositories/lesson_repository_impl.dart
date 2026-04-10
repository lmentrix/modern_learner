import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/new_lesson/data/models/lesson_model.dart';
import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';

class LessonRepositoryImpl implements LessonRepository {
  const LessonRepositoryImpl(this._supabase, this._roadmapService);

  final SupabaseClient _supabase;
  final RoadmapGenerationService _roadmapService;

  static const _table = 'lessons';

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }

  @override
  Future<NewLesson> createLesson({
    required NewLessonType lessonType,
    required String contentType,
    required String topic,
    required String difficulty,
    required String title,
    Map<String, dynamic>? content,
  }) async {
    final nativeLanguage = await _getNativeLanguage();
    final roadmapJson = await _roadmapService.generateLessonRoadmapJson(
      lessonType: lessonType.name,
      topic: topic,
      contentType: contentType,
      level: difficulty.toLowerCase(),
      nativeLanguage: nativeLanguage,
    );

    final generatedContent = <String, dynamic>{
      if (content != null) ...content,
      'topic': topic,
      'roadmapLanguage': contentType,
      'nativeLanguage': nativeLanguage,
      'level': difficulty.toLowerCase(),
      'roadmap': roadmapJson,
    };

    final payload = <String, dynamic>{
      'user_id': _userId,
      'lesson_type': lessonType.name,
      'content_type': contentType,
      'difficulty': difficulty,
      'title': title,
      'status': NewLessonStatus.active.name,
      'content': generatedContent,
    };

    final row = await _supabase.from(_table).insert(payload).select().single();

    return LessonModel.fromJson(row);
  }

  @override
  Future<List<NewLesson>> getLessons() async {
    final rows = await _supabase
        .from(_table)
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false);

    return rows.map<NewLesson>((r) => LessonModel.fromJson(r)).toList();
  }

  @override
  Future<NewLesson> getLesson(String id) async {
    final row = await _supabase
        .from(_table)
        .select()
        .eq('id', id)
        .eq('user_id', _userId)
        .single();

    return LessonModel.fromJson(row);
  }

  @override
  Future<NewLesson> updateLesson({
    required String id,
    String? contentType,
    String? difficulty,
    String? title,
    Map<String, dynamic>? content,
    NewLessonStatus? status,
  }) async {
    final updates = <String, dynamic>{};
    if (contentType != null) updates['content_type'] = contentType;
    if (difficulty != null) updates['difficulty'] = difficulty;
    if (title != null) updates['title'] = title;
    if (content != null) updates['content'] = content;
    if (status != null) updates['status'] = status.name;

    if (updates.isEmpty) return getLesson(id);

    final row = await _supabase
        .from(_table)
        .update(updates)
        .eq('id', id)
        .eq('user_id', _userId)
        .select()
        .single();

    return LessonModel.fromJson(row);
  }

  @override
  Future<void> deleteLesson(String id) async {
    await _supabase.from(_table).delete().eq('id', id).eq('user_id', _userId);
  }

  Future<String> _getNativeLanguage() async {
    try {
      final row = await _supabase
          .from('profiles')
          .select('native_language')
          .eq('id', _userId)
          .maybeSingle();

      final nativeLanguage = row?['native_language'] as String?;
      if (nativeLanguage != null && nativeLanguage.trim().isNotEmpty) {
        return nativeLanguage.trim();
      }
    } catch (_) {}

    return 'English';
  }
}
