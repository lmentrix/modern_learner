import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/progress_course_snapshot.dart';
import 'package:modern_learner_production/features/progress/data/progress_module_step.dart';
import 'package:modern_learner_production/features/progress/data/progress_page_data.dart';
import 'package:modern_learner_production/features/progress/data/progress_stat_item.dart';
import 'package:modern_learner_production/features/progress/data/progress_week_day.dart';

ProgressPageData buildProgressPageData({
  required ProgressCourseSelection course,
  int unlockedChapterLimit = 1,
}) {
  final levelFactor = _levelFactor(course.level);
  final roadmap = _extractBaseRoadmapPayload(course.roadmapJson);
  final accentColor = _accentForCourse(course.courseType);
  final moduleSteps = _buildModuleSteps(
    course: course,
    roadmap: roadmap,
    levelFactor: levelFactor,
    accentColor: accentColor,
    unlockedChapterLimit: unlockedChapterLimit,
  );
  final totalLessons = _totalLessons(roadmap, moduleSteps.length);
  final masteredLessons = _estimateMasteredLessons(totalLessons, levelFactor);
  final completion = totalLessons == 0 ? 0.0 : masteredLessons / totalLessons;
  final weeklyGoalMinutes = course.courseType == ProgressCourseType.voice
      ? 180
      : 240;
  final weeklyMinutes = (weeklyGoalMinutes * (0.64 + levelFactor * 0.18))
      .round();
  final totalHours = _estimatedHours(roadmap, totalLessons, levelFactor);
  final currentFocus = moduleSteps.firstWhere(
    (step) => step.isCurrent,
    orElse: () => moduleSteps.first,
  );

  final snapshot = ProgressCourseSnapshot(
    completion: completion.clamp(0.18, 0.94),
    streakDays: 6 + (levelFactor * 10).round(),
    weeklyMinutes: weeklyMinutes,
    weeklyGoalMinutes: weeklyGoalMinutes,
    totalHours: totalHours,
    masteredLessons: masteredLessons,
    totalLessons: totalLessons,
    currentFocus: currentFocus.title,
    momentumLabel: course.courseType == ProgressCourseType.voice
        ? 'Speaking confidence is building through short, steady reps.'
        : 'Your study rhythm is turning abstract topics into usable depth.',
    accentColor: accentColor,
  );

  return ProgressPageData(
    course: course,
    snapshot: snapshot,
    statItems: _buildStatItems(
      snapshot: snapshot,
      moduleCount: moduleSteps.length,
      accentColor: accentColor,
    ),
    weekDays: _buildWeekDays(
      goalMinutes: weeklyGoalMinutes,
      weeklyMinutes: weeklyMinutes,
      levelFactor: levelFactor,
    ),
    moduleSteps: moduleSteps,
  );
}

List<ProgressStatItem> _buildStatItems({
  required ProgressCourseSnapshot snapshot,
  required int moduleCount,
  required Color accentColor,
}) {
  return [
    ProgressStatItem(
      icon: Icons.local_fire_department_rounded,
      label: 'Current streak',
      value: '${snapshot.streakDays} days',
      detail: 'Your longest run this month',
      toneColor: const Color(0xFFFF9F43),
    ),
    ProgressStatItem(
      icon: Icons.auto_graph_rounded,
      label: 'Completion',
      value: '${(snapshot.completion * 100).round()}%',
      detail:
          '${snapshot.masteredLessons}/${snapshot.totalLessons} lessons done',
      toneColor: accentColor,
    ),
    ProgressStatItem(
      icon: Icons.schedule_rounded,
      label: 'Deep work',
      value: '${snapshot.totalHours} hrs',
      detail: 'Estimated invested across the roadmap',
      toneColor: AppColors.tertiary,
    ),
    ProgressStatItem(
      icon: Icons.layers_rounded,
      label: 'Active chapters',
      value: '$moduleCount',
      detail: 'Sequenced modules in this track',
      toneColor: AppColors.secondary,
    ),
  ];
}

List<ProgressWeekDay> _buildWeekDays({
  required int goalMinutes,
  required int weeklyMinutes,
  required double levelFactor,
}) {
  final spread = <double>[0.75, 0.92, 0.58, 1.08, 1.16, 0.88, 0.63];
  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  final todayIndex = DateTime.now().weekday - 1;
  final base =
      weeklyMinutes / spread.fold<double>(0, (sum, item) => sum + item);

  return List<ProgressWeekDay>.generate(labels.length, (index) {
    final scaled = base * spread[index];
    final minutes = (scaled * (0.92 + levelFactor * 0.12)).round();
    return ProgressWeekDay(
      label: labels[index],
      minutes: minutes,
      goalMinutes: goalMinutes ~/ labels.length,
      isToday: index == todayIndex,
    );
  });
}

List<ProgressModuleStep> _buildModuleSteps({
  required ProgressCourseSelection course,
  required Map<String, dynamic> roadmap,
  required double levelFactor,
  required Color accentColor,
  required int unlockedChapterLimit,
}) {
  final chapters = _mapList(roadmap['chapters']);
  if (chapters.isEmpty) {
    return _fallbackModuleSteps(
      course: course,
      levelFactor: levelFactor,
      accentColor: accentColor,
      unlockedChapterLimit: unlockedChapterLimit,
    );
  }

  final currentIndex = (unlockedChapterLimit - 1).clamp(0, chapters.length - 1);
  final tones = <Color>[
    accentColor,
    AppColors.secondary,
    const Color(0xFFFF9F43),
    AppColors.tertiary,
  ];

  return List<ProgressModuleStep>.generate(chapters.length, (index) {
    final chapter = chapters[index];
    final lessons = _mapList(chapter['lessons']);
    final lessonCount = lessons.length;
    final chapterNumber = _chapterNumberFor(chapter, index);
    final progress = index < currentIndex
        ? 1.0
        : index == currentIndex
        ? (0.42 + levelFactor * 0.28).clamp(0.42, 0.88)
        : 0.0;

    return ProgressModuleStep(
      id: _chapterIdFor(chapter, index),
      chapterNumber: chapterNumber,
      icon: (chapter['icon'] ?? _defaultIconForCourse(course.courseType))
          .toString(),
      eyebrow: 'CHAPTER ${chapterNumber.toString().padLeft(2, '0')}',
      title: _stringValue(chapter['title'], fallback: 'Untitled chapter'),
      detail: _stringValue(
        chapter['description'],
        fallback: course.courseType == ProgressCourseType.voice
            ? 'Short speaking loops, feedback, and recall practice.'
            : 'Concept depth, worked examples, and applied practice.',
      ),
      progress: progress,
      durationLabel: _durationLabel(
        chapter['duration_minutes'],
        lessonCount: lessonCount,
        levelFactor: levelFactor,
      ),
      lessonCountLabel: '$lessonCount lessons',
      toneColor: tones[index % tones.length],
      isCurrent: index == currentIndex,
      isLocked: index > currentIndex,
    );
  });
}

List<ProgressModuleStep> _fallbackModuleSteps({
  required ProgressCourseSelection course,
  required double levelFactor,
  required Color accentColor,
  required int unlockedChapterLimit,
}) {
  final titles = course.courseType == ProgressCourseType.voice
      ? [
          'Warm-up phrases',
          'Guided speaking drills',
          'Natural response building',
          'Live fluency checkpoints',
        ]
      : [
          'Core foundations',
          'Worked examples',
          'Applied practice',
          'Mastery and review',
        ];
  final details = course.courseType == ProgressCourseType.voice
      ? [
          'Anchor pronunciation, cadence, and the phrases you use every day.',
          'Repeat, remix, and sharpen short responses until they feel easy.',
          'Move from recognition to confident spontaneous answers.',
          'Push fluency with longer exchanges and higher-pressure prompts.',
        ]
      : [
          'Frame the big ideas so later chapters have a strong base.',
          'Turn theory into patterns with step-by-step examples.',
          'Handle more complex problems without losing clarity.',
          'Consolidate the full topic with mixed review and challenge work.',
        ];
  final currentIndex = (unlockedChapterLimit - 1).clamp(0, titles.length - 1);
  final tones = <Color>[
    accentColor,
    AppColors.secondary,
    const Color(0xFFFF9F43),
    AppColors.tertiary,
  ];

  return List<ProgressModuleStep>.generate(titles.length, (index) {
    return ProgressModuleStep(
      id: 'chapter_${index + 1}',
      chapterNumber: index + 1,
      icon: _fallbackIcons(course.courseType)[index],
      eyebrow: 'CHAPTER ${(index + 1).toString().padLeft(2, '0')}',
      title: titles[index],
      detail: details[index],
      progress: index < currentIndex
          ? 1.0
          : index == currentIndex
          ? (0.40 + levelFactor * 0.30).clamp(0.40, 0.90)
          : 0.0,
      durationLabel: '${50 + index * 15} min',
      lessonCountLabel:
          '${course.courseType == ProgressCourseType.voice ? 4 + index : 3 + index} lessons',
      toneColor: tones[index % tones.length],
      isCurrent: index == currentIndex,
      isLocked: index > currentIndex,
    );
  });
}

int _totalLessons(Map<String, dynamic> roadmap, int fallbackModuleCount) {
  final chapters = _mapList(roadmap['chapters']);
  if (chapters.isEmpty) {
    return fallbackModuleCount * 4;
  }

  final total = chapters.fold<int>(0, (sum, chapter) {
    return sum + _mapList(chapter['lessons']).length;
  });
  return total > 0 ? total : fallbackModuleCount * 4;
}

int _estimateMasteredLessons(int totalLessons, double levelFactor) {
  final ratio = (0.34 + levelFactor * 0.42).clamp(0.24, 0.90);
  return (totalLessons * ratio).round().clamp(1, totalLessons);
}

int _estimatedHours(
  Map<String, dynamic> roadmap,
  int totalLessons,
  double levelFactor,
) {
  final raw = roadmap['estimatedHours'] ?? roadmap['estimated_hours'];
  if (raw is int && raw > 0) return raw;
  if (raw is num && raw > 0) return raw.round();
  return ((totalLessons * 0.55) + (levelFactor * 2.4)).round().clamp(2, 48);
}

Map<String, dynamic> _extractBaseRoadmapPayload(Map<String, dynamic>? raw) {
  if (raw == null) return <String, dynamic>{};

  final roadmap = _unwrapNestedMap(raw, 'roadmap');
  if (roadmap != null) {
    final nestedData = _unwrapNestedMap(roadmap, 'data');
    return nestedData ?? roadmap;
  }

  final data = _unwrapNestedMap(raw, 'data');
  return data ?? raw;
}

Map<String, dynamic>? _unwrapNestedMap(Map<String, dynamic> raw, String key) {
  final nested = raw[key];
  if (nested is Map<String, dynamic>) return nested;
  if (nested is Map) return Map<String, dynamic>.from(nested);
  return null;
}

List<Map<String, dynamic>> _mapList(Object? raw) {
  if (raw is! List<dynamic>) return const [];
  return raw
      .whereType<Map>()
      .map((item) => Map<String, dynamic>.from(item))
      .toList();
}

double _levelFactor(String rawLevel) {
  switch (rawLevel.trim().toLowerCase()) {
    case 'beginner':
      return 0.24;
    case 'advanced':
      return 0.82;
    default:
      return 0.56;
  }
}

Color _accentForCourse(ProgressCourseType courseType) {
  return courseType == ProgressCourseType.voice
      ? AppColors.primary
      : AppColors.secondary;
}

String _durationLabel(
  Object? durationRaw, {
  required int lessonCount,
  required double levelFactor,
}) {
  if (durationRaw is int && durationRaw > 0) {
    return '$durationRaw min';
  }
  if (durationRaw is num && durationRaw > 0) {
    return '${durationRaw.round()} min';
  }
  final estimated = (lessonCount * (12 + (levelFactor * 4))).round();
  return '$estimated min';
}

String _stringValue(Object? raw, {required String fallback}) {
  final value = raw?.toString().trim() ?? '';
  return value.isEmpty ? fallback : value;
}

int _chapterNumberFor(Map<String, dynamic> chapter, int index) {
  final raw = chapter['chapter_number'] ?? chapter['chapterNumber'];
  if (raw is int && raw > 0) {
    return raw;
  }
  if (raw is num && raw > 0) {
    return raw.toInt();
  }
  return index + 1;
}

String _chapterIdFor(Map<String, dynamic> chapter, int index) {
  final rawId = chapter['id']?.toString().trim();
  if (rawId != null && rawId.isNotEmpty) {
    return rawId;
  }
  return 'chapter_${_chapterNumberFor(chapter, index)}';
}

String _defaultIconForCourse(ProgressCourseType courseType) {
  return courseType == ProgressCourseType.voice ? '🎙️' : '📘';
}

List<String> _fallbackIcons(ProgressCourseType courseType) {
  return courseType == ProgressCourseType.voice
      ? ['🎧', '🗣️', '💬', '🚀']
      : ['🧠', '🧩', '📐', '🏁'];
}
