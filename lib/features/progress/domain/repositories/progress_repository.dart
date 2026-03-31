import '../entities/roadmap.dart';
import '../entities/user_progress.dart';

abstract class ProgressRepository {
  Future<Roadmap> getRoadmap();
  Future<UserProgress> getUserProgress();
  Future<void> startLesson(String lessonId);
  Future<void> completeLesson(String lessonId);
  Future<void> updateLessonProgress(String lessonId, double progress);
  Stream<UserProgress> getProgressStream();
}
