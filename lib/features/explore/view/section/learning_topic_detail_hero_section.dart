import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/view/widgets/level_pill.dart';

class LearningTopicDetailHeroSection extends StatelessWidget {
  const LearningTopicDetailHeroSection({
    super.key,
    required this.topic,
    required this.accent,
  });

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
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
