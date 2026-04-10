import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';

class GetLesson {
  const GetLesson(this._repository);
  final LessonRepository _repository;

  Future<NewLesson> call(String id) => _repository.getLesson(id);
}
