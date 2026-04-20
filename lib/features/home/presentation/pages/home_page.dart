  import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/supabase/supabase_service.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/home/service/lesson_refresh_notifier.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/pages/lesson_detail_page.dart'
    as lesson_detail;
import 'package:modern_learner_production/features/lesson_detail/presentation/pages/voice_lesson_page.dart';
import 'package:modern_learner_production/features/home/presentation/pages/all_lessons_page.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/lesson_card.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/progress_overview_card.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/streak_badge.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/streak_details_dialog.dart';
import 'package:modern_learner_production/features/home/presentation/widgets/voice_lesson_card.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/service/progress_navigation_state.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final _scrollCtrl = ScrollController();

  LessonRefreshNotifier? _lessonRefreshNotifier;
  RealtimeChannel? _lessonsChannel;
  List<_SupabaseLesson> _fetchedLessons = [];
  bool _isLoadingLessons = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (getIt.isRegistered<LessonRefreshNotifier>()) {
      _lessonRefreshNotifier = getIt<LessonRefreshNotifier>()
        ..addListener(_handleLessonsChanged);
    }
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
              .map((e) => _SupabaseLesson.fromMap(e as Map<String, dynamic>))
              .toList();
          _isLoadingLessons = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingLessons = false);
    }
  }

  void _handleLessonsChanged() {
    _fetchLessons();
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
        final initial = displayName.isNotEmpty
            ? displayName[0].toUpperCase()
            : 'U';

        return Container(
          decoration: const BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 12,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(context).padding.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              // Profile header
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        Text(
                          'Advanced Learner · LVL 8',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Stats row
              const Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      emoji: '🔥',
                      label: 'Streak',
                      value: '14',
                      subtitle: 'days',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      emoji: '⭐',
                      label: 'XP',
                      value: '2.4K',
                      subtitle: 'total',
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: _QuickStat(
                      emoji: '📚',
                      label: 'Lessons',
                      value: '47',
                      subtitle: 'done',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Quick actions
              Text(
                'QUICK ACTIONS',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              _QuickActionRow(
                icon: Icons.person_outline_rounded,
                label: 'View Profile',
                accentColor: AppColors.primary,
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push(Routes.viewProfile);
                },
              ),
              const SizedBox(height: 8),
              _QuickActionRow(
                icon: Icons.emoji_events_rounded,
                label: 'Achievements',
                accentColor: AppColors.tertiaryContainer,
                onTap: () {
                  final router = GoRouter.of(context);
                  Navigator.of(context).pop();
                  router.push(Routes.achievements);
                },
              ),
              const SizedBox(height: 8),
              _QuickActionRow(
                icon: Icons.settings_rounded,
                label: 'Settings',
                accentColor: AppColors.onSurfaceVariant,
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to settings
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSupabaseLesson(_SupabaseLesson lesson) {
    if (lesson.lessonType == 'language') {
      // Voice lesson — open with phrase/exercise player.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VoiceLessonPage(lessonId: lesson.id)),
      );
    } else {
      context.go(Routes.progress, extra: lesson.toCourseSelection());
    }
  }

  void _openVoiceLessonDetail(_VoiceLesson lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => lesson_detail.LessonDetailPage(
          type: lesson_detail.LessonType.voice,
          title: lesson.title,
          subtitle: lesson.subtitle,
          emoji: lesson.emoji,
          duration: lesson.duration,
          accentColor: lesson.color,
          progress: 0.0,
          totalLessons: 12,
          completedLessons: 0,
          learningObjectives: const [],
          sections: const [],
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
    _lessonRefreshNotifier?.removeListener(_handleLessonsChanged);
    final lessonsChannel = _lessonsChannel;
    if (lessonsChannel != null) {
      SupabaseService.client.removeChannel(lessonsChannel);
    }
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      child: SafeArea(
        child: CustomScrollView(
          controller: _scrollCtrl,
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildHeader()),

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

            // ── Voice lessons label ────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('VOICE LESSONS')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Voice lessons horizontal scroll ────────────────────────────
            SliverToBoxAdapter(child: _buildVoiceLessons()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Quick start label ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(child: _sectionLabel('QUICK START')),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Quick access to lesson pages ───────────────────────────────
            SliverToBoxAdapter(child: _buildLessonQuickAccess()),

            const SliverToBoxAdapter(child: SizedBox(height: 32)),

            // ── Continue learning label ────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverToBoxAdapter(
                child: _sectionLabel('CONTINUE LEARNING'),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 14)),

            // ── Explore courses ────────────────────────────────────────────
            SliverToBoxAdapter(child: _buildExploreCourseItems()),

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

  Widget _buildExploreCourseItems() {
    return ValueListenableBuilder<List<ProgressCourseSelection>>(
      valueListenable: ExploreCoursesService.instance.courses,
      builder: (context, courses, _) {
        if (courses.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: courses
                .map(
                  (course) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LessonCard(
                      emoji: '🎓',
                      title: course.topic,
                      chapter: course.title,
                      duration: course.level,
                      progress: 0.0,
                      accentColor: AppColors.primary,
                      isNew: !course.roadmapGenerated,
                      lessonType: course.roadmapGenerated
                          ? (course.title == 'Languages'
                              ? 'language'
                              : 'school')
                          : null,
                      onTap: () => context.go(Routes.progress, extra: course),
                    ),
                  ),
                )
                .toList(),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    final supaUser = Supabase.instance.client.auth.currentUser;
    final displayName = supaUser?.userMetadata?['name'] as String? ?? 'User';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0E1020), AppColors.surface],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Good morning,',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$displayName 👋',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              // Avatar
              GestureDetector(
                onTap: () => _showProfileQuickView(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryDim.withValues(alpha: 0.3),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      initial,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => _showStreakDetails(),
            child: const StreakBadge(count: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildVoiceLessons() {
    return SizedBox(
      height: 230,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _voiceLessons.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (context, i) {
          final v = _voiceLessons[i];
          return VoiceLessonCard(
            title: v.title,
            subtitle: v.subtitle,
            duration: v.duration,
            accentColor: v.color,
            emoji: v.emoji,
            isActive: i == 0,
            onTap: () => _openVoiceLessonDetail(v),
          );
        },
      ),
    );
  }

  Widget _buildLessonQuickAccess() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _LessonQuickAccessCard(
              title: 'Voice Lesson',
              subtitle: 'Practice pronunciation',
              emoji: '🎤',
              color: AppColors.primary,
              onTap: _openVoiceLessonPage,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _LessonQuickAccessCard(
              title: 'School Lesson',
              subtitle: 'Learn academics',
              emoji: '📚',
              color: AppColors.secondary,
              onTap: _openSchoolLessonPage,
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.8,
      ),
    );
  }
}

// ── Supabase lesson model ────────────────────────────────────────────────────

class _SupabaseLesson {
  const _SupabaseLesson({
    required this.id,
    required this.lessonType,
    required this.contentType,
    required this.difficulty,
    required this.title,
    required this.status,
    this.content,
  });

  factory _SupabaseLesson.fromMap(Map<String, dynamic> map) => _SupabaseLesson(
    id: map['id'] as String,
    lessonType: map['lesson_type'] as String? ?? 'school',
    contentType: map['content_type'] as String? ?? '',
    difficulty: map['difficulty'] as String? ?? 'Beginner',
    title: map['title'] as String? ?? '',
    status: map['status'] as String? ?? 'draft',
    content: map['content'] == null
        ? null
        : Map<String, dynamic>.from(map['content'] as Map),
  );

  final String id;
  final String lessonType;
  final String contentType;
  final String difficulty;
  final String title;
  final String status;
  final Map<String, dynamic>? content;

  String get topic {
    final value = content?['topic'] as String?;
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
    return contentType;
  }

  String get subtitle => topic.isNotEmpty ? topic : contentType;

  String get emoji {
    if (lessonType == 'language') return '🎤';
    switch (contentType.toLowerCase()) {
      case 'science':
        return '🔬';
      case 'math':
      case 'mathematics':
        return '📐';
      case 'history':
        return '📜';
      case 'biology':
        return '🌱';
      case 'chemistry':
        return '⚗️';
      case 'physics':
        return '⚡';
      case 'english':
        return '✍️';
      case 'geography':
        return '🌍';
      case 'music':
        return '🎵';
      default:
        return '📚';
    }
  }

  Color get color =>
      lessonType == 'language' ? AppColors.primary : AppColors.secondary;

  ProgressCourseSelection toCourseSelection() {
    final roadmapJson = content?['roadmap'] is Map
        ? Map<String, dynamic>.from(content!['roadmap'] as Map)
        : null;

    return ProgressCourseSelection(
      title: title,
      topic: topic,
      roadmapLanguage:
          (content?['roadmapLanguage'] as String?)?.trim().isNotEmpty == true
          ? (content!['roadmapLanguage'] as String).trim()
          : contentType,
      level: ((content?['level'] as String?) ?? difficulty.toLowerCase())
          .toLowerCase(),
      nativeLanguage:
          (content?['nativeLanguage'] as String?)?.trim().isNotEmpty == true
          ? (content!['nativeLanguage'] as String).trim()
          : 'English',
      roadmapJson: roadmapJson,
    );
  }

  String get duration {
    switch (difficulty) {
      case 'Advanced':
        return '30 min';
      case 'Intermediate':
        return '20 min';
      default:
        return '10 min';
    }
  }

  double get progress {
    switch (status) {
      case 'active':
        return 0.3;
      case 'completed':
        return 1.0;
      default:
        return 0.0;
    }
  }
}

// ── Static voice lesson data ─────────────────────────────────────────────────

class _VoiceLesson {
  const _VoiceLesson({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.color,
    required this.emoji,
  });
  final String title, subtitle, duration, emoji;
  final Color color;
}

const _voiceLessons = [
  _VoiceLesson(
    title: 'Pronunciation\nMastery',
    subtitle: 'Chapter 3 · Vowels',
    duration: '12 min',
    color: AppColors.primary,
    emoji: '🎤',
  ),
  _VoiceLesson(
    title: 'Conversational\nFlow',
    subtitle: 'Session 5 · Dialogue',
    duration: '8 min',
    color: AppColors.tertiary,
    emoji: '🗣️',
  ),
  _VoiceLesson(
    title: 'Accent\nReduction',
    subtitle: 'Module 2 · Rhythm',
    duration: '15 min',
    color: AppColors.secondary,
    emoji: '🎯',
  ),
];

// ── Quick Stat Widget ───────────────────────────────────────────────────────

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.emoji,
    required this.label,
    required this.value,
    required this.subtitle,
  });
  final String emoji, label, value, subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 9,
              color: AppColors.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Action Row ────────────────────────────────────────────────────────

class _QuickActionRow extends StatelessWidget {
  const _QuickActionRow({
    required this.icon,
    required this.label,
    required this.accentColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHighest.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.outlineVariant.withValues(alpha: 0.15),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 18),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Lesson Quick Access Card ───────────────────────────────────────────────

class _LessonQuickAccessCard extends StatelessWidget {
  const _LessonQuickAccessCard({
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.color,
    required this.onTap,
  });
  final String title;
  final String subtitle;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color.withValues(alpha: 0.15),
              color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: color.withValues(alpha: 0.6),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
