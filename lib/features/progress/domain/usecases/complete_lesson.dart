import '../repositories/progress_repository.dart';

class CompleteLesson {
  final ProgressRepository repository;

  CompleteLesson(this.repository);

  Future<void> call(String lessonId) => repository.completeLesson(lessonId);
}
