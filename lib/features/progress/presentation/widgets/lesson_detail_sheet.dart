import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';

class LessonDetailSheet extends StatelessWidget {

  const LessonDetailSheet({
    super.key,
    required this.chapter,
    required this.lesson,
    required this.onStart,
    required this.onClaim,
    required this.canClaim,
  });
  final Chapter chapter;
  final Lesson lesson;
  final VoidCallback onStart;
  final VoidCallback onClaim;
  final bool canClaim;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Chapter badge + XP reward
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ChapterBadge(chapter: chapter),
                    Text(
                      '+${lesson.xpReward} XP',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Lesson type + title + description
                Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.outlineVariant.withValues(
                            alpha: 0.3,
                          ),
                        ),
                      ),
                      child: Center(
                        child: _LessonTypeIcon(type: lesson.type),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _LessonTypeLabel(type: lesson.type),
                              const SizedBox(width: 8),
                              Text(
                                lesson.title,
                                style: GoogleFonts.spaceGrotesk(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            lesson.description,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Skills to learn
                if (chapter.skills.isNotEmpty) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'You\'ll learn',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: chapter.skills.take(3).map((skill) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primary
                                    .withValues(alpha: 0.2),
                              ),
                            ),
                            child: Text(
                              skill,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                color: AppColors.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // Action button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: canClaim
                      ? _ClaimButton(onTap: onClaim)
                      : _StartButton(status: lesson.status, onTap: onStart),
                ),
              ],
            ),
          ),
          const SafeArea(child: SizedBox(height: 4)),
        ],
      ),
    );
  }
}

class _ChapterBadge extends StatelessWidget {

  const _ChapterBadge({required this.chapter});
  final Chapter chapter;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            chapter.icon,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 6),
          Text(
            'Ch. ${chapter.chapterNumber}',
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTypeIcon extends StatelessWidget {

  const _LessonTypeIcon({required this.type});
  final LessonType type;

  @override
  Widget build(BuildContext context) {
    final (icon, color) = switch (type) {
      LessonType.vocabulary => (Icons.book_rounded, AppColors.primary),
      LessonType.grammar => (Icons.rule_rounded, AppColors.primary),
      LessonType.exercise => (Icons.fitness_center_rounded, AppColors.tertiary),
      LessonType.listening => (Icons.headphones_rounded, AppColors.secondary),
      LessonType.reading => (Icons.menu_book_rounded, AppColors.secondary),
      LessonType.conversation => (Icons.chat_rounded, AppColors.tertiary),
    };

    return Icon(icon, color: color, size: 24);
  }
}

class _LessonTypeLabel extends StatelessWidget {

  const _LessonTypeLabel({required this.type});
  final LessonType type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      LessonType.vocabulary => ('VOCAB', AppColors.primary),
      LessonType.grammar => ('GRAMMAR', AppColors.primary),
      LessonType.exercise => ('EXERCISE', AppColors.tertiary),
      LessonType.listening => ('LISTEN', AppColors.secondary),
      LessonType.reading => ('READ', AppColors.secondary),
      LessonType.conversation => ('TALK', AppColors.tertiary),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

class _StartButton extends StatelessWidget {

  const _StartButton({required this.status, required this.onTap});
  final LessonStatus status;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      LessonStatus.available => 'Start Lesson',
      LessonStatus.inProgress => 'Continue',
      _ => 'Start',
    };

    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: Text(label),
    );
  }
}

class _ClaimButton extends StatelessWidget {

  const _ClaimButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.tertiary,
        foregroundColor: Colors.black,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.spaceGrotesk(
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('🎉 ', style: TextStyle(fontSize: 18)),
          Text('Claim Rewards'),
        ],
      ),
    );
  }
}
