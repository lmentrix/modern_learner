import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/fill_blank_exercise.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/match_exercise.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/select_correct_exercise.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({
    super.key,
    required this.exerciseIdx,
    required this.exercise,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.typeColor,
    required this.onSelectAnswer,
    required this.onCheckFillBlank,
    required this.getShuffledAnswers,
    required this.getController,
    required this.itemKey,
  });

  final int exerciseIdx;
  final PracticeExerciseModel exercise;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final Function(String key, String answer, String correctAnswer)
  onSelectAnswer;
  final Function(String key, String correctAnswer) onCheckFillBlank;
  final List<String> Function(int, PracticeExerciseModel) getShuffledAnswers;
  final TextEditingController Function(String key) getController;
  final String Function(int exerciseIdx, int itemIdx) itemKey;

  @override
  Widget build(BuildContext context) {
    final totalItems = exercise.items.length;
    final correctCount = exercise.items.asMap().entries.where((e) {
      return itemCorrect[itemKey(exerciseIdx, e.key)] == true;
    }).length;
    final allDone = correctCount == totalItems;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: allDone
              ? AppColors.tertiary.withValues(alpha: 0.35)
              : AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Type badge + number ──
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  exercise.type.toUpperCase().replaceAll('_', ' '),
                  style: GoogleFonts.inter(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: typeColor,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Exercise ${exerciseIdx + 1}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              const Spacer(),
              if (allDone)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 14,
                      color: AppColors.tertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Complete',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.tertiary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  '$correctCount / $totalItems',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // ── Instruction ──
          Text(
            exercise.instruction,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // ── Interactive content per type ──
          if (exercise.type == 'match')
            MatchExercise(
              exerciseIdx: exerciseIdx,
              items: exercise.items,
              shuffledAnswers: getShuffledAnswers(exerciseIdx, exercise),
              itemAnswers: itemAnswers,
              itemCorrect: itemCorrect,
              typeColor: typeColor,
              itemKey: itemKey,
              onSelect: onSelectAnswer,
            )
          else if (exercise.type == 'fill_blank')
            FillBlankExercise(
              exerciseIdx: exerciseIdx,
              items: exercise.items,
              itemCorrect: itemCorrect,
              typeColor: typeColor,
              itemKey: itemKey,
              getController: getController,
              onCheck: onCheckFillBlank,
            )
          else
            SelectCorrectExercise(
              exerciseIdx: exerciseIdx,
              items: exercise.items,
              itemAnswers: itemAnswers,
              itemCorrect: itemCorrect,
              typeColor: typeColor,
              itemKey: itemKey,
              onSelect: onSelectAnswer,
            ),
        ],
      ),
    );
  }
}
