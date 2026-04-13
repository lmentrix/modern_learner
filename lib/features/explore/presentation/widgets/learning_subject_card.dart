import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/domain/entities/learning_subject.dart';

class LearningSubjectCard extends StatefulWidget {
  const LearningSubjectCard({
    super.key,
    required this.subject,
    this.onTap,
  });

  final LearningSubject subject;
  final VoidCallback? onTap;

  @override
  State<LearningSubjectCard> createState() => _LearningSubjectCardState();
}

class _LearningSubjectCardState extends State<LearningSubjectCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 1.0,
      value: 1.0,
    );
    _scaleAnim = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) => _controller.reverse();
  void _onTapUp(TapUpDetails _) => _controller.forward();
  void _onTapCancel() => _controller.forward();

  @override
  Widget build(BuildContext context) {
    final subject = widget.subject;
    final accent = subject.accentColor;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.22),
                AppColors.surfaceContainerLow,
                AppColors.surface.withValues(alpha: 0.9),
              ],
            ),
            border: Border.all(
              color: accent.withValues(alpha: 0.28),
            ),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.10),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    subject.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                  const Spacer(),
                  _DifficultyDot(level: subject.difficulty, accent: accent),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                subject.name,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurface,
                  height: 1.1,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                subject.description,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                  height: 1.4,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      subject.category,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: accent,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${subject.topicCount} topics',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyDot extends StatelessWidget {
  const _DifficultyDot({required this.level, required this.accent});

  final DifficultyLevel level;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        level.label,
        style: GoogleFonts.inter(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          color: accent,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
