import 'package:modern_learner_production/features/achievemenet/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievemenet/service/achievement_service.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';

class AchievementProgressTracker {
  const AchievementProgressTracker({this.service = const AchievementService()});

  final AchievementService service;

  Future<void> trackChapterExerciseCompleted({
    required ChapterExerciseCompletionResult result,
    required int xpEarned,
    required int totalChapters,
    required bool isVoiceLesson,
  }) async {
    final progressPercent = totalChapters <= 0
        ? 0
        : ((result.chapterNumber / totalChapters) * 100).round();
    final scorePercent = result.scorePercent;
    final mistakes = result.mistakesCount;

    final signals = <AchievementSignal>[
      const AchievementSignal(metric: AchievementMetric.activitiesCompleted),
      const AchievementSignal(
        metric: AchievementMetric.learningActivitiesCompleted,
      ),
      const AchievementSignal(metric: AchievementMetric.exercisesCompleted),
      const AchievementSignal(metric: AchievementMetric.lessonsCompleted),
      const AchievementSignal(metric: AchievementMetric.quizzesCompleted),
      const AchievementSignal(metric: AchievementMetric.assessmentsCompleted),
      AchievementSignal(
        metric: AchievementMetric.xpEarned,
        incrementBy: xpEarned,
      ),
      AchievementSignal(
        metric: AchievementMetric.courseProgressPercent,
        absoluteValue: progressPercent,
        metadata: {
          'chapter_number': result.chapterNumber,
          'subcontent_number': result.subcontentNumber,
          'total_chapters': totalChapters,
          'score': result.score,
          'total_questions': result.totalQuestions,
          'score_percent': result.scorePercent,
          'mistakes': mistakes,
        },
      ),
      const AchievementSignal(
        metric: AchievementMetric.coursesWithProgress,
        absoluteValue: 1,
      ),
      if (isVoiceLesson)
        const AchievementSignal(
          metric: AchievementMetric.voiceLessonsCompleted,
        ),
      if (result.totalQuestions > 0)
        const AchievementSignal(metric: AchievementMetric.assessmentsPassed),
      if (scorePercent >= 80)
        const AchievementSignal(metric: AchievementMetric.assessmentScore80),
      if (scorePercent >= 90)
        const AchievementSignal(metric: AchievementMetric.assessmentScore90),
      if (scorePercent >= 95)
        const AchievementSignal(metric: AchievementMetric.assessmentScore95),
      if (scorePercent == 100) ...[
        const AchievementSignal(metric: AchievementMetric.assessmentScore100),
        const AchievementSignal(metric: AchievementMetric.perfectExercises),
        const AchievementSignal(metric: AchievementMetric.perfectAssessments),
        const AchievementSignal(metric: AchievementMetric.zeroMistakeLessons),
      ],
      if (mistakes > 0)
        AchievementSignal(
          metric: AchievementMetric.mistakesReviewed,
          incrementBy: mistakes,
        ),
      if (scorePercent >= 80)
        const AchievementSignal(
          metric: AchievementMetric.averageAccuracy80Activities,
        ),
      if (scorePercent >= 85)
        const AchievementSignal(
          metric: AchievementMetric.averageAccuracy85Activities,
        ),
      if (scorePercent >= 90)
        const AchievementSignal(
          metric: AchievementMetric.averageAccuracy90Activities,
        ),
      if (progressPercent >= 100) ...[
        const AchievementSignal(metric: AchievementMetric.coursesCompleted),
        const AchievementSignal(
          metric: AchievementMetric.completedCoursesAtFullProgress,
        ),
      ],
    ];

    await service.recordSignals(signals);
  }
}
