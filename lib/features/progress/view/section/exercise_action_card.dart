import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/view/widgets/exercise_panel.dart';

class ExerciseActionCard extends StatelessWidget {
  const ExerciseActionCard({
    super.key,
    required this.checked,
    required this.score,
    required this.total,
    required this.accentColor,
    required this.onPrimaryAction,
  });

  final bool checked;
  final int score;
  final int total;
  final Color accentColor;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final hasScore = total > 0;
    final label = checked
        ? hasScore
              ? 'Score: $score of $total'
              : 'Practice checked'
        : hasScore
        ? 'Ready to review your answers'
        : 'Ready to complete this practice';
    return ExercisePanel(
      accentColor: accentColor,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 360;
          final button = FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: Icon(
              checked ? Icons.arrow_forward_rounded : Icons.check_rounded,
              size: 18,
            ),
            label: Text(checked ? 'Continue' : 'Check'),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
          );

          if (compact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 12),
                button,
              ],
            );
          }

          return Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              button,
            ],
          );
        },
      ),
    );
  }
}
