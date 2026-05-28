import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/models/user_progress.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievement/service/achievement_service.dart';
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
  bool _loading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadFromSupabase();
    CourseXpService.instance.totalExerciseXp.addListener(_onXpChanged);
    CourseXpService.instance.version.addListener(_onVersionChanged);
  }

  @override
  void dispose() {
    CourseXpService.instance.totalExerciseXp.removeListener(_onXpChanged);
    CourseXpService.instance.version.removeListener(_onVersionChanged);
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

  // ── Local evaluation (instant, no network) ───────────────────────────────────

  void _evaluateLocally() {
    if (!mounted) return;

    final courseData = Map.fromEntries(
      CourseXpService.instance.courseNotifiers.entries.map(
        (e) => MapEntry(e.key, e.value.value),
      ),
    );
    final userProgress = _buildUserProgress(courseData);

    final evaluated = AchievementCatalogue.all.map((a) {
      final existing = _achievements.firstWhere(
        (e) => e.id == a.id,
        orElse: () => a,
      );
      final courses = _unlockedBy(a, userProgress, courseData);
      final nowUnlocked = courses.isNotEmpty;
      return a.copyWith(
        unlockedByCourses:
            nowUnlocked ? courses : existing.unlockedByCourses,
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
      streak: 0,
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
      await CourseXpService.instance.syncToSupabase();

      final results = await Future.wait([
        _service.getUnlockedProgress(),
        _service.getCourseXp(),
      ]);

      final progress = results[0] as List<UserAchievementProgressModel>;
      final courseXp = results[1] as List<ProfileCourseXpModel>;

      final progressByKey = <String, List<UserAchievementProgressModel>>{};
      for (final p in progress) {
        progressByKey.putIfAbsent(p.achievementKey, () => []).add(p);
      }

      final achievements = AchievementCatalogue.all.map((a) {
        final rows = progressByKey[a.id] ?? [];
        final unlockedRows = rows.where((r) => r.isUnlocked).toList();
        final unlockedByCourses =
            unlockedRows.map((r) => r.courseKey).toList();
        final unlockedAt = unlockedRows.isNotEmpty
            ? unlockedRows
                  .map((r) => r.unlockedAt!)
                  .reduce((x, y) => x.isBefore(y) ? x : y)
            : null;
        return a.copyWith(
          unlockedAt: unlockedAt,
          unlockedByCourses: unlockedByCourses,
        );
      }).toList();

      if (!mounted) return;
      setState(() {
        _achievements = achievements;
        _courseXp = courseXp;
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
    final progress =
        _achievements.isEmpty ? 0.0 : unlocked / _achievements.length;

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
}
