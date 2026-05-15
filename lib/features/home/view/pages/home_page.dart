import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/state/progress_navigation_state.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/pages/exercise_page.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/service/user_courses_service.dart';
import 'package:modern_learner_production/features/home/data/home_lesson_filter.dart';
import 'package:modern_learner_production/features/home/data/home_supabase_lesson.dart';
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
import 'package:supabase_flutter/supabase_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scrollCtrl = ScrollController();
  late final UserCoursesService _userCoursesService;

  RealtimeChannel? _lessonsChannel;
  List<HomeSupabaseLesson> _fetchedLessons = [];
  bool _isLoadingLessons = false;

  @override
  void initState() {
    super.initState();
    _userCoursesService = getIt<UserCoursesService>();
    WidgetsBinding.instance.addObserver(this);
    _subscribeToLessonChanges();
    _fetchLessons(showLoading: true);
  }

  Future<void> _fetchLessons({bool showLoading = false}) async {
    if (showLoading && mounted) {
      setState(() => _isLoadingLessons = true);
    }

    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      if (mounted) {
        setState(() {
          _fetchedLessons = [];
          _isLoadingLessons = false;
        });
      }
      return;
    }

    try {
      final response = await SupabaseService.client
          .from('lessons')
          .select(
            'id, lesson_type, content_type, difficulty, title, status, content',
          )
          .eq('user_id', userId)
          .neq('status', 'completed')
          .order('created_at', ascending: false);

      if (mounted) {
        setState(() {
          _fetchedLessons = (response as List)
              .map((e) => HomeSupabaseLesson.fromMap(e as Map<String, dynamic>))
              .toList();
          _isLoadingLessons = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLessons = false);
    }
  }

  void _subscribeToLessonChanges() {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) return;

    _lessonsChannel = SupabaseService.client
        .channel('public:lessons:user:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'lessons',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (_) => _fetchLessons(),
        )
        .subscribe();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _fetchLessons();
    }
  }

  void _showStreakDetails() {
    showDialog(
      context: context,
      builder: (context) => const StreakDetailsDialog(streak: 14),
    );
  }

  void _navigateToProgress() {
    // Set the navigation state to scroll to current chapter
    final navState = getIt<ProgressNavigationState>();
    navState.navigateToChapter('current');

    // Navigate to progress page
    context.go(Routes.progress);
  }

  void _showProfileQuickView() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final supaUser = Supabase.instance.client.auth.currentUser;
        final displayName =
            supaUser?.userMetadata?['name'] as String? ?? 'User';

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
            // Navigate to settings
          },
        );
      },
    );
  }

  void _openSupabaseLesson(HomeSupabaseLesson lesson) {
    if (lesson.lessonType == 'language') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ExercisePage(
            lessonType: LessonType.voice,
            title: lesson.title,
            sectionTitle: lesson.subtitle,
            accentColor: lesson.color,
            emoji: lesson.emoji,
          ),
        ),
      );
    } else {
      context.go(Routes.progress, extra: lesson.toCourseSelection());
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
    await _userCoursesService.deleteCourse(course);
    // The course list will automatically refresh via ExploreCoursesService
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
            },
          ),
        ),
      );
      // Auto-dismiss after 2 seconds even if action wasn't tapped
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
    WidgetsBinding.instance.removeObserver(this);
    final lessonsChannel = _lessonsChannel;
    if (lessonsChannel != null) {
      SupabaseService.client.removeChannel(lessonsChannel);
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supaUser = Supabase.instance.client.auth.currentUser;
    final displayName = supaUser?.userMetadata?['name'] as String? ?? 'User';

    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: HomeHeader(
                displayName: displayName,
                onAvatarTap: _showProfileQuickView,
                onStreakTap: _showStreakDetails,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),

            // ── Progress overview ──────────────────────────────────────────
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

            // ── Quick start label ──────────────────────────────────────────
            const SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: HomeSectionLabel(text: 'QUICK START'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Quick access to lesson pages ───────────────────────────────
            SliverToBoxAdapter(
              child: HomeLessonQuickAccess(
                onVoiceLessonTap: _openVoiceLessonPage,
                onSchoolLessonTap: _openSchoolLessonPage,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Continue learning label ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: HomeContinueLearningHeaderSection(
                  onDeleteAllTap: _showDeleteAllConfirmation,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Explore courses ────────────────────────────────────────────
            SliverToBoxAdapter(
              child: HomeCourseList(
                onCourseTap: (course) =>
                    context.go(Routes.progress, extra: course),
                onCourseLongPress: _showDeleteConfirmation,
              ),
            ),

            // ── Lesson cards ───────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: _isLoadingLessons
                  ? const SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      ),
                    )
                  : _fetchedLessons.isEmpty
                  ? SliverToBoxAdapter(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 24),
                          child: Text(
                            'No lessons yet. Start creating!',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    )
                  : SliverList.separated(
                      itemCount: _fetchedLessons.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, i) {
                        final l = _fetchedLessons[i];
                        return LessonCard(
                          emoji: l.emoji,
                          title: l.title,
                          chapter: l.subtitle,
                          duration: l.duration,
                          progress: l.progress,
                          accentColor: l.color,
                          isNew: l.status == 'draft',
                          lessonType: l.lessonType,
                          onTap: () => _openSupabaseLesson(l),
                        );
                      },
                    ),
            ),

            // Add padding for bottom navigation bar
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        ),
      ),
    );
  }
}
