import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';

class GetUserProgress {

  GetUserProgress(this.repository);
  final ProgressRepository repository;

  Future<UserProgress> call() => repository.getUserProgress();
  Stream<UserProgress> stream() => repository.getProgressStream();
}
