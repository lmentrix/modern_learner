import 'package:modern_learner_production/features/new_lesson/domain/entities/lesson.dart';
import 'package:modern_learner_production/features/new_lesson/domain/repositories/lesson_repository.dart';

class GetLessons {
  const GetLessons(this._repository);
  final LessonRepository _repository;

  Future<List<NewLesson>> call() => _repository.getLessons();
}
