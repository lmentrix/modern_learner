import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';

class VocabularyCarousel extends StatelessWidget {
  const VocabularyCarousel({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onNext,
    required this.onPrev,
    required this.typeColor,
  });
  final List<VocabularyItemModel> items;
  final int currentIndex;
  final VoidCallback onNext;
  final VoidCallback onPrev;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final item = items[currentIndex];
    return Column(
      children: [
        // Progress dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            items.length,
            (i) => AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == currentIndex ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: i == currentIndex
                    ? typeColor
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                typeColor.withValues(alpha: 0.12),
                AppColors.surfaceContainerHigh,
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: typeColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Word + part of speech
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      item.word,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: typeColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      item.partOfSpeech,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: typeColor,
                      ),
                    ),
                  ),
                ],
              ),

              if (item.pronunciation.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  item.pronunciation,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Divider(color: AppColors.outlineVariant.withValues(alpha: 0.2)),
              const SizedBox(height: 12),

              // Translation
              Text(
                item.translation,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),

              if (item.exampleSentence.isNotEmpty) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.exampleSentence,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (item.exampleTranslation.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          item.exampleTranslation,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],

              if (item.memoryTip.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('💡', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.memoryTip,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.primary,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 14),

        // Navigation buttons
        Row(
          children: [
            Expanded(
              child: _NavButton(
                label: 'Previous',
                icon: Icons.arrow_back_rounded,
                onTap: currentIndex > 0 ? onPrev : null,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NavButton(
                label: currentIndex < items.length - 1 ? 'Next' : 'Done',
                icon: currentIndex < items.length - 1
                    ? Icons.arrow_forward_rounded
                    : Icons.check_rounded,
                onTap: currentIndex < items.length - 1 ? onNext : null,
                color: typeColor,
                isForward: true,
              ),
            ),
          ],
        ),

        const SizedBox(height: 6),
        Text(
          '${currentIndex + 1} of ${items.length}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.color,
    this.isForward = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  final Color color;
  final bool isForward;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: enabled ? 1.0 : 0.3,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: enabled
                ? color.withValues(alpha: 0.12)
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: enabled
                  ? color.withValues(alpha: 0.3)
                  : AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (!isForward) ...[
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
              if (isForward) ...[
                const SizedBox(width: 6),
                Icon(icon, size: 16, color: color),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
