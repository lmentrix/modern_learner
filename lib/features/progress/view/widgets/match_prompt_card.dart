import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

class MatchPromptCard extends StatelessWidget {
  const MatchPromptCard({
    super.key,
    required this.label,
    required this.selectedAnswer,
    required this.checked,
    required this.isActive,
    required this.isCorrect,
    required this.accentColor,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String? selectedAnswer;
  final bool checked;
  final bool isActive;
  final bool isCorrect;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = selectedAnswer != null;
    final showCorrect = checked && hasAnswer && isCorrect;
    final showWrong = checked && hasAnswer && !isCorrect;
    final tone = showCorrect
        ? AppColors.tertiary
        : showWrong
        ? AppColors.error
        : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (isActive || hasAnswer)
                ? tone.withValues(alpha: 0.10)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isActive || hasAnswer)
                  ? tone.withValues(alpha: 0.36)
                  : AppColors.outlineVariant.withValues(alpha: 0.14),
              width: isActive ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.drag_indicator_rounded, size: 18, color: tone),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: AppColors.onSurfaceVariant,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tone.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      showCorrect
                          ? Icons.check_circle_rounded
                          : showWrong
                          ? Icons.error_rounded
                          : hasAnswer
                          ? Icons.link_rounded
                          : Icons.add_link_rounded,
                      size: 16,
                      color: tone,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedAnswer ?? 'Choose a matching answer',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hasAnswer
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
