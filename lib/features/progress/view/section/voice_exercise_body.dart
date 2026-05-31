import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_label.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_small_note.dart';
import 'package:modern_learner_production/features/progress/view/widgets/vocabulary_row.dart';
import 'package:modern_learner_production/features/progress/view/widgets/voice_step_row.dart';
import 'package:modern_learner_production/features/voice/service/voice_pronunciation_scorer.dart';

class VoiceExerciseBody extends StatefulWidget {
  const VoiceExerciseBody({
    super.key,
    required this.detail,
    required this.accentColor,
    required this.checkedVoiceStepKeys,
    required this.onVoiceStepChecked,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final Set<String> checkedVoiceStepKeys;
  final ValueChanged<String> onVoiceStepChecked;

  @override
  State<VoiceExerciseBody> createState() => _VoiceExerciseBodyState();
}

class _VoiceExerciseBodyState extends State<VoiceExerciseBody>
    with SingleTickerProviderStateMixin {
  // Latest score per step number (updates on each attempt).
  final Map<int, PronunciationResult> _stepScores = {};

  late final AnimationController _sessionScoreCtrl;
  late final Animation<double> _sessionScoreAnim;

  @override
  void initState() {
    super.initState();
    _sessionScoreCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _sessionScoreAnim = CurvedAnimation(
      parent: _sessionScoreCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _sessionScoreCtrl.dispose();
    super.dispose();
  }

  void _onStepScored(int stepNumber, PronunciationResult result) {
    setState(() => _stepScores[stepNumber] = result);
    _sessionScoreCtrl.forward(from: 0);

    // Mark the step as checked so the header progress bar advances.
    final key = 'voice_step_$stepNumber';
    if (!widget.checkedVoiceStepKeys.contains(key)) {
      widget.onVoiceStepChecked(key);
    }
  }

  // Average score across all steps that have been attempted.
  double get _sessionScore {
    if (_stepScores.isEmpty) return 0;
    final sum = _stepScores.values.fold(0.0, (acc, r) => acc + r.score);
    return sum / _stepScores.length;
  }

  int get _sessionScorePercent => (_sessionScore * 100).round();

  Color get _sessionColor {
    if (_sessionScore >= 0.78) return AppColors.tertiary;
    if (_sessionScore >= 0.50) return const Color(0xFFFFD580);
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.detail.practiceSteps;

    return Column(
      children: [
        // ── Session score card (appears once any step is scored) ──────────
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          child: _stepScores.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _SessionScoreCard(
                    scoreAnim: _sessionScoreAnim,
                    sessionScore: _sessionScore,
                    sessionScorePercent: _sessionScorePercent,
                    sessionColor: _sessionColor,
                    completedSteps: _stepScores.length,
                    totalSteps: steps.length,
                    accentColor: widget.accentColor,
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // ── Speaking practice panel ──────────────────────────────────────
        ExercisePanel(
          accentColor: widget.accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExerciseLabel('Speaking practice'),
              const SizedBox(height: 12),
              if ((widget.detail.speakingFocus ?? '').trim().isNotEmpty)
                Text(
                  widget.detail.speakingFocus ?? '',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              const SizedBox(height: 14),
              ...steps.map((step) {
                return VoiceStepRow(
                  step: step,
                  accentColor: widget.accentColor,
                  onScored: (result) => _onStepScored(step.stepNumber, result),
                );
              }),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Vocabulary panel ─────────────────────────────────────────────
        ExercisePanel(
          accentColor: AppColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ExerciseLabel('Vocabulary'),
              const SizedBox(height: 12),
              ...widget.detail.vocabularyItems.map(VocabularyRow.new),
            ],
          ),
        ),

        // ── Performance task ─────────────────────────────────────────────
        if ((widget.detail.performanceTask ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          ExercisePanel(
            accentColor: AppColors.tertiary,
            child: ExerciseSmallNote(
              icon: Icons.record_voice_over_rounded,
              text: widget.detail.performanceTask ?? '',
            ),
          ),
        ],
      ],
    );
  }
}

// ── Session score card ────────────────────────────────────────────────────────

class _SessionScoreCard extends StatelessWidget {
  const _SessionScoreCard({
    required this.scoreAnim,
    required this.sessionScore,
    required this.sessionScorePercent,
    required this.sessionColor,
    required this.completedSteps,
    required this.totalSteps,
    required this.accentColor,
  });

  final Animation<double> scoreAnim;
  final double sessionScore;
  final int sessionScorePercent;
  final Color sessionColor;
  final int completedSteps;
  final int totalSteps;
  final Color accentColor;

  String get _label {
    if (sessionScore >= 0.90) return 'Outstanding session!';
    if (sessionScore >= 0.75) return 'Strong pronunciation';
    if (sessionScore >= 0.60) return 'Good progress';
    if (sessionScore >= 0.40) return 'Keep practicing';
    return 'Room to improve';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: sessionColor.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: sessionColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: sessionColor.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.spatial_audio_rounded, size: 18, color: sessionColor),
              const SizedBox(width: 8),
              Text(
                'Session score',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: sessionColor,
                  letterSpacing: 1.2,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: scoreAnim,
                builder: (context, _) => Text(
                  '$sessionScorePercent%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: sessionColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Animated score bar
          AnimatedBuilder(
            animation: scoreAnim,
            builder: (context, _) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: sessionScore * scoreAnim.value,
                  minHeight: 8,
                  backgroundColor: AppColors.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(sessionColor),
                ),
              );
            },
          ),
          const SizedBox(height: 8),

          // Steps completed + label
          Row(
            children: [
              Text(
                '$completedSteps of $totalSteps steps',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              Text(
                _label,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: sessionColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
