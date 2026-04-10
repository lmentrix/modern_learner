import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';

class CreateLesson {
  const CreateLesson(this._repository);
  final LessonRepository _repository;

  Future<NewLesson> call({
    required NewLessonType lessonType,
    required String contentType,
    required String difficulty,
    required String title,
    Map<String, dynamic>? content,
  }) {
    return _repository.createLesson(
      lessonType: lessonType,
      contentType: contentType,
      difficulty: difficulty,
      title: title,
      content: content,
    );
  }
}
