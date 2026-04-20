import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/voice_lesson_entity.dart';

/// Displays a phrase card with text, phonetic, translation, and tip
class VoicePhraseCard extends StatelessWidget {
  const VoicePhraseCard({
    super.key,
    required this.phrase,
    required this.accentColor,
    required this.voiceProfile,
    this.isPlaying = false,
    this.isLoading = false,
    this.audioErrorMessage,
    this.onPlayTap,
  });

  final VoicePhrase phrase;
  final Color accentColor;
  final VoiceLessonVoiceProfile voiceProfile;
  final bool isPlaying;
  final bool isLoading;
  final String? audioErrorMessage;
  final VoidCallback? onPlayTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with play button
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: onPlayTap,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accentColor, accentColor.withValues(alpha: 0.7)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    isLoading
                        ? Icons.graphic_eq_rounded
                        : isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      phrase.text,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      phrase.phonetic,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Translation
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('🌐', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Translation',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phrase.translation,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Tip
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tertiaryContainer.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.tertiary.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💡', style: TextStyle(fontSize: 18)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Usage Tip',
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phrase.tip,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppColors.onSurface,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (phrase.audioCues.isNotEmpty) ...[
            const SizedBox(height: 12),
            _CueSection(
              title: 'AI Voice Cues',
              accentColor: accentColor,
              icon: Icons.multitrack_audio_rounded,
              cues: phrase.audioCues,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 18, color: accentColor),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voiceProfile.disclosure,
                        style: GoogleFonts.inter(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.onSurfaceVariant,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${voiceProfile.voice} · ${voiceProfile.model}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                      if (voiceProfile.style.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          voiceProfile.style,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: AppColors.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (audioErrorMessage != null && audioErrorMessage!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.18),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline_rounded,
                    size: 18,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      audioErrorMessage!,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppColors.onSurface,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Horizontal phrase selector with thumbnails
class VoicePhraseSelector extends StatelessWidget {
  const VoicePhraseSelector({
    super.key,
    required this.phrases,
    required this.currentIndex,
    required this.accentColor,
    this.onPhraseSelected,
  });

  final List<VoicePhrase> phrases;
  final int currentIndex;
  final Color accentColor;
  final ValueChanged<int>? onPhraseSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: phrases.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final isSelected = index == currentIndex;
          final phrase = phrases[index];
          return GestureDetector(
            onTap: () => onPhraseSelected?.call(index),
            child: Container(
              width: 120,
              decoration: BoxDecoration(
                color: isSelected
                    ? accentColor.withValues(alpha: 0.15)
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? accentColor.withValues(alpha: 0.5)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${index + 1}',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? accentColor
                            : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Expanded(
                      child: Text(
                        phrase.text,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VoiceLessonInsightCard extends StatelessWidget {
  const VoiceLessonInsightCard({
    super.key,
    required this.lesson,
    required this.accentColor,
  });

  final VoiceLessonEntity lesson;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI Lesson Notes',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          if (lesson.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              lesson.description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppColors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
          if (lesson.practicePhrases.isNotEmpty) ...[
            const SizedBox(height: 14),
            _CueSection(
              title: 'Shadowing Phrases',
              accentColor: accentColor,
              icon: Icons.record_voice_over_rounded,
              cues: lesson.practicePhrases.take(4).toList(),
            ),
          ],
          if (lesson.pronunciationTips.isNotEmpty) ...[
            const SizedBox(height: 14),
            ...lesson.pronunciationTips
                .take(2)
                .map(
                  (tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tip.category,
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accentColor,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            tip.tip,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppColors.onSurface,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ],
        ],
      ),
    );
  }
}

class _CueSection extends StatelessWidget {
  const _CueSection({
    required this.title,
    required this.accentColor,
    required this.icon,
    required this.cues,
  });

  final String title;
  final Color accentColor;
  final IconData icon;
  final List<String> cues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: accentColor),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurfaceVariant,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: cues
              .map(
                (cue) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.15),
                    ),
                  ),
                  child: Text(
                    cue,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

/// Exercise question card for voice lessons
class VoiceExerciseCard extends StatelessWidget {
  const VoiceExerciseCard({
    super.key,
    required this.exercise,
    required this.accentColor,
    this.selectedAnswer,
    this.showResult = false,
    this.onAnswerSelected,
  });

  final VoiceExercise exercise;
  final Color accentColor;
  final int? selectedAnswer;
  final bool showResult;
  final ValueChanged<int>? onAnswerSelected;

  bool get isAnswerCorrect =>
      showResult && selectedAnswer == exercise.correctIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.help_outline_rounded,
                    color: AppColors.onSurface,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    exercise.question,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Options
          ...exercise.options.asMap().entries.map(
            (entry) => _buildOption(entry.key, entry.value),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(int index, String option) {
    final isSelected = selectedAnswer == index;
    final isCorrect = exercise.correctIndex == index;

    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (showResult) {
      if (isCorrect) {
        borderColor = AppColors.tertiary;
        backgroundColor = AppColors.tertiary.withValues(alpha: 0.1);
        textColor = AppColors.onSurface;
      } else if (isSelected && !isCorrect) {
        borderColor = AppColors.error;
        backgroundColor = AppColors.error.withValues(alpha: 0.1);
        textColor = AppColors.onSurface;
      } else {
        borderColor = AppColors.outlineVariant.withValues(alpha: 0.2);
        backgroundColor = AppColors.surfaceContainerHighest.withValues(
          alpha: 0.3,
        );
        textColor = AppColors.onSurfaceVariant;
      }
    } else {
      borderColor = isSelected
          ? accentColor.withValues(alpha: 0.5)
          : AppColors.outlineVariant.withValues(alpha: 0.2);
      backgroundColor = isSelected
          ? accentColor.withValues(alpha: 0.1)
          : AppColors.surfaceContainerHighest.withValues(alpha: 0.3);
      textColor = isSelected ? AppColors.onSurface : AppColors.onSurfaceVariant;
    }

    return GestureDetector(
      onTap: showResult ? null : () => onAnswerSelected?.call(index),
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected || (showResult && isCorrect)
                    ? accentColor
                    : AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  String.fromCharCode(65 + index), // A, B, C, D
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected || (showResult && isCorrect)
                        ? Colors.white
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            if (showResult && isCorrect)
              const Icon(
                Icons.check_circle_rounded,
                color: AppColors.tertiary,
                size: 22,
              )
            else if (showResult && isSelected && !isCorrect)
              const Icon(Icons.error_rounded, color: AppColors.error, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Progress indicator for exercises
class VoiceExercisesProgress extends StatelessWidget {
  const VoiceExercisesProgress({
    super.key,
    required this.answeredCount,
    required this.totalCount,
    required this.accentColor,
    required this.progress,
  });

  final int answeredCount;
  final int totalCount;
  final Color accentColor;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'EXERCISES',
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.onSurfaceVariant,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                '$answeredCount/$totalCount',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
