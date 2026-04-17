import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/home/service/achievement_evaluator.dart';
import 'package:modern_learner_production/features/progress/data/models/roadmap_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';
import 'package:modern_learner_production/features/progress/service/chapter_content_service.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';
import 'package:modern_learner_production/features/progress/service/user_progress_service.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required this.supabase,
    required this.roadmapService,
    required this.chapterContentService,
    required this.lessonContentService,
    required this.userProgressService,
  });

  final SupabaseClient supabase;
  final RoadmapGenerationService roadmapService;
  final ChapterContentService chapterContentService;
  final LessonContentService lessonContentService;
  final UserProgressService userProgressService;

  final _progressController = StreamController<UserProgress>.broadcast();
  bool _initialized = false;

  UserProgress _userProgress = const UserProgress(
    totalXp: 0,
    level: 1,
    gems: 0,
    streak: 0,
    completedLessons: {},
    lessonProgress: {},
    completedChapters: {},
    achievementLevels: {},
    currentRoadmapId: '',
  );

  @override
  Future<Roadmap> getRoadmap({ProgressCourseSelection? courseSelection}) async {
    final request = await _resolveRoadmapRequest(
      courseSelection: courseSelection,
    );
    final rawRoadmap = await _loadRoadmap(request);
    _activateRoadmap(rawRoadmap.id);
    return _applyUserProgress(rawRoadmap, _userProgress);
  }

  @override
  Future<Roadmap> regenerateRoadmap({
    ProgressCourseSelection? courseSelection,
  }) async {
    final request = await _resolveRoadmapRequest(
      courseSelection: courseSelection,
    );

    _userProgress = _clearProgressForRoadmap(
      _userProgress,
      _userProgress.currentRoadmapId,
    );
    _progressController.add(_userProgress);

    await Future.wait([
      roadmapService.clearCache(
        topic: request.topic,
        language: request.language,
        level: request.level,
        nativeLanguage: request.nativeLanguage,
      ),
      chapterContentService.clearAllCaches(),
      lessonContentService.clearAllCaches(),
    ]);

    final rawRoadmap = await roadmapService.generateRoadmap(
      topic: request.topic,
      language: request.language,
      level: request.level,
      nativeLanguage: request.nativeLanguage,
    );

    _activateRoadmap(rawRoadmap.id);
    return _applyUserProgress(rawRoadmap, _userProgress);
  }

  @override
  Future<UserProgress> getUserProgress() async {
    if (!_initialized) {
      _initialized = true;
      await _loadFromSupabase();
    }
    return _userProgress;
  }

  @override
  Future<void> startLesson(String lessonId) async {
    final progressKey = _progressKeyForCurrentRoadmap(lessonId);
    _userProgress = _userProgress.copyWith(
      lessonProgress: {..._userProgress.lessonProgress, progressKey: 0.1},
    );
    _progressController.add(_userProgress);
    _persistToSupabase();
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    final progressKey = _progressKeyForCurrentRoadmap(lessonId);
    final newXp = _userProgress.totalXp + 100;
    _userProgress = _userProgress.copyWith(
      totalXp: newXp,
      level: newXp ~/ 500 + 1,
      gems: _userProgress.gems + 7,
      completedLessons: {
        ..._userProgress.completedLessons,
        progressKey: DateTime.now(),
      },
      lessonProgress: Map.from(_userProgress.lessonProgress)
        ..remove(progressKey),
    );
    _evaluateAndApplyAchievements();
    _progressController.add(_userProgress);
    _persistToSupabase();
  }

  @override
  Future<void> updateLessonProgress(String lessonId, double progress) async {
    final progressKey = _progressKeyForCurrentRoadmap(lessonId);
    _userProgress = _userProgress.copyWith(
      lessonProgress: {..._userProgress.lessonProgress, progressKey: progress},
    );
    _progressController.add(_userProgress);
    _persistToSupabase();
  }

  @override
  Stream<UserProgress> getProgressStream() => _progressController.stream;

  Future<_RoadmapRequest> _resolveRoadmapRequest({
    ProgressCourseSelection? courseSelection,
  }) async {
    if (courseSelection != null) {
      return _RoadmapRequest(
        topic: courseSelection.topic,
        language: courseSelection.roadmapLanguage,
        level: courseSelection.level,
        nativeLanguage: courseSelection.nativeLanguage,
        roadmapJson: courseSelection.roadmapJson,
      );
    }

    final userId = supabase.auth.currentUser?.id;

    String topic = 'general programming';
    String language = 'English';
    String level = 'beginner';
    String nativeLanguage = 'English';

    if (userId != null) {
      try {
        final row = await supabase
            .from('profiles')
            .select(
              'topic, target_language, proficiency_level, native_language',
            )
            .eq('id', userId)
            .single();
        topic = row['topic'] as String? ?? topic;
        language = row['target_language'] as String? ?? language;
        level = row['proficiency_level'] as String? ?? level;
        nativeLanguage = row['native_language'] as String? ?? nativeLanguage;
      } catch (_) {}
    }

    return _RoadmapRequest(
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );
  }

  Future<Roadmap> _loadRoadmap(_RoadmapRequest request) async {
    final storedRoadmapJson = request.roadmapJson;
    if (storedRoadmapJson != null) {
      await roadmapService.cacheRoadmapJson(
        storedRoadmapJson,
        topic: request.topic,
        language: request.language,
        level: request.level,
        nativeLanguage: request.nativeLanguage,
      );
      return RoadmapModel.fromJson(storedRoadmapJson).toEntity();
    }

    return roadmapService.generateRoadmap(
      topic: request.topic,
      language: request.language,
      level: request.level,
      nativeLanguage: request.nativeLanguage,
    );
  }

  void _activateRoadmap(String roadmapId) {
    _userProgress = _userProgress.copyWith(currentRoadmapId: roadmapId);
    // Bootstrap achievements (e.g. early_adopter) on first load.
    _evaluateAndApplyAchievements();
    _progressController.add(_userProgress);
    _persistToSupabase();
  }

  // ── Supabase persistence ─────────────────────────────────────────────────────

  Future<void> _loadFromSupabase() async {
    final fetched = await userProgressService.fetchProgress();
    if (fetched != null) _userProgress = fetched;
  }

  void _persistToSupabase() =>
      userProgressService.saveProgress(_userProgress);

  // ── Achievement evaluation ───────────────────────────────────────────────────

  /// Evaluates achievement levels against the current [_userProgress]
  /// and upgrades any achievement that has earned a higher level.
  void _evaluateAndApplyAchievements() {
    final earned = AchievementEvaluator.evaluate(_userProgress);
    final current = Map<String, int>.from(_userProgress.achievementLevels);
    var changed = false;
    for (final entry in earned.entries) {
      final prev = current[entry.key] ?? 0;
      if (entry.value > prev) {
        current[entry.key] = entry.value;
        changed = true;
      }
    }
    if (changed) {
      _userProgress = _userProgress.copyWith(achievementLevels: current);
    }
  }

  String _progressKey(String roadmapId, String lessonId) =>
      '$roadmapId::$lessonId';

  String _progressKeyForCurrentRoadmap(String lessonId) {
    final roadmapId = _userProgress.currentRoadmapId;
    if (roadmapId == null || roadmapId.isEmpty) return lessonId;
    return _progressKey(roadmapId, lessonId);
  }

  UserProgress _clearProgressForRoadmap(
    UserProgress progress,
    String? roadmapId,
  ) {
    if (roadmapId == null || roadmapId.isEmpty) return progress;

    final prefix = '$roadmapId::';

    Map<String, T> withoutRoadmapEntries<T>(Map<String, T> source) => {
      for (final entry in source.entries)
        if (!entry.key.startsWith(prefix)) entry.key: entry.value,
    };

    return progress.copyWith(
      completedLessons: withoutRoadmapEntries(progress.completedLessons),
      lessonProgress: withoutRoadmapEntries(progress.lessonProgress),
      currentRoadmapId: roadmapId,
    );
  }

  bool _hasCompletedLesson(
    UserProgress progress,
    String roadmapId,
    String lessonId,
  ) {
    return progress.completedLessons.containsKey(
          _progressKey(roadmapId, lessonId),
        ) ||
        progress.completedLessons.containsKey(lessonId);
  }

  bool _hasLessonInProgress(
    UserProgress progress,
    String roadmapId,
    String lessonId,
  ) {
    return progress.lessonProgress.containsKey(
          _progressKey(roadmapId, lessonId),
        ) ||
        progress.lessonProgress.containsKey(lessonId);
  }

  Roadmap _applyUserProgress(Roadmap roadmap, UserProgress progress) {
    final completedChapterIds = <String>{};

    final updatedChapters = roadmap.chapters.map((chapter) {
      final prereqsMet =
          chapter.prerequisites.isEmpty ||
          chapter.prerequisites.every(completedChapterIds.contains);

      List<Lesson> updatedLessons;

      if (!prereqsMet) {
        updatedLessons = chapter.lessons
            .map((l) => l.copyWith(status: LessonStatus.locked))
            .toList();
      } else {
        bool prevCompleted = true;
        updatedLessons = chapter.lessons.map((lesson) {
          LessonStatus status;
          if (_hasCompletedLesson(progress, roadmap.id, lesson.id)) {
            status = LessonStatus.completed;
            prevCompleted = true;
          } else if (_hasLessonInProgress(progress, roadmap.id, lesson.id)) {
            status = LessonStatus.inProgress;
            prevCompleted = false;
          } else if (prevCompleted) {
            status = LessonStatus.available;
            prevCompleted = false;
          } else {
            status = LessonStatus.locked;
          }
          return lesson.copyWith(status: status);
        }).toList();
      }

      if (updatedLessons.every((l) => l.status == LessonStatus.completed)) {
        completedChapterIds.add(chapter.id);
      }

      return Chapter(
        id: chapter.id,
        chapterNumber: chapter.chapterNumber,
        title: chapter.title,
        description: chapter.description,
        icon: chapter.icon,
        type: chapter.type,
        xpReward: chapter.xpReward,
        gemReward: chapter.gemReward,
        prerequisites: chapter.prerequisites,
        skills: chapter.skills,
        lessons: updatedLessons,
      );
    }).toList();

    return Roadmap(
      id: roadmap.id,
      title: roadmap.title,
      description: roadmap.description,
      targetLanguage: roadmap.targetLanguage,
      level: roadmap.level,
      totalXp: roadmap.totalXp,
      estimatedHours: roadmap.estimatedHours,
      chapters: updatedChapters,
    );
  }
}

class _RoadmapRequest {
  const _RoadmapRequest({
    required this.topic,
    required this.language,
    required this.level,
    required this.nativeLanguage,
    this.roadmapJson,
  });

  final String topic;
  final String language;
  final String level;
  final String nativeLanguage;
  final Map<String, dynamic>? roadmapJson;
}
