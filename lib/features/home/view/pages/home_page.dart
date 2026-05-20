import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/profile/local_profile_service.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/auth/service/auth_service.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/home/data/home_lesson_filter.dart';
import 'package:modern_learner_production/features/home/view/pages/all_lessons_page.dart';
import 'package:modern_learner_production/features/home/view/section/home_continue_learning_header_section.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_course_list.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_delete_dialog.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_header.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_lesson_quick_access.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_profile_sheet.dart';
import 'package:modern_learner_production/features/home/view/widgets/home_section_label.dart';
import 'package:modern_learner_production/features/home/view/widgets/lesson_card.dart';
import 'package:modern_learner_production/features/home/view/widgets/progress_overview_card.dart';
import 'package:modern_learner_production/features/home/view/widgets/streak_details_dialog.dart';
import 'package:modern_learner_production/features/new_lesson/model/lesson_actions_model.dart';
import 'package:modern_learner_production/features/new_lesson/service/lesson_actions.dart';
import 'package:modern_learner_production/features/profile/data/profile_identity.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _scrollCtrl = ScrollController();
  final _profileService = getIt<LocalProfileService>();
  late final UserCoursesService _userCoursesService;

  List<AddLesson> _fetchedLessons = [];
  bool _lessonsLoading = true;

  @override
  void initState() {
    super.initState();
    _userCoursesService = getIt<UserCoursesService>();
    _fetchLessons();
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

  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => const StreakDetailsDialog(streak: 14),
    );
  }

  void _navigateToProgress() {
    final navState = getIt<ProgressNavigationState>();
    navState.navigateToChapter('current');
    context.go(Routes.progress);
  }

  void _showProfileQuickView() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final displayName = _profileService.currentIdentity.displayName;

        return HomeProfileSheet(
          displayName: displayName,
          onProfileTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push(Routes.viewProfile);
          },
          onAchievementsTap: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.push(Routes.achievements);
          },
          onSettingsTap: () {
            Navigator.pop(context);
          },
        );
      },
    );
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
    if (mounted) {
      final messengerState = ScaffoldMessenger.of(context);
      messengerState.showSnackBar(
        SnackBar(
          content: Text('Deleted "${course.topic}"'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: AppColors.surfaceContainerHigh,
          duration: const Duration(seconds: 2),
          action: SnackBarAction(
            label: 'Undo',
            textColor: AppColors.primary,
            onPressed: () async {
              await _userCoursesService.upsertCourse(course);
              await ExploreCoursesService.instance.loadCourses();
            },
          ),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        if (messengerState.mounted) {
          messengerState.hideCurrentSnackBar();
        }
      });
    }
  }

  Future<void> _deleteAllCourses() async {
    final deletedCourses = await ExploreCoursesService.instance
        .removeAllCourses();
    if (deletedCourses.isEmpty || !mounted) return;

    final messengerState = ScaffoldMessenger.of(context);
    messengerState.showSnackBar(
      SnackBar(
        content: Text(
          'Deleted ${deletedCourses.length} course${deletedCourses.length == 1 ? '' : 's'}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surfaceContainerHigh,
        duration: const Duration(seconds: 3),
        action: SnackBarAction(
          label: 'Undo',
          textColor: AppColors.primary,
          onPressed: () async {
            for (final course in deletedCourses) {
              await _userCoursesService.upsertCourse(course);
            }
            await ExploreCoursesService.instance.loadCourses();
          },
        ),
      ),
    );
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

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ProfileIdentity>(
      valueListenable: _profileService.identityListenable,
      builder: (context, identity, _) {
        return Container(
          color: AppColors.surface,
          child: SafeArea(
            child: CustomScrollView(
              controller: _scrollCtrl,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: HomeHeader(
                    displayName: identity.displayName,
                    onAvatarTap: _showProfileQuickView,
                    onStreakTap: _showStreakDetails,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverToBoxAdapter(
                    child: ProgressOverviewCard(
                      level: 8,
                      xp: 2400,
                      xpToNext: 3000,
                      progress: 0.73,
                      onTap: _navigateToProgress,
                    ),
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
                              const emojis = [
                                '📚',
                                '🎯',
                                '✏️',
                                '🧠',
                                '🚀',
                                '💡',
                              ];
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
                                progress:
                                    lesson.status == LessonStatus.completed
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
        );
      },
    );
  }
}
