import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

/// Reads voice lesson content stored in `lessons.content.voice_lesson` JSONB.
class VoiceLessonSupabaseService {
  const VoiceLessonSupabaseService({required this.supabase});

  final SupabaseClient supabase;

  /// Returns the [VoiceLessonEntity] for [lessonId], or `null` if the row has
  /// no voice_lesson payload (e.g. a school lesson or a legacy static id).
  Future<VoiceLessonEntity?> fetchByLessonId(String lessonId) async {
    try {
      final row = await supabase
          .from('lessons')
          .select('id, title, content, content_type, difficulty')
          .eq('id', lessonId)
          .eq('lesson_type', 'language')
          .maybeSingle();

      if (row == null) return null;

      final content = row['content'] as Map<String, dynamic>?;
      final voiceJson = content?['voice_lesson'] as Map<String, dynamic>?;
      if (voiceJson == null) return null;

      // Merge the lesson-level fields into the voice JSON so that the entity
      // always has a valid id, title and level even if the AI left them blank.
      final merged = <String, dynamic>{
        ...voiceJson,
        'id': row['id'] as String,
        if ((voiceJson['title'] as String?)?.isEmpty ?? true)
          'title': row['title'] as String? ?? 'Voice Lesson',
        if ((voiceJson['level'] as String?)?.isEmpty ?? true)
          'level': row['difficulty'] as String? ?? 'Beginner',
      };

      return VoiceLessonEntity.fromJson(merged);
    } catch (_) {
      return null;
    }
  }

  /// Returns all voice lessons created by the current user, newest first.
  Future<List<VoiceLessonEntity>> fetchAllForUser() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return [];
    try {
      final rows = await supabase
          .from('lessons')
          .select('id, title, content, content_type, difficulty')
          .eq('user_id', uid)
          .eq('lesson_type', 'language')
          .neq('status', 'completed')
          .order('created_at', ascending: false);

      return (rows as List).map((row) {
        final r = row as Map<String, dynamic>;
        final content = r['content'] as Map<String, dynamic>?;
        final voiceJson = content?['voice_lesson'] as Map<String, dynamic>?;
        if (voiceJson == null) return null;
        return VoiceLessonEntity.fromJson({
          ...voiceJson,
          'id': r['id'] as String,
          if ((voiceJson['title'] as String?)?.isEmpty ?? true)
            'title': r['title'] as String? ?? 'Voice Lesson',
          if ((voiceJson['level'] as String?)?.isEmpty ?? true)
            'level': r['difficulty'] as String? ?? 'Beginner',
        });
      }).whereType<VoiceLessonEntity>().toList();
    } catch (_) {
      return [];
    }
  }
}
