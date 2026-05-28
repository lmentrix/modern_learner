import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/achievement/data/achievemenet_data.dart';
import 'package:modern_learner_production/features/achievement/model/achievement_model.dart';
import 'package:modern_learner_production/features/achievement/service/achievement_service.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_actions_section.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_hero_section.dart';
import 'package:modern_learner_production/features/home/view/section/view_profile_stats_section.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';
import 'package:modern_learner_production/features/profile/view/section/profile_achievement_section.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';

class ViewProfilePage extends StatelessWidget {
  const ViewProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final profileService = LocalProfileService.instance;

    return ValueListenableBuilder<ProfileIdentity>(
      valueListenable: profileService.identityListenable,
      builder: (context, identity, _) {
        return Material(
          color: AppColors.surface,
          child: SafeArea(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ViewProfileHeroSection(
                    initial: identity.initial,
                    displayName: identity.displayName,
                    email: identity.email,
                    isVip: false,
                    onBackTap: () => Navigator.pop(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(child: ViewProfileStatsSection()),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                const SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: _PersistentProfileAchievementSection(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 28)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: ViewProfileActionsSection(
                      onManageProfileTap: () {
                        Navigator.pop(context);
                        context.go(Routes.profile);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PersistentProfileAchievementSection extends StatefulWidget {
  const _PersistentProfileAchievementSection();

  @override
  State<_PersistentProfileAchievementSection> createState() =>
      _PersistentProfileAchievementSectionState();
}

class _PersistentProfileAchievementSectionState
    extends State<_PersistentProfileAchievementSection> {
  final AchievementService _achievementService = AchievementService();
  final Map<String, _CourseXpListener> _courseListeners = {};

  bool _syncScheduled = false;
  bool _syncInFlight = false;
  String _lastSyncedSignature = '';

  @override
  void initState() {
    super.initState();
    CourseXpService.instance.totalExerciseXp.addListener(_handleCourseData);
    CourseXpService.instance.version.addListener(_handleCourseData);
    _attachCourseListeners();
    _scheduleSync();
  }

  @override
  void dispose() {
    CourseXpService.instance.totalExerciseXp.removeListener(_handleCourseData);
    CourseXpService.instance.version.removeListener(_handleCourseData);
    for (final entry in _courseListeners.entries) {
      entry.value.notifier.removeListener(entry.value.listener);
    }
    super.dispose();
  }

  void _handleCourseData() {
    _attachCourseListeners();
    _scheduleSync();
  }

  void _attachCourseListeners() {
    final notifiers = CourseXpService.instance.courseNotifiers;
    final removedKeys = _courseListeners.keys
        .where((key) => !notifiers.containsKey(key))
        .toList();

    for (final key in removedKeys) {
      final removed = _courseListeners.remove(key);
      removed?.notifier.removeListener(removed.listener);
    }

    for (final entry in notifiers.entries) {
      if (_courseListeners.containsKey(entry.key)) continue;
      void listener() => _handleCourseData();
      _courseListeners[entry.key] = _CourseXpListener(
        notifier: entry.value,
        listener: listener,
      );
      entry.value.addListener(listener);
    }
  }

  void _scheduleSync() {
    if (_syncScheduled || _syncInFlight) return;
    _syncScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      _syncScheduled = false;
      await _syncAchievements();
    });
  }

  Future<void> _syncAchievements() async {
    final userId = _achievementService.currentUserId;
    if (userId == null) return;

    final courseXp = _courseXpSnapshot(userId);
    final signature = _signature(courseXp);
    if (signature == _lastSyncedSignature) return;

    _syncInFlight = true;
    try {
      final definitions = [
        for (int i = 0; i < AchievementCatalogue.all.length; i++)
          AchievementDefinitionModel.fromAchievement(
            achievement: AchievementCatalogue.all[i],
            sortOrder: i + 1,
          ),
      ];

      await _achievementService.syncProfileSnapshot(
        userId: userId,
        definitions: definitions,
        courseXp: courseXp,
      );

      _lastSyncedSignature = signature;
    } catch (error) {
      debugPrint('Failed to sync profile achievements: $error');
    } finally {
      _syncInFlight = false;
      if (_signature(_courseXpSnapshot(userId)) != _lastSyncedSignature) {
        _scheduleSync();
      }
    }
  }

  List<ProfileCourseXpModel> _courseXpSnapshot(String userId) {
    return CourseXpService.instance.courseNotifiers.entries.map((entry) {
      final data = entry.value.value;
      return ProfileCourseXpModel(
        userId: userId,
        courseKey: entry.key,
        exerciseXp: data.exerciseXp,
        exercisesCompleted: data.exercisesCompleted,
        chaptersUnlocked: data.chaptersUnlocked,
      );
    }).toList();
  }

  String _signature(List<ProfileCourseXpModel> courseXp) {
    final sorted = [...courseXp]
      ..sort((a, b) => a.courseKey.compareTo(b.courseKey));
    return sorted
        .map(
          (data) =>
              '${data.courseKey}:${data.exerciseXp}:${data.exercisesCompleted}:${data.chaptersUnlocked}',
        )
        .join('|');
  }

  @override
  Widget build(BuildContext context) {
    return const ProfileAchievementSection();
  }
}

class _CourseXpListener {
  const _CourseXpListener({required this.notifier, required this.listener});

  final ValueNotifier<CourseXpData> notifier;
  final VoidCallback listener;
}
