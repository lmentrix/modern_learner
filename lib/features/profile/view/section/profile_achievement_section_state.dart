import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/models/user_progress.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievement/service/achievement_service.dart';
import 'package:modern_learner_production/features/course/model/course__service_model.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/profile/service/streak_service.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_achievement_section.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_badge_row.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_error_placeholder.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_achievement_progress_bar.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_course_xp_list.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_section_label.dart';
import 'package:modern_learner_production/features/profile/view/widgets/profile_skeletons.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class ProfileAchievementSectionState extends State<ProfileAchievementSection> {
  final _service = AchievementService();

  List<Achievement> _achievements = [];
  List<ProfileCourseXpModel> _courseXp = [];
  Set<String> _activeCourseKeys = const {};
  Set<String> _activeCourseKeyPrefixes = const {};
  bool _activeCoursesLoaded = false;
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
    CourseXpService.instance.totalExerciseXp.addListener(_onXpChanged);
    CourseXpService.instance.version.addListener(_onVersionChanged);
    StreakService.instance.currentStreak.addListener(_onStreakChanged);
  }

  @override
  void dispose() {
    CourseXpService.instance.totalExerciseXp.removeListener(_onXpChanged);
    CourseXpService.instance.version.removeListener(_onVersionChanged);
    StreakService.instance.currentStreak.removeListener(_onStreakChanged);
    super.dispose();
  }

  // ── Listeners ────────────────────────────────────────────────────────────────

  void _onXpChanged() {
    // addXp() already triggered _syncToSupabase() before this fires —
    // so the DB write is already in flight. Just update the UI locally.
    _evaluateLocally();
  }

  void _onVersionChanged() {
    _loadFromSupabase();
  }

  void _onStreakChanged() {
    _evaluateLocally();
  }

  // ── Local evaluation (instant, no network) ───────────────────────────────────

  void _evaluateLocally() {
    if (!mounted) return;

    final courseData = Map.fromEntries(
      CourseXpService.instance.courseNotifiers.entries.map(
        (e) => MapEntry(e.key, e.value.value),
      ),
    );
    final activeCourseData = _filterActiveCourseData(courseData);
    final userProgress = _buildUserProgress(activeCourseData);

    final evaluated = AchievementCatalogue.all.map((a) {
      final existing = _achievements.firstWhere(
        (e) => e.id == a.id,
        orElse: () => a,
      );
      final courses = _unlockedBy(a, userProgress, activeCourseData);
      final nowUnlocked = courses.isNotEmpty;
      final existingCourses = _visibleUnlockedByCourses(
        existing.unlockedByCourses,
      );
      return a.copyWith(
        unlockedByCourses: nowUnlocked ? courses : existingCourses,
        unlockedAt: nowUnlocked && existing.unlockedAt == null
            ? DateTime.now()
            : existing.unlockedAt,
      );
    }).toList();

    setState(() => _achievements = evaluated);
  }

  UserProgress _buildUserProgress(Map<String, CourseXpData> courseData) {
    final totalXp = CourseXpService.instance.totalExerciseXp.value;
    final totalExercises = courseData.values.fold(
      0,
      (sum, d) => sum + d.exercisesCompleted,
    );
    return UserProgress(
      totalXp: totalXp,
      level: 1,
      gems: 0,
      streak: StreakService.instance.currentStreak.value,
      completedLessons: {
        for (var i = 0; i < totalExercises; i++) 'ex_$i': DateTime.now(),
      },
      lessonProgress: const {},
      completedChapters: const {},
    );
  }

  List<String> _unlockedBy(
    Achievement a,
    UserProgress progress,
    Map<String, CourseXpData> courseData,
  ) {
    switch (a.type) {
      case AchievementType.xp:
        return courseData.entries
            .where((e) => e.value.exerciseXp >= a.requirement)
            .map((e) => e.key)
            .toList();
      case AchievementType.chapter:
        return courseData.entries
            .where((e) => e.value.chaptersUnlocked >= a.requirement)
            .map((e) => e.key)
            .toList();
      case AchievementType.streak:
        return progress.streak >= a.requirement ? ['global'] : [];
      case AchievementType.level:
        return progress.level >= a.requirement ? ['global'] : [];
      case AchievementType.gems:
        return progress.gems >= a.requirement ? ['global'] : [];
      case AchievementType.lesson:
        return progress.completedLessons.length >= a.requirement
            ? ['global']
            : [];
    }
  }

  // ── Supabase load (ground truth, runs on init + user switch) ─────────────────

  Future<void> _loadFromSupabase() async {
    if (!mounted) return;
    setState(() {
      _loading = _achievements.isEmpty;
      _hasError = false;
    });

    try {
      await Future.wait([
        CourseXpService.instance.syncToSupabase(),
        StreakService.instance.fetchAndUpdate(),
      ]);

      final results = await Future.wait([
        _service.getUnlockedProgress(),
        _service.getCourseXp(),
        CourseService.instance.fetchCourses(),
      ]);

      final progress = results[0] as List<UserAchievementProgressModel>;
      final courseXp = results[1] as List<ProfileCourseXpModel>;
      final activeCourses = results[2] as List<UserCourseModel>;
      final activeCourseKeys = courseXp
          .map((row) => row.courseKey)
          .where(
            (courseKey) => _matchesAnyActiveCourse(courseKey, activeCourses),
          )
          .toSet();
      final activeCourseKeyPrefixes = activeCourses
          .map(_courseKeyPrefixForActiveCourse)
          .toSet();

      final progressByKey = <String, List<UserAchievementProgressModel>>{};
      for (final p in progress) {
        progressByKey.putIfAbsent(p.achievementKey, () => []).add(p);
      }

      final achievements = AchievementCatalogue.all.map((a) {
        final rows = progressByKey[a.id] ?? [];
        final unlockedRows = rows.where((r) => r.isUnlocked).toList();
        final unlockedByCourses = _visibleUnlockedByCourses(
          unlockedRows.map((r) => r.courseKey),
          activeCourseKeys: activeCourseKeys,
        );
        final unlockedDates = unlockedRows
            .map((r) => r.unlockedAt)
            .whereType<DateTime>();
        final unlockedAt = unlockedDates.isNotEmpty
            ? unlockedDates.reduce((x, y) => x.isBefore(y) ? x : y)
            : null;
        return a.copyWith(
          unlockedAt: unlockedAt,
          unlockedByCourses: unlockedByCourses,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _achievements = achievements;
        _courseXp = courseXp
            .where((row) => activeCourseKeys.contains(row.courseKey))
            .toList(growable: false);
        _activeCourseKeys = activeCourseKeys;
        _activeCourseKeyPrefixes = activeCourseKeyPrefixes;
        _activeCoursesLoaded = true;
        _loading = false;
      });

      // Run local eval on top so in-session XP is reflected immediately.
      _evaluateLocally();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _hasError = _achievements.isEmpty;
      });
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_loading) return const ProfileAchievementSkeleton();
    if (_hasError) return const ProfileAchievementErrorPlaceholder();

    final unlocked = _achievements.where((a) => a.isUnlocked).length;
    final progress = _achievements.isEmpty
        ? 0.0
        : unlocked / _achievements.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
        const SizedBox(height: 14),
        ProfileAchievementProgressBar(
          unlocked: unlocked,
          total: _achievements.length,
          progress: progress,
        ),
        const SizedBox(height: 16),
        ProfileAchievementBadgeRow(achievements: _achievements),
        const SizedBox(height: 20),
        const ProfileSectionLabel(text: 'COURSE XP'),
        const SizedBox(height: 14),
        ProfileCourseXpList(courseXp: _courseXp),
      ],
    );
  }

  List<String> _visibleUnlockedByCourses(
    Iterable<String> courseKeys, {
    Set<String>? activeCourseKeys,
  }) {
    final visibleCourseKeys = activeCourseKeys ?? _activeCourseKeys;
    return courseKeys
        .where((courseKey) {
          return courseKey == 'global' ||
              visibleCourseKeys.contains(courseKey) ||
              _matchesActiveCoursePrefix(courseKey);
        })
        .toSet()
        .toList(growable: false);
  }

  Map<String, CourseXpData> _filterActiveCourseData(
    Map<String, CourseXpData> courseData,
  ) {
    if (!_activeCoursesLoaded) return courseData;
    return Map.fromEntries(
      courseData.entries.where((entry) {
        return _activeCourseKeys.contains(entry.key) ||
            _matchesActiveCoursePrefix(entry.key);
      }),
    );
  }

  bool _matchesAnyActiveCourse(
    String courseKey,
    List<UserCourseModel> activeCourses,
  ) {
    return activeCourses.any((course) {
      return courseKey.startsWith(
        '${_courseKeyPrefixForActiveCourse(course)}::',
      );
    });
  }

  bool _matchesActiveCoursePrefix(String courseKey) {
    return _activeCourseKeyPrefixes.any(
      (prefix) => courseKey.startsWith('$prefix::'),
    );
  }

  String _courseKeyPrefixForActiveCourse(UserCourseModel course) {
    return [
      course.title,
      course.topic,
      course.level,
      course.nativeLanguage,
    ].join('::');
  }
}
