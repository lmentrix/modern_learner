import 'package:equatable/equatable.dart';

enum AchievementCategory {
  foundations,
  consistency,
  mastery,
  exploration,
  creation,
  focus,
  collaboration,
  wellbeing,
  challenge,
  career,
}

enum AchievementLevel { starter, explorer, achiever, expert, master }

enum AchievementMetric {
  lessonsCompleted,
  lessonsOpened,
  exercisesCompleted,
  xpEarned,
  learningMinutes,
  singleSessionMinutes,
  activeDays,
  streakDays,
  coursesStarted,
  coursesCompleted,
  completedCoursesAtFullProgress,
  courseProgressPercent,
  subjectsExplored,
  topicsStudied,
  perfectExercises,
  perfectAssessments,
  mistakesReviewed,
  notesCreated,
  goalsSet,
  weeklyGoalsCompleted,
  monthlyGoalMonthsCompleted,
  flashcardsReviewed,
  voiceLessonsCompleted,
  quizzesCompleted,
  quizzesPassed,
  assessmentsCompleted,
  assessmentsPassed,
  assessmentScore80,
  assessmentScore90,
  assessmentScore95,
  assessmentScore100,
  averageAccuracy80Activities,
  averageAccuracy85Activities,
  averageAccuracy90Activities,
  earlySessions,
  nightSessions,
  focusSessions,
  longFocusSessions,
  projectsCreated,
  profileCreated,
  profileUpdates,
  sharesCreated,
  comebackDays,
  challengeWins,
  bookmarksCreated,
  notesOrBookmarksCreated,
  resourcesSaved,
  resourcesDownloaded,
  lessonReplays,
  activitiesCompleted,
  learningActivitiesCompleted,
  sameDayLessonAfterEnrollment,
  improvedQuizScores,
  zeroMistakeLessons,
  coursesWithProgress,
}

class AchievementDefinition extends Equatable {
  const AchievementDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.level,
    required this.metric,
    required this.target,
    required this.xpReward,
    required this.iconKey,
    required this.colorHex,
    required this.actionLabel,
  });

  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final AchievementLevel level;
  final AchievementMetric metric;
  final int target;
  final int xpReward;
  final String iconKey;
  final int colorHex;
  final String actionLabel;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    category,
    level,
    metric,
    target,
    xpReward,
    iconKey,
    colorHex,
    actionLabel,
  ];
}

class AchievementProgress extends Equatable {
  const AchievementProgress({
    required this.achievementId,
    this.progressValue = 0,
    this.unlockedAt,
    this.seenAt,
    this.metadata = const {},
  });

  factory AchievementProgress.fromMap(Map<String, dynamic> map) {
    return AchievementProgress(
      achievementId: map['achievement_id'] as String,
      progressValue: (map['progress_value'] as num?)?.toInt() ?? 0,
      unlockedAt: DateTime.tryParse(map['unlocked_at'] as String? ?? ''),
      seenAt: DateTime.tryParse(map['seen_at'] as String? ?? ''),
      metadata: Map<String, dynamic>.from(map['metadata'] as Map? ?? const {}),
    );
  }

  final String achievementId;
  final int progressValue;
  final DateTime? unlockedAt;
  final DateTime? seenAt;
  final Map<String, dynamic> metadata;

  bool get isUnlocked => unlockedAt != null;
  bool get isUnseen => isUnlocked && seenAt == null;

  AchievementProgress copyWith({
    int? progressValue,
    DateTime? unlockedAt,
    DateTime? seenAt,
    Map<String, dynamic>? metadata,
  }) {
    return AchievementProgress(
      achievementId: achievementId,
      progressValue: progressValue ?? this.progressValue,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      seenAt: seenAt ?? this.seenAt,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toUpsertMap(String userId) {
    return {
      'user_id': userId,
      'achievement_id': achievementId,
      'progress_value': progressValue,
      'unlocked_at': unlockedAt?.toUtc().toIso8601String(),
      'seen_at': seenAt?.toUtc().toIso8601String(),
      'metadata': metadata,
    };
  }

  @override
  List<Object?> get props => [
    achievementId,
    progressValue,
    unlockedAt,
    seenAt,
    metadata,
  ];
}

class UserAchievement extends Equatable {
  const UserAchievement({required this.definition, required this.progress});

  final AchievementDefinition definition;
  final AchievementProgress progress;

  double get completionRatio {
    if (definition.target <= 0) return progress.isUnlocked ? 1 : 0;
    final ratio = progress.progressValue / definition.target;
    return ratio.clamp(0, 1).toDouble();
  }

  int get remaining =>
      (definition.target - progress.progressValue).clamp(0, definition.target);
  bool get isUnlocked => progress.isUnlocked;
  bool get isUnseen => progress.isUnseen;

  @override
  List<Object?> get props => [definition, progress];
}

class AchievementSignal extends Equatable {
  const AchievementSignal({
    required this.metric,
    this.incrementBy = 1,
    this.absoluteValue,
    this.metadata = const {},
  }) : assert(incrementBy >= 0);

  final AchievementMetric metric;
  final int incrementBy;
  final int? absoluteValue;
  final Map<String, dynamic> metadata;

  @override
  List<Object?> get props => [metric, incrementBy, absoluteValue, metadata];
}
