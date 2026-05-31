import 'dart:async';
import 'dart:convert';

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
import 'package:modern_learner_production/features/profile/view/widgets/learning_activity_scope.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  static const _progressCachePrefix = 'lesson_exercise_progress_v1';

  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;

  late final List<Exercise> _exercises;

  Exercise get _currentExercise => _exercises[_currentExerciseIndex];

  String get _progressCacheKey => [
    _progressCachePrefix,
    widget.lessonType.name,
    widget.title,
    widget.sectionTitle,
  ].join('::');

  @override
  void initState() {
    super.initState();
    _exercises = buildExercises(widget.lessonType);
    unawaited(_restoreProgress());
  }

  Future<void> _restoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressCacheKey);
    if (raw == null) return;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || !mounted) return;
      if (_exercises.isEmpty) return;
      final index = (decoded['currentExerciseIndex'] as num?)?.toInt() ?? 0;
      setState(() {
        _currentExerciseIndex = index.clamp(0, _exercises.length - 1);
        _correctAnswers = ((decoded['correctAnswers'] as num?)?.toInt() ?? 0)
            .clamp(0, _exercises.length);
        _selectedAnswer = decoded['selectedAnswer']?.toString();
        _answered = decoded['answered'] == true;
        _isCorrect = decoded['isCorrect'] == true;
      });
    } catch (_) {
      await prefs.remove(_progressCacheKey);
    }
  }

  Future<void> _saveProgress() async {
    final payload = <String, dynamic>{
      'currentExerciseIndex': _currentExerciseIndex,
      'correctAnswers': _correctAnswers,
      'selectedAnswer': _selectedAnswer,
      'answered': _answered,
      'isCorrect': _isCorrect,
      'updatedAt': DateTime.now().toIso8601String(),
    };
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressCacheKey, jsonEncode(payload));
  }

  Future<void> _clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressCacheKey);
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
    unawaited(_saveProgress());

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
      unawaited(_saveProgress());
    } else {
      _showCompletion();
    }
  }

  void _showCompletion() {
    unawaited(_clearProgress());
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
    if (_exercises.isEmpty) {
      return const Scaffold(
        backgroundColor: AppColors.surface,
        body: SafeArea(child: Center(child: Text('No exercises available'))),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LearningActivityScope(
        child: SafeArea(
          child: SizedBox.expand(
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
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverPadding(
                        padding: const EdgeInsets.all(20),
                        sliver: SliverToBoxAdapter(
                          child: ExerciseQuestionCard(
                            exercise: _currentExercise,
                            accentColor: widget.accentColor,
                            emoji: widget.emoji,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 4)),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        sliver: SliverToBoxAdapter(
                          child: ExerciseAnswerSection(
                            exercise: _currentExercise,
                            accentColor: widget.accentColor,
                            selectedAnswer: _selectedAnswer,
                            answered: _answered,
                            isCorrect: _isCorrect,
                            onCheckAnswer: _checkAnswer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ExerciseFooter(
                  answered: _answered,
                  accentColor: widget.accentColor,
                  isLastExercise:
                      _currentExerciseIndex >= _exercises.length - 1,
                  onNext: _nextExercise,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
