import 'package:flutter/material.dart';
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

typedef ProfileAchievementData = ({
  List<Achievement> achievements,
  List<ProfileCourseXpModel> courseXp,
});

class ProfileAchievementSectionState extends State<ProfileAchievementSection> {
  final _service = AchievementService();
  Future<ProfileAchievementData>? _future;
  int _lastSyncedVersion = -1;

  @override
  void initState() {
    super.initState();
    _future = _load();
    CourseXpService.instance.version.addListener(_onVersionChanged);
  }

  @override
  void dispose() {
    CourseXpService.instance.version.removeListener(_onVersionChanged);
    super.dispose();
  }

  void _onVersionChanged() {
    final v = CourseXpService.instance.version.value;
    if (v == _lastSyncedVersion) return;
    _lastSyncedVersion = v;
    setState(() => _future = _syncThenLoad());
  }

  Future<ProfileAchievementData> _syncThenLoad() async {
    await CourseXpService.instance.syncToSupabase();
    return _load();
  }

  Future<ProfileAchievementData> _load() async {
    final results = await Future.wait([
      _service.getDefinitions(),
      _service.getUnlockedProgress(),
      _service.getCourseXp(),
    ]);

    final definitions = results[0] as List<AchievementDefinitionModel>;
    final progress = results[1] as List<UserAchievementProgressModel>;
    final courseXp = results[2] as List<ProfileCourseXpModel>;

    final progressByKey = <String, List<UserAchievementProgressModel>>{};
    for (final p in progress) {
      progressByKey.putIfAbsent(p.achievementKey, () => []).add(p);
    }

    final achievements = definitions.map((def) {
      final rows = progressByKey[def.key] ?? [];
      final unlockedRows = rows.where((r) => r.isUnlocked).toList();
      final unlockedByCourses = unlockedRows.map((r) => r.courseKey).toList();
      final unlockedAt = unlockedRows.isNotEmpty
          ? unlockedRows
                .map((r) => r.unlockedAt!)
                .reduce((a, b) => a.isBefore(b) ? a : b)
          : null;
      return def.toAchievement(
        unlockedAt: unlockedAt,
        unlockedByCourses: unlockedByCourses,
      );
    }).toList();

    return (achievements: achievements, courseXp: courseXp);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ProfileAchievementData>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const ProfileAchievementSkeleton();
        }
        if (snapshot.hasError) {
          return const ProfileAchievementErrorPlaceholder();
        }

        final data = snapshot.data!;
        final achievements = data.achievements;
        final unlocked = achievements.where((a) => a.isUnlocked).length;
        final progress = achievements.isEmpty
            ? 0.0
            : unlocked / achievements.length;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ProfileSectionLabel(text: 'ACHIEVEMENTS'),
            const SizedBox(height: 14),
            ProfileAchievementProgressBar(
              unlocked: unlocked,
              total: achievements.length,
              progress: progress,
            ),
            const SizedBox(height: 16),
            ProfileAchievementBadgeRow(achievements: achievements),
            const SizedBox(height: 20),
            const ProfileSectionLabel(text: 'COURSE XP'),
            const SizedBox(height: 14),
            ProfileCourseXpList(courseXp: data.courseXp),
          ],
        );
      },
    );
  }
}
