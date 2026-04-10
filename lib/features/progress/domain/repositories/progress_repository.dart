import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

abstract class ProgressRepository {
  Future<Roadmap> getRoadmap({ProgressCourseSelection? courseSelection});
  Future<Roadmap> regenerateRoadmap({ProgressCourseSelection? courseSelection});
  Future<UserProgress> getUserProgress();
  Future<void> startLesson(String lessonId);
  Future<void> completeLesson(String lessonId);
  Future<void> updateLessonProgress(String lessonId, double progress);
  Stream<UserProgress> getProgressStream();
}
