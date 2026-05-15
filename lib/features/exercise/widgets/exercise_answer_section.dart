import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

import '../models/exercise.dart';
import 'exercise_answer_option.dart';
import 'exercise_hint.dart';

class ExerciseAnswerSection extends StatelessWidget {
  const ExerciseAnswerSection({
    super.key,
    required this.exercise,
    required this.accentColor,
    required this.selectedAnswer,
    required this.answered,
    required this.isCorrect,
    required this.onCheckAnswer,
  });

  final Exercise exercise;
  final Color accentColor;
  final String? selectedAnswer;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<String> onCheckAnswer;

  @override
  Widget build(BuildContext context) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice();
      case ExerciseType.fillBlank:
        return _buildFillBlank();
      case ExerciseType.speaking:
        return _buildSpeaking();
      case ExerciseType.matching:
        return _buildMatching();
      case ExerciseType.trueFalse:
        return _buildTrueFalse();
      case ExerciseType.writing:
        return _buildWriting();
    }
  }

  Widget _buildMultipleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 16),
        ...(exercise.options ?? []).map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExerciseAnswerOption(
              option: option,
              isSelected: selectedAnswer == option,
              isCorrect: answered && option == exercise.correctAnswer,
              isWrong:
                  answered && selectedAnswer == option && option != exercise.correctAnswer,
              onTap: () => onCheckAnswer(option),
              accentColor: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFillBlank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 16),
        TextField(
          enabled: !answered,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
          onSubmitted: onCheckAnswer,
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: answered ? null : () => onCheckAnswer('submitted'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              answered ? 'Submitted' : 'Check Answer',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeaking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                accentColor.withValues(alpha: 0.2),
                accentColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accentColor.withValues(alpha: 0.2),
                  boxShadow: answered
                      ? [
                          BoxShadow(
                            color: (isCorrect ? Colors.green : Colors.red)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: accentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: Icon(
                  answered
                      ? (isCorrect ? Icons.check_rounded : Icons.close_rounded)
                      : Icons.mic_rounded,
                  size: 40,
                  color: answered
                      ? (isCorrect ? Colors.green : Colors.red)
                      : accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                answered
                    ? (isCorrect ? 'Great pronunciation!' : 'Keep practicing!')
                    : 'Tap to speak',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: answered ? null : () => onCheckAnswer('spoken'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              answered ? 'Completed' : 'Practice',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatching() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 16),
        ...(exercise.pairs ?? []).map(
          (pair) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      pair.values.first,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    size: 18,
                    color: AppColors.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pair.values.last,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: accentColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: () => onCheckAnswer('matched'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTrueFalse() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ExerciseAnswerOption(
                option: 'True',
                isSelected: selectedAnswer == 'true',
                isCorrect: answered && exercise.correctAnswer == 'true',
                isWrong:
                    answered && selectedAnswer == 'true' && exercise.correctAnswer != 'true',
                onTap: () => onCheckAnswer('true'),
                accentColor: accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ExerciseAnswerOption(
                option: 'False',
                isSelected: selectedAnswer == 'false',
                isCorrect: answered && exercise.correctAnswer == 'false',
                isWrong:
                    answered && selectedAnswer == 'false' && exercise.correctAnswer != 'false',
                onTap: () => onCheckAnswer('false'),
                accentColor: accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWriting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (exercise.hint != null && !answered) ExerciseHint(hint: exercise.hint!),
        const SizedBox(height: 16),
        TextField(
          enabled: !answered,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: accentColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: answered ? null : () => onCheckAnswer('written'),
            style: FilledButton.styleFrom(
              backgroundColor: accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              answered ? 'Submitted' : 'Submit',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
