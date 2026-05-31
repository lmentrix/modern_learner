import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/course/service/course_service.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/service/course_xp_service.dart';
import 'package:modern_learner_production/features/home/data/home_lesson_filter.dart';
import 'package:modern_learner_production/features/home/view/pages/all_lessons_page.dart';
import 'package:modern_learner_production/features/home/view/section/home_continue_learning_header_section.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_course_list.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_delete_dialog.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_header.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_lesson_quick_access.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';
import 'package:modern_learner_production/features/home/view/widgets/progress_overview_card.dart';
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
  late final Future<({String name, bool isVip})> _profileFuture =
      _profileService.getCurrentProfile().then((p) => (
            name: p?.name.trim().isNotEmpty == true ? p!.name.trim() : 'Learner',
            isVip: p?.role == 'vip',
          ));

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

  @override
  void initState() {
    super.initState();
    LearningActivityMonitor.instance.refresh();
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
    final courses = ExploreCoursesService.instance.courses.value;
    for (final c in courses) {
      CourseXpService.instance.removeCourse(progressCourseXpKey(c));
    }
    ExploreCoursesService.instance.courses.value = const [];
    await CourseService.instance.deleteAllCourses();
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
    return _xpBlocByCourse.putIfAbsent(key, () => XpBloc(courseKey: key));
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

  static const int _totalChapters = 20;

  double _averageChapterProgress(List<ProgressCourseSelection> courses) {
    if (courses.isEmpty) return 0.0;
    var total = 0.0;
    for (final course in courses) {
      final key = progressCourseXpKey(course);
      final xpData = CourseXpService.instance.dataFor(key);
      final completed = (xpData.chaptersUnlocked - 1).clamp(0, _totalChapters);
      final partialFraction =
          xpData.subcontentProgressFor(xpData.chaptersUnlocked) / _totalChapters;
      total += (completed / _totalChapters) + partialFraction;
    }
    return (total / courses.length).clamp(0.0, 1.0);
  }

  Widget _buildProgressOverviewCard(BuildContext context) {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, child) {
        if (courses.isEmpty) {
          return const ProgressOverviewCard(
            level: 1,
            rankTitle: 'Starter',
            xp: 0,
            xpToNext: 500,
            progress: 0,
          );
        }

        final selectedCourse = courses.first;
        return BlocProvider.value(
          value: _xpBlocFor(selectedCourse),
          child: ValueListenableBuilder<int>(
            valueListenable: CourseXpService.instance.totalExerciseXp,
            builder: (context, _, __) {
              return BlocBuilder<XpBloc, XpState>(
                builder: (context, xpState) {
                  final chapterXp = (xpState.chaptersUnlocked - 1) * 200;
                  final levelData = _levelData(chapterXp + xpState.totalXp);
                  final avgProgress = _averageChapterProgress(courses);
                  return ProgressOverviewCard(
                    level: levelData.level,
                    rankTitle: levelData.rankTitle,
                    xp: levelData.xpInLevel,
                    xpToNext: levelData.xpNeeded,
                    progress: avgProgress,
                    onTap: () =>
                        context.go(Routes.progress, extra: selectedCourse),
                  );
                },
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
                  child: FutureBuilder<({String name, bool isVip})>(
                    future: _profileFuture,
                    builder: (context, snapshot) {
                      final name = snapshot.data?.name ?? 'Learner';
                      final isVip = snapshot.data?.isVip ?? false;

                      return HomeHeader(
                        displayName: name,
                        isVip: isVip,
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
