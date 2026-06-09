import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_header_pill.dart';

class ExerciseHeader extends StatelessWidget {
  const ExerciseHeader({
    super.key,
    required this.detail,
    required this.accentColor,
    required this.checked,
    required this.score,
    required this.total,
    required this.onBack,
    this.answeredCount = 0,
    this.streak = 0,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final bool checked;
  final int score;
  final int total;
  final VoidCallback onBack;

  /// How many questions have been individually checked so far.
  final int answeredCount;

  /// Current consecutive-correct streak.
  final int streak;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: BoxDecoration(gradient: ProfilePageConstants.headerGradient),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Top row: back / streak / score pill ───────────────────────
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              const SizedBox(width: 8),
              // Streak badge (visible when streak >= 2)
              if (streak >= 2) ...[
                _StreakBadge(streak: streak, color: accentColor),
                const SizedBox(width: 8),
              ],
              const Spacer(),
              ExerciseHeaderPill(
                label: checked && total > 0 ? '$score/$total' : 'Exercise',
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Title block ───────────────────────────────────────────────
          Text(
            'Chapter ${detail.chapterNumber}.${detail.subcontentNumber}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.55),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.subcontentTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.06,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.chapterTitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(height: 20),

          // ── Progress track ────────────────────────────────────────────
          if (total > 0)
            _ProgressTrack(
              answered: answeredCount,
              total: total,
              accentColor: accentColor,
            ),
        ],
      ),
    );
  }
}

// ── Progress track ────────────────────────────────────────────────────────────

class _ProgressTrack extends StatelessWidget {
  const _ProgressTrack({
    required this.answered,
    required this.total,
    required this.accentColor,
  });

  final int answered;
  final int total;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Segmented bar
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              const segGap = 4.0;
              final segWidth =
                  ((constraints.maxWidth - segGap * (total - 1)) / total).clamp(
                    4.0,
                    40.0,
                  );
              return Row(
                children: List.generate(total, (i) {
                  final filled = i < answered;
                  return Padding(
                    padding: EdgeInsets.only(right: i < total - 1 ? segGap : 0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.easeOutCubic,
                      width: segWidth,
                      height: 5,
                      decoration: BoxDecoration(
                        color: filled
                            ? accentColor
                            : Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: filled
                            ? [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.55),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                    ),
                  );
                }),
              );
            },
          ),
        ),
        const SizedBox(width: 10),
        // x / total label
        Text(
          '$answered/$total',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: Colors.white.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

// ── Streak badge ──────────────────────────────────────────────────────────────

class _StreakBadge extends StatefulWidget {
  const _StreakBadge({required this.streak, required this.color});

  final int streak;
  final Color color;

  @override
  State<_StreakBadge> createState() => _StreakBadgeState();
}

class _StreakBadgeState extends State<_StreakBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  int _prevStreak = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.28), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.28, end: 0.92), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.92, end: 1.00), weight: 35),
    ]).animate(CurvedAnimation(parent: _ctrl, curve: Curves.linear));
    _prevStreak = widget.streak;
  }

  @override
  void didUpdateWidget(_StreakBadge old) {
    super.didUpdateWidget(old);
    if (widget.streak > _prevStreak) {
      _ctrl.forward(from: 0);
    }
    _prevStreak = widget.streak;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) =>
          Transform.scale(scale: _scale.value, child: child),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: widget.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: widget.color.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: widget.color.withValues(alpha: 0.25),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bolt_rounded, size: 13, color: widget.color),
            const SizedBox(width: 3),
            Text(
              '${widget.streak}×',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: widget.color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
