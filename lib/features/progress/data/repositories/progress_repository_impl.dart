import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';
import 'package:modern_learner_production/features/progress/service/chapter_content_service.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  ProgressRepositoryImpl({
    required this.supabase,
    required this.roadmapService,
    required this.chapterContentService,
    required this.lessonContentService,
  });

  final SupabaseClient supabase;
  final RoadmapGenerationService roadmapService;
  final ChapterContentService chapterContentService;
  final LessonContentService lessonContentService;

  final _progressController = StreamController<UserProgress>.broadcast();

  UserProgress _userProgress = const UserProgress(
    totalXp: 0,
    level: 1,
    gems: 0,
    streak: 0,
    completedLessons: {},
    lessonProgress: {},
    completedChapters: {},
    unlockedAchievements: [],
    currentRoadmapId: '',
  );

  @override
  Future<Roadmap> getRoadmap() async {
    final userId = supabase.auth.currentUser?.id;

    String topic = 'general programming';
    String language = 'English';
    String level = 'beginner';
    String nativeLanguage = 'English';

    if (userId != null) {
      try {
        final row = await supabase
            .from('profiles')
            .select('topic, target_language, proficiency_level, native_language')
            .eq('id', userId)
            .single();
        topic = row['topic'] as String? ?? topic;
        language = row['target_language'] as String? ?? language;
        level = row['proficiency_level'] as String? ?? level;
        nativeLanguage = row['native_language'] as String? ?? nativeLanguage;
      } catch (_) {}
    }

    final rawRoadmap = await roadmapService.generateRoadmap(
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );

    return _applyUserProgress(rawRoadmap, _userProgress);
  }

  @override
  Future<Roadmap> regenerateRoadmap() async {
    final userId = supabase.auth.currentUser?.id;

    String topic = 'general programming';
    String language = 'English';
    String level = 'beginner';
    String nativeLanguage = 'English';

    if (userId != null) {
      try {
        final row = await supabase
            .from('profiles')
            .select('topic, target_language, proficiency_level, native_language')
            .eq('id', userId)
            .single();
        topic = row['topic'] as String? ?? topic;
        language = row['target_language'] as String? ?? language;
        level = row['proficiency_level'] as String? ?? level;
        nativeLanguage = row['native_language'] as String? ?? nativeLanguage;
      } catch (_) {}
    }

    // Reset progress BEFORE any awaits so concurrent getUserProgress() calls
    // return the cleared state, not the old one.
    _userProgress = const UserProgress(
      totalXp: 0,
      level: 1,
      gems: 0,
      streak: 0,
      completedLessons: {},
      lessonProgress: {},
      completedChapters: {},
      unlockedAchievements: [],
      currentRoadmapId: '',
    );
    _progressController.add(_userProgress);

    await Future.wait([
      roadmapService.clearCache(
        topic: topic,
        language: language,
        level: level,
        nativeLanguage: nativeLanguage,
      ),
      chapterContentService.clearAllCaches(),
      lessonContentService.clearAllCaches(),
    ]);

    final rawRoadmap = await roadmapService.generateRoadmap(
      topic: topic,
      language: language,
      level: level,
      nativeLanguage: nativeLanguage,
    );

    return _applyUserProgress(rawRoadmap, _userProgress);
  }

  @override
  Future<UserProgress> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _userProgress;
  }

  @override
  Future<void> startLesson(String lessonId) async {
    _userProgress = _userProgress.copyWith(
      lessonProgress: {
        ..._userProgress.lessonProgress,
        lessonId: 0.1,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> completeLesson(String lessonId) async {
    _userProgress = _userProgress.copyWith(
      totalXp: _userProgress.totalXp + 100,
      level: (_userProgress.totalXp + 100) ~/ 500 + 1,
      gems: _userProgress.gems + 7,
      completedLessons: {
        ..._userProgress.completedLessons,
        lessonId: DateTime.now(),
      },
      lessonProgress: Map.from(_userProgress.lessonProgress)..remove(lessonId),
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> updateLessonProgress(String lessonId, double progress) async {
    _userProgress = _userProgress.copyWith(
      lessonProgress: {
        ..._userProgress.lessonProgress,
        lessonId: progress,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Stream<UserProgress> getProgressStream() => _progressController.stream;

  // ── Helper: overlay user progress onto AI-generated roadmap ───────────────

  Roadmap _applyUserProgress(Roadmap roadmap, UserProgress progress) {
    final completedChapterIds = <String>{};

    final updatedChapters = roadmap.chapters.map((chapter) {
      final prereqsMet = chapter.prerequisites.isEmpty ||
          chapter.prerequisites.every(completedChapterIds.contains);

      List<Lesson> updatedLessons;

      if (!prereqsMet) {
        updatedLessons =
            chapter.lessons.map((l) => l.copyWith(status: LessonStatus.locked)).toList();
      } else {
        bool prevCompleted = true;
        updatedLessons = chapter.lessons.map((lesson) {
          LessonStatus status;
          if (progress.completedLessons.containsKey(lesson.id)) {
            status = LessonStatus.completed;
            prevCompleted = true;
          } else if (progress.lessonProgress.containsKey(lesson.id)) {
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
