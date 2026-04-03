import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class StartLesson {

  StartLesson(this.repository);
  final ProgressRepository repository;

  Future<void> call(String lessonId) => repository.startLesson(lessonId);
}
