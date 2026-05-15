import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class CreateCourseHeaderSection extends StatelessWidget {
  const CreateCourseHeaderSection({
    super.key,
    required this.subject,
    required this.topic,
    required this.accent,
  });

  final LearningSubject subject;
  final LearningTopic? topic;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final displayEmoji = topic?.emoji ?? subject.emoji;
    final displayName = topic?.name ?? subject.name;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = w < 360
        ? 16.0
        : w >= 600
        ? 28.0
        : 20.0;
    final emojiSize = w < 360
        ? 34.0
        : w >= 600
        ? 50.0
        : 42.0;
    final titleSize = w < 360
        ? 20.0
        : w >= 600
        ? 32.0
        : 26.0;

    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.10),
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [accent.withValues(alpha: 0.32), AppColors.surface],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
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
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: accent.withValues(alpha: 0.40)),
                    ),
                    child: Text(
                      'CREATE COURSE',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.4,
                        color: accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(displayEmoji, style: TextStyle(fontSize: emojiSize)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          displayName,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.05,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (topic != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      'in ${subject.name}',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.65),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
