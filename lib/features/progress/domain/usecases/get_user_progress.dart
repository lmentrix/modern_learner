import '../entities/user_progress.dart';
import '../repositories/progress_repository.dart';

class GetUserProgress {
  final ProgressRepository repository;

  GetUserProgress(this.repository);

  Future<UserProgress> call() => repository.getUserProgress();
  Stream<UserProgress> stream() => repository.getProgressStream();
}
