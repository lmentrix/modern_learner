import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';

class UpdateLesson {
  const UpdateLesson(this._repository);
  final LessonRepository _repository;

  Future<NewLesson> call({
    required String id,
    String? contentType,
    String? difficulty,
    String? title,
    Map<String, dynamic>? content,
    NewLessonStatus? status,
  }) {
    return _repository.updateLesson(
      id: id,
      contentType: contentType,
      difficulty: difficulty,
      title: title,
      content: content,
      status: status,
    );
  }
}
