import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:modern_learner_production/core/router/app_router.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/exercise/data/exercise_bank.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_answer_section.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_completion_dialog.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_footer.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_header.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_progress_bar.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_question_card.dart';

class ExercisePage extends StatefulWidget {
  const ExercisePage({
    super.key,
    required this.lessonType,
    required this.title,
    required this.sectionTitle,
    required this.accentColor,
    required this.emoji,
  });

  final LessonType lessonType;
  final String title;
  final String sectionTitle;
  final Color accentColor;
  final String emoji;

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;

  late final List<Exercise> _exercises;

  Exercise get _currentExercise => _exercises[_currentExerciseIndex];

  @override
  void initState() {
    super.initState();
    _exercises = buildExercises(widget.lessonType);
  }

  void _checkAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      _isCorrect = _evaluateAnswer(answer);

      if (_isCorrect) {
        _correctAnswers++;
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextExercise();
      }
    });
  }

  bool _evaluateAnswer(String answer) {
    final correct = _currentExercise.correctAnswer?.toLowerCase();

    if (correct == null) {
      return true;
    }

    return answer.toLowerCase() == correct ||
        answer.toLowerCase().contains(correct) ||
        correct == 'speech recognition' ||
        correct == 'written response';
  }

  void _nextExercise() {
    if (_currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _selectedAnswer = null;
        _answered = false;
        _isCorrect = false;
      });
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ExerciseCompletionDialog(
        accentColor: widget.accentColor,
        totalQuestions: _exercises.length,
        correctAnswers: _correctAnswers,
        onContinue: () {
          Navigator.of(context, rootNavigator: true).pop();
          Navigator.of(context, rootNavigator: true).pop();
          context.go(Routes.progress);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            ExerciseHeader(
              title: widget.title,
              sectionTitle: widget.sectionTitle,
              accentColor: widget.accentColor,
              correctAnswers: _correctAnswers,
              onClose: () => Navigator.pop(context),
            ),
            ExerciseProgressBar(
              currentIndex: _currentExerciseIndex,
              totalExercises: _exercises.length,
              accentColor: widget.accentColor,
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ExerciseQuestionCard(
                      exercise: _currentExercise,
                      accentColor: widget.accentColor,
                      emoji: widget.emoji,
                    ),
                    const SizedBox(height: 24),
                    ExerciseAnswerSection(
                      exercise: _currentExercise,
                      accentColor: widget.accentColor,
                      selectedAnswer: _selectedAnswer,
                      answered: _answered,
                      isCorrect: _isCorrect,
                      onCheckAnswer: _checkAnswer,
                    ),
                  ],
                ),
              ),
            ),
            ExerciseFooter(
              answered: _answered,
              accentColor: widget.accentColor,
              isLastExercise: _currentExerciseIndex >= _exercises.length - 1,
              onNext: _nextExercise,
            ),
          ],
        ),
      ),
    );
  }
}
