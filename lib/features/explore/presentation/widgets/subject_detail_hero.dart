import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';
import 'package:modern_learner_production/features/explore/presentation/widgets/difficulty_badge.dart';

class SubjectDetailHero extends StatelessWidget {
  const SubjectDetailHero({super.key, required this.subject});

  final LearningSubject subject;

  @override
  Widget build(BuildContext context) {
    final accent = subject.accentColor;
    final w = MediaQuery.sizeOf(context).width;
    final topInset = MediaQuery.paddingOf(context).top;
    final baseHeight = w < 360 ? 280.0 : w >= 600 ? 380.0 : 320.0;
    final heroHeight = baseHeight + topInset;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        children: [
          _HeroBackground(accent: accent),
          _DecorativeCircles(accent: accent),
          Positioned.fill(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _BackButton(),
                    const Spacer(),
                    _CategoryPill(category: subject.category, accent: accent),
                    const SizedBox(height: 14),
                    _SubjectTitle(
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

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [accent.withValues(alpha: 0.30), AppColors.surface],
          ),
        ),
      ),
    );
  }
}

class _DecorativeCircles extends StatelessWidget {
  const _DecorativeCircles({required this.accent});

  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -40,
          right: -40,
          child: Container(
            width: 220,
            height: 220,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.10),
            ),
          ),
        ),
        Positioned(
          top: 20,
          right: 20,
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.08),
            ),
          ),
        ),
      ],
    );
  }
}

class _BackButton extends StatelessWidget {
  const _BackButton();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
        ),
        child: const Icon(
          Icons.arrow_back_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({required this.category, required this.accent});

  final String category;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: accent.withValues(alpha: 0.40)),
      ),
      child: Text(
        category.toUpperCase(),
        style: GoogleFonts.inter(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
          color: accent,
        ),
      ),
    );
  }
}

class _SubjectTitle extends StatelessWidget {
  const _SubjectTitle({required this.emoji, required this.name});

  final String emoji;
  final String name;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final emojiSize = w < 360 ? 40.0 : w >= 600 ? 56.0 : 48.0;
    final titleSize = w < 360 ? 28.0 : w >= 600 ? 44.0 : 36.0;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(emoji, style: TextStyle(fontSize: emojiSize)),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            name,
            style: GoogleFonts.spaceGrotesk(
              fontSize: titleSize,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.0,
            ),
          ),
        ),
      ],
    );
  }
}
