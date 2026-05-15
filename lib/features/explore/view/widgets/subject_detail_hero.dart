import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/difficulty_badge.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_detail_back_button.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_detail_category_pill.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_detail_decorative_circles.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_detail_hero_background.dart';
import 'package:modern_learner_production/features/explore/view/widgets/subject_detail_title.dart';

class SubjectDetailHero extends StatelessWidget {
  const SubjectDetailHero({super.key, required this.subject});

  final LearningSubject subject;

  @override
  Widget build(BuildContext context) {
    final accent = subject.accentColor;
    final w = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final baseHeight = w < 360
        ? 280.0
        : w >= 600
        ? 380.0
        : 320.0;
    final heroHeight = baseHeight + topInset;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          SubjectDetailHeroBackground(accent: accent),
          SubjectDetailDecorativeCircles(accent: accent),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SubjectDetailBackButton(),
                    const Spacer(),
                    SubjectDetailCategoryPill(
                      category: subject.category,
                      accent: accent,
                    ),
                    const SizedBox(height: 14),
                    SubjectDetailTitle(
                      emoji: subject.emoji,
                      name: subject.name,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        DifficultyBadge(
                          level: subject.difficulty,
                          accent: accent,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${subject.topicCount} topics',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.72),
                          ),
                        ),
                      ],
                    ),
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
