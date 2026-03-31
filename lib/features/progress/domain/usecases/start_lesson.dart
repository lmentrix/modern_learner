import '../repositories/progress_repository.dart';

class StartLesson {
  final ProgressRepository repository;

  StartLesson(this.repository);

  Future<void> call(String lessonId) => repository.startLesson(lessonId);
}
