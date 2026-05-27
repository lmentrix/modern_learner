import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/home/data/home_lesson_filter.dart';
import 'package:modern_learner_production/features/home/view/pages/all_lessons_page.dart';
import 'package:modern_learner_production/features/home/view/section/home_continue_learning_header_section.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_course_list.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_delete_dialog.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_header.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_lesson_quick_access.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';
import 'package:modern_learner_production/features/home/view/widgets/progress_overview_card.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
import 'package:modern_learner_production/features/new_lesson/service/lesson_actions.dart';
import 'package:modern_learner_production/features/profile/service/profile_service.dart';
import 'package:modern_learner_production/features/profile/state/learning_activity_monitor.dart';
import 'package:modern_learner_production/features/progress/bloc/xp_bloc.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();
  final ProfileService _profileService = ProfileService();
  final Map<String, XpBloc> _xpBlocByCourse = {};
  late final Future<String?> _nameFuture;

  static const List<int> _xpLevelThresholds = [
    0,
    500,
    1200,
    2200,
    3500,
    5000,
    7000,
    10000,
  ];
  static const List<String> _xpRankTitles = [
    'Starter',
    'Explorer',
    'Practitioner',
    'Achiever',
    'Expert',
    'Master',
    'Legend',
    'Grandmaster',
  ];

  List<AddLesson> _fetchedLessons = [];
  bool _lessonsLoading = true;

  @override
  void initState() {
    super.initState();
    _nameFuture = _profileService.getCurrentUserName();

    _fetchLessons();
    LearningActivityMonitor.instance.refresh();
  }

  Future<void> _fetchLessons() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) {
      if (mounted) setState(() => _lessonsLoading = false);
      return;
    }
    try {
      final lessons = await getLessonsService(userId: userId);
      if (mounted) setState(() => _fetchedLessons = lessons);
    } finally {
      if (mounted) setState(() => _lessonsLoading = false);
    }
  }

  void _showDeleteConfirmation(ProgressCourseSelection course) {
    showDialog(
      context: context,
      builder: (context) => HomeDeleteDialog(
        course: course,
        onDelete: () async {
          Navigator.pop(context);
          await _deleteCourse(course);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _showDeleteAllConfirmation() {
    final courses = ExploreCoursesService.instance.courses.value;
    if (courses.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete All Courses?',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will remove all courses from your continue learning list.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteAllCourses();
              await _deleteAllLessons();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Delete All',
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteCourse(ProgressCourseSelection course) async {
    await ExploreCoursesService.instance.removeCourse(course);
  }

  Future<void> _deleteAllCourses() async {
    await ExploreCoursesService.instance.removeAllCourses();
  }

  Future<void> _deleteAllLessons() async {
    final userId = AuthService.instance.currentUser?.id;
    if (userId == null) return;
    try {
      await deleteAllLessonsService(userId: userId);
      if (mounted) setState(() => _fetchedLessons = []);
    } catch (e) {
      debugPrint('[HomePage] deleteAllLessons failed: $e');
    }
  }

  void _openVoiceLessonPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllLessonsPage(filter: LessonFilter.voice),
      ),
    );
  }

  void _openSchoolLessonPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AllLessonsPage(filter: LessonFilter.school),
      ),
    );
  }

  void _onAvatarTap() {}

  @override
  void dispose() {
    for (final bloc in _xpBlocByCourse.values) {
      bloc.close();
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  XpBloc _xpBlocFor(ProgressCourseSelection course) {
    final key = progressCourseXpKey(course);
    return _xpBlocByCourse.putIfAbsent(key, () => getIt<XpBloc>(param1: key));
  }

  _HomeXpLevelData _levelData(int xp) {
    int level = 1;
    for (int i = 1; i < _xpLevelThresholds.length; i++) {
      if (xp >= _xpLevelThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }

    level = level.clamp(1, _xpRankTitles.length);
    final floor = _xpLevelThresholds[level - 1];
    final ceil = level < _xpLevelThresholds.length
        ? _xpLevelThresholds[level]
        : _xpLevelThresholds.last + 5000;
    final xpInLevel = xp - floor;
    final xpNeeded = ceil - floor;

    return _HomeXpLevelData(
      level: level,
      rankTitle: _xpRankTitles[level - 1],
      xpInLevel: xpInLevel,
      xpNeeded: xpNeeded,
      progress: (xpInLevel / xpNeeded).clamp(0.0, 1.0),
    );
  }

  Widget _buildProgressOverviewCard(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, child) {
        if (courses.isEmpty) {
          const levelData = _HomeXpLevelData(
            level: 1,
            rankTitle: 'Starter',
            xpInLevel: 0,
            xpNeeded: 500,
            progress: 0,
          );
          return ProgressOverviewCard(
            level: levelData.level,
            rankTitle: levelData.rankTitle,
            xp: levelData.xpInLevel,
            xpToNext: levelData.xpNeeded,
            progress: levelData.progress,
            onTap: () {},
          );
        }

        final selectedCourse = courses.first;
        return BlocProvider.value(
          value: _xpBlocFor(selectedCourse),
          child: BlocBuilder<XpBloc, XpState>(
            builder: (context, xpState) {
              final levelData = _levelData(xpState.totalXp);
              return ProgressOverviewCard(
                level: levelData.level,
                rankTitle: levelData.rankTitle,
                xp: levelData.xpInLevel,
                xpToNext: levelData.xpNeeded,
                progress: levelData.progress,
                onTap: () => context.go(Routes.progress, extra: selectedCourse),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.surface,
        child: SafeArea(
          child: CustomScrollView(
            controller: _scrollCtrl,
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: FutureBuilder<String?>(
                    future: _nameFuture,
                    builder: (context, snapshot) {
                      final displayName = snapshot.data?.trim();

                      return HomeHeader(
                        displayName: displayName == null || displayName.isEmpty
                            ? 'Learner'
                            : displayName,
                        onAvatarTap: _onAvatarTap,
                        onStreakTap: () {},
                      );
                    },
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _buildProgressOverviewCard(context),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: HomeSectionLabel(text: 'QUICK START'),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: HomeLessonQuickAccess(
                  onVoiceLessonTap: _openVoiceLessonPage,
                  onSchoolLessonTap: _openSchoolLessonPage,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 32)),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: HomeContinueLearningHeaderSection(
                    onDeleteAllTap: _showDeleteAllConfirmation,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              SliverToBoxAdapter(
                child: HomeCourseList(
                  onCourseTap: (course) =>
                      context.go(Routes.progress, extra: course),
                  onCourseLongPress: _showDeleteConfirmation,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: _lessonsLoading
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : _fetchedLessons.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Center(
                            child: Text(
                              'No lessons yet. Start creating!',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _fetchedLessons.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, i) {
                            final lesson = _fetchedLessons[i];
                            const accentColors = [
                              Color(0xFFB1A0FF),
                              Color(0xFF929BFA),
                              Color(0xFF7E51FF),
                              Color(0xFFB1FFCE),
                            ];
                            const emojis = ['📚', '🎯', '✏️', '🧠', '🚀', '💡'];
                            final accent =
                                accentColors[i % accentColors.length];
                            final emoji = emojis[i % emojis.length];
                            return LessonCard(
                              emoji: emoji,
                              title: lesson.title.isEmpty
                                  ? 'Untitled Lesson'
                                  : lesson.title,
                              chapter:
                                  lesson.lessonType.name[0].toUpperCase() +
                                  lesson.lessonType.name.substring(1),
                              duration: lesson.status.name,
                              progress: lesson.status == LessonStatus.completed
                                  ? 1.0
                                  : lesson.status == LessonStatus.active
                                  ? 0.5
                                  : 0.0,
                              accentColor: accent,
                              isNew: lesson.status == LessonStatus.draft,
                              lessonType: lesson.lessonType.name,
                            );
                          },
                        ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
          ),
        ),
      ),
    );
  }
}

class _HomeXpLevelData {
  const _HomeXpLevelData({
    required this.level,
    required this.rankTitle,
    required this.xpInLevel,
    required this.xpNeeded,
    required this.progress,
  });

  final int level;
  final String rankTitle;
  final int xpInLevel;
  final int xpNeeded;
  final double progress;
}
