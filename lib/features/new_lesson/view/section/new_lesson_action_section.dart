import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';

class NewLessonActionSection extends StatelessWidget {
  const NewLessonActionSection({
    super.key,
    required this.canStart,
    required this.selectedLanguage,
    required this.selectedDifficulty,
    required this.onStart,
  });

  final bool canStart;
  final String? selectedLanguage;
  final String selectedDifficulty;
  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom + 18,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer.withValues(alpha: 0.86),
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.12),
            width: 0.6,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            canStart
                ? '$selectedLanguage • $selectedDifficulty roadmap'
                : 'Select a language to unlock generation',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: canStart
                  ? AppColors.onSurface
                  : AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: canStart ? onStart : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 58,
              decoration: BoxDecoration(
                gradient: canStart
                    ? LinearGradient(
                        colors: [
                          AppColors.primary,
                          AppColors.primary.withValues(alpha: 0.76),
                        ],
                      )
                    : const LinearGradient(
                        colors: [
                          AppColors.surfaceContainerHigh,
                          AppColors.surfaceContainerHigh,
                        ],
                      ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: canStart
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.26),
                          blurRadius: 22,
                          offset: const Offset(0, 8),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    canStart
                        ? Icons.auto_awesome_rounded
                        : Icons.lock_outline_rounded,
                    color: canStart ? Colors.white : AppColors.onSurfaceVariant,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    canStart
                        ? 'Generate $selectedDifficulty Roadmap'
                        : 'Choose a language first',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: canStart
                          ? Colors.white
                          : AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
