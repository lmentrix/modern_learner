import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/difficulty_badge.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

/// Passed via [GoRouterState.extra] when navigating to the topic detail route.
class LearningTopicDetailArgs {
  const LearningTopicDetailArgs({required this.subject, required this.topic});

  final LearningSubject subject;
  final LearningTopic topic;
}

class LearningTopicDetailPage extends StatelessWidget {
  const LearningTopicDetailPage({
    super.key,
    required this.subject,
    required this.topic,
  });

  final LearningSubject subject;
  final LearningTopic topic;

  void _startCourse(BuildContext context) {
    final course = ProgressCourseSelection(
      title: subject.name,
      topic: topic.name,
      roadmapLanguage: topic.name,
      level: topic.difficulty.label.toLowerCase(),
      nativeLanguage: 'English',
    );
    ExploreCoursesService.instance.addCourse(course);
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final accent = subject.accentColor;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360
        ? 16.0
        : w >= 600
        ? 28.0
        : 20.0;

    return Material(
      color: AppColors.surface,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _TopicHero(topic: topic, accent: accent),
          ),
          SliverPadding(
            padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Subject breadcrumb
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          subject.emoji,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          subject.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 16,
                          color: AppColors.onSurfaceVariant,
                        ),
                        Text(
                          topic.name,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Stats row
                  _StatsRow(topic: topic, accent: accent),

                  const SizedBox(height: 28),

                  // Description card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accent.withValues(alpha: 0.18)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ABOUT THIS TOPIC',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.4,
                            color: accent,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          topic.description,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            height: 1.6,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // What you'll learn section
                  Text(
                    'WHAT YOU\'LL LEARN',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 14),
                  ..._learningPoints(topic).map(
                    (point) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 3),
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.14),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              size: 12,
                              color: accent,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              point,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                height: 1.5,
                                color: AppColors.onSurface,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _startCourse(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      icon: const Icon(Icons.rocket_launch_rounded),
                      label: Text(
                        'Start This Topic',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Generate generic but contextual learning points from the topic description.
  List<String> _learningPoints(LearningTopic t) {
    return [
      'Core concepts and theory of ${t.name}',
      'Practical applications and real-world examples',
      'Problem-solving techniques used by experts',
      'Self-assessment exercises to track progress',
    ];
  }
}

// ── Hero ──────────────────────────────────────────────────────────────────────

class _TopicHero extends StatelessWidget {
  const _TopicHero({required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final baseHeight = w < 360
        ? 220.0
        : w >= 600
        ? 320.0
        : 260.0;
    final heroHeight = baseHeight + topInset;
    final emojiSize = w < 360
        ? 42.0
        : w >= 600
        ? 60.0
        : 52.0;
    final titleSize = w < 360
        ? 24.0
        : w >= 600
        ? 36.0
        : 30.0;
    final hPad = w < 360
        ? 16.0
        : w >= 600
        ? 28.0
        : 20.0;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [accent.withValues(alpha: 0.28), AppColors.surface],
                ),
              ),
            ),
          ),
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.withValues(alpha: 0.10),
              ),
            ),
          ),
          // Content
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.14),
                          ),
                        ),
                        child: const Icon(
                          Icons.arrow_back_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(topic.emoji, style: TextStyle(fontSize: emojiSize)),
                    const SizedBox(height: 10),
                    Text(
                      topic.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        height: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    LevelPill(level: topic.difficulty, accent: accent),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.topic, required this.accent});

  final LearningTopic topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatChip(
          icon: Icons.schedule_rounded,
          label: '${topic.estimatedMinutes} min',
          accent: accent,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.signal_cellular_alt_rounded,
          label: topic.difficulty.label,
          accent: accent,
        ),
        const SizedBox(width: 10),
        _StatChip(
          icon: Icons.auto_stories_rounded,
          label: 'AI-generated roadmap',
          accent: accent,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    required this.accent,
  });

  final IconData icon;
  final String label;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: accent),
          const SizedBox(width: 5),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
