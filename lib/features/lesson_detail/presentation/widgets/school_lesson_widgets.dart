import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/domain/entities/school_lesson_entity.dart';

/// Accordion-style section card for school lessons
class SchoolSectionCard extends StatelessWidget {
  const SchoolSectionCard({
    super.key,
    required this.section,
    required this.color,
    this.isExpanded = false,
    this.onTap,
  });

  final SchoolSection section;
  final Color color;
  final bool isExpanded;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isExpanded
              ? color.withValues(alpha: 0.3)
              : AppColors.outlineVariant.withValues(alpha: 0.15),
          width: isExpanded ? 1.5 : 1,
        ),
      ),
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: onTap,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(section.icon, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          section.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.onSurface,
                          ),
                        ),
                        if (section.concepts.isNotEmpty)
                          Text(
                            '${section.concepts.length} concepts',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        if (section.vocabulary.isNotEmpty)
                          Text(
                            '${section.vocabulary.length} vocabulary words',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.onSurfaceVariant,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
          // Content
          if (isExpanded) ...[
            const Divider(height: 1, color: AppColors.outlineVariant),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section content text
                  Text(
                    section.content,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.6,
                    ),
                  ),
                  // Concepts
                  if (section.concepts.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'KEY CONCEPTS',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.concepts.map((c) => ConceptCard(concept: c)),
                  ],
                  // Vocabulary
                  if (section.vocabulary.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'VOCABULARY',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...section.vocabulary.map((v) => VocabCard(vocab: v)),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual concept card
class ConceptCard extends StatelessWidget {
  const ConceptCard({super.key, required this.concept});

  final SchoolConcept concept;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('📌', style: TextStyle(fontSize: 14)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      concept.term,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      concept.definition,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppColors.onSurface,
                        height: 1.5,
                      ),
                    ),
                    if (concept.example.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('💡', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                concept.example,
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: AppColors.onSurfaceVariant,
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
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Vocabulary word card
class VocabCard extends StatelessWidget {
  const VocabCard({super.key, required this.vocab});

  final VocabWord vocab;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      vocab.word,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.tertiaryContainer.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        vocab.partOfSpeech,
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: AppColors.tertiary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  vocab.definition,
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
    );
  }
}

/// Quiz question card for school lessons
class SchoolQuizCard extends StatelessWidget {
  const SchoolQuizCard({
    super.key,
    required this.question,
    required this.color,
    this.selectedAnswer,
    this.showResult = false,
    this.onAnswerSelected,
  });

  final QuizQuestion question;
  final Color color;
  final int? selectedAnswer;
  final bool showResult;
  final ValueChanged<int>? onAnswerSelected;

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
          // Question number and text
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [color, color.withValues(alpha: 0.7)]),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${question.id.contains('_') ? question.id.split('_').last : '1'}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
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
          ...question.options.asMap().entries.map(
                (entry) => _buildOption(entry.key, entry.value),
              ),
          // Explanation (shown after submission)
          if (showResult) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selectedAnswer == question.correctIndex
                    ? AppColors.tertiary.withValues(alpha: 0.1)
                    : AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: selectedAnswer == question.correctIndex
                      ? AppColors.tertiary.withValues(alpha: 0.3)
                      : AppColors.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    selectedAnswer == question.correctIndex ? '✅ ' : '📖 ',
                    style: const TextStyle(fontSize: 16),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedAnswer == question.correctIndex
                              ? 'Correct!'
                              : 'Explanation',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: selectedAnswer == question.correctIndex
                                ? AppColors.tertiary
                                : AppColors.error,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          question.explanation,
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
          ],
        ],
      ),
    );
  }

  Widget _buildOption(int index, String option) {
    final isSelected = selectedAnswer == index;
    final isCorrect = question.correctIndex == index;

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
        backgroundColor = AppColors.surfaceContainerHighest.withValues(alpha: 0.3);
        textColor = AppColors.onSurfaceVariant;
      }
    } else {
      borderColor = isSelected
          ? color.withValues(alpha: 0.5)
          : AppColors.outlineVariant.withValues(alpha: 0.2);
      backgroundColor = isSelected
          ? color.withValues(alpha: 0.1)
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
                    ? color
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
              const Icon(
                Icons.error_rounded,
                color: AppColors.error,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

/// Quiz progress indicator
class SchoolQuizProgress extends StatelessWidget {
  const SchoolQuizProgress({
    super.key,
    required this.answeredCount,
    required this.totalCount,
    required this.color,
  });

  final int answeredCount;
  final int totalCount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final progress = totalCount > 0 ? answeredCount / totalCount : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'QUIZ PROGRESS',
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
                  color: color,
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
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}

/// Score result card shown after quiz submission
class SchoolScoreCard extends StatelessWidget {
  const SchoolScoreCard({
    super.key,
    required this.score,
    required this.totalQuestions,
    required this.color,
  });

  final int score;
  final int totalQuestions;
  final Color color;

  double get percentage => totalQuestions > 0 ? (score / totalQuestions) * 100 : 0;

  String get message {
    if (percentage >= 90) return 'Excellent! 🎉';
    if (percentage >= 70) return 'Great job! 👏';
    if (percentage >= 50) return 'Good effort! 💪';
    return 'Keep practicing! 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Text(
            message,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120,
                height: 120,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 10,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${percentage.round()}%',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  Text(
                    '$score/$totalQuestions',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
