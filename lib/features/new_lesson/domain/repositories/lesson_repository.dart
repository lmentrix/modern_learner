import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';

abstract class LessonRepository {
  Future<NewLesson> createLesson({
    required NewLessonType lessonType,
    required String contentType,
    required String difficulty,
    required String title,
    Map<String, dynamic>? content,
  });

  Future<List<NewLesson>> getLessons();

  Future<NewLesson> getLesson(String id);

  Future<NewLesson> updateLesson({
    required String id,
    String? contentType,
    String? difficulty,
    String? title,
    Map<String, dynamic>? content,
    NewLessonStatus? status,
  });

  Future<void> deleteLesson(String id);
}
