import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/models/progress_course_selection.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/service/explore_courses_service.dart';
import 'package:modern_learner_production/features/explore/view/section/learning_topic_detail_hero_section.dart';
import 'package:modern_learner_production/features/explore/view/section/learning_topic_detail_stats_section.dart';

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
      courseType: ProgressCourseType.school,
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
            child: LearningTopicDetailHeroSection(topic: topic, accent: accent),
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
                        const Icon(
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

                  LearningTopicDetailStatsSection(topic: topic, accent: accent),

                  const SizedBox(height: 28),
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
