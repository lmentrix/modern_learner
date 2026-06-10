import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/core/utils/responsive.dart';
import 'package:modern_learner_production/features/new_lesson/data/new_lesson_page_constants.dart';

class NewLessonPreviewCard extends StatelessWidget {
  const NewLessonPreviewCard({
    super.key,
    required this.selectedLanguage,
    required this.selectedDifficulty,
  });

  final String? selectedLanguage;
  final String selectedDifficulty;

  @override
  Widget build(BuildContext context) {
    final language = selectedLanguage == null
        ? context.tr('Pick a language')
        : context.tr(selectedLanguage!);
    final chapterCount = switch (selectedDifficulty) {
      'Intermediate' => 5,
      'Advanced' => 6,
      _ => 4,
    };
    final lessonCount = switch (selectedDifficulty) {
      'Intermediate' => 18,
      'Advanced' => 24,
      _ => 12,
    };
    final ready = selectedLanguage != null;
    final compact = Responsive.isCompact(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: NewLessonPageConstants.previewGradient,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: ready
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.outlineVariant.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.surfaceContainerLowest.withValues(alpha: 0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary,
                      AppColors.tertiary.withValues(alpha: 0.76),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('Voice roadmap preview'),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      child: Text(
                        language,
                        key: ValueKey(language),
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurface,
                          height: 1.05,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            context.tr(
              'Short drills, recall loops, and guided response practice tailored to your level.',
            ),
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          if (compact)
            Column(
              children: [
                _buildMetric(
                  label: context.tr('Difficulty'),
                  value: context.tr(selectedDifficulty),
                  color: AppColors.tertiary,
                  icon: Icons.tune_rounded,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetric(
                        label: context.tr('Chapters'),
                        value: '$chapterCount',
                        color: AppColors.secondary,
                        icon: Icons.layers_rounded,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildMetric(
                        label: context.tr('Lessons'),
                        value: '$lessonCount',
                        color: AppColors.primary,
                        icon: Icons.bolt_rounded,
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: _buildMetric(
                    label: context.tr('Difficulty'),
                    value: context.tr(selectedDifficulty),
                    color: AppColors.tertiary,
                    icon: Icons.tune_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetric(
                    label: context.tr('Chapters'),
                    value: '$chapterCount',
                    color: AppColors.secondary,
                    icon: Icons.layers_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _buildMetric(
                    label: context.tr('Lessons'),
                    value: '$lessonCount',
                    color: AppColors.primary,
                    icon: Icons.bolt_rounded,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                ready
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked,
                size: 17,
                color: ready ? AppColors.tertiary : AppColors.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ready
                      ? context.tr('Ready to generate')
                      : context.tr('Waiting for language selection'),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: ready
                        ? AppColors.tertiary
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: Text(
              value,
              key: ValueKey(value),
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
