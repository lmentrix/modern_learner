import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';

class DeleteLesson {
  const DeleteLesson(this._repository);
  final LessonRepository _repository;

  Future<void> call(String id) => _repository.deleteLesson(id);
}
