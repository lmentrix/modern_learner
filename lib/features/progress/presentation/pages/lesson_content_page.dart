import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/repositories/progress_repository.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart';
import 'package:modern_learner_production/features/progress/service/chapter_content_service.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';
import 'package:modern_learner_production/features/progress/service/roadmap_generation_service.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/content_view.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/error_content.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/generating_content.dart';

class LessonContentPage extends StatefulWidget {
  const LessonContentPage({
    super.key,
    required this.lesson,
    required this.chapter,
    required this.roadmap,
    this.onLessonCompleted,
  });

  final Lesson lesson;
  final Chapter chapter;
  final Roadmap roadmap;

  /// Called after a lesson is marked done so the progress page can
  /// re-apply user progress and unlock the next lessons.
  final VoidCallback? onLessonCompleted;

  @override
  State<LessonContentPage> createState() => _LessonContentPageState();
}

class _LessonContentPageState extends State<LessonContentPage> {
  late Future<LessonContentModel> _contentFuture;
  int _currentVocabIndex = 0;

  // item key = "${exerciseIdx}_${itemIdx}"
  final Map<String, String?> _itemAnswers = {};
  final Map<String, bool?> _itemCorrect = {}; // null = unchecked
  final Map<String, TextEditingController> _fillControllers = {};
  final Map<int, List<String>> _shuffledMatchAnswers = {};

  @override
  void initState() {
    super.initState();
    _contentFuture = _loadContent();
  }

  @override
  void dispose() {
    for (final c in _fillControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  String _itemKey(int exerciseIdx, int itemIdx) => '${exerciseIdx}_$itemIdx';

  List<String> _getShuffledAnswers(int exerciseIdx, PracticeExerciseModel ex) {
    return _shuffledMatchAnswers.putIfAbsent(exerciseIdx, () {
      final answers = ex.items.map((i) => i.answer).toList()..shuffle();
      return answers;
    });
  }

  TextEditingController _getController(String key) {
    return _fillControllers.putIfAbsent(key, () => TextEditingController());
  }

  void _onSelectAnswer(String key, String answer, String correctAnswer) {
    setState(() {
      _itemAnswers[key] = answer;
      _itemCorrect[key] =
          answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    });
  }

  void _onCheckFillBlank(String key, String correctAnswer) {
    final entered = _fillControllers[key]?.text ?? '';
    setState(() {
      _itemCorrect[key] =
          entered.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    });
  }

  Lesson? get _nextLesson {
    final idx = widget.chapter.lessons.indexWhere(
      (l) => l.id == widget.lesson.id,
    );
    if (idx == -1 || idx >= widget.chapter.lessons.length - 1) return null;
    return widget.chapter.lessons[idx + 1];
  }

  Future<void> _handleMarkDone() async {
    try {
      await CompleteLesson(getIt<ProgressRepository>())(widget.lesson.id);
    } catch (_) {}

    // Notify the progress page to reload the roadmap so newly unlocked
    // lessons become accessible (chapters 2, 3, … unlock as chapters complete).
    widget.onLessonCompleted?.call();

    if (!mounted) return;

    final next = _nextLesson;
    if (next != null) {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => LessonContentPage(
            lesson: next,
            chapter: widget.chapter,
            roadmap: widget.roadmap,
            onLessonCompleted: widget.onLessonCompleted,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  Future<LessonContentModel> _loadContent() async {
    // Step 1 result: retrieve the raw roadmap JSON from cache.
    final roadmapJson = getIt<RoadmapGenerationService>()
        .getCachedRoadmapJsonById(widget.roadmap.id);
    if (roadmapJson == null) {
      throw Exception(
        'Roadmap data not found. Please go back and reload the roadmap.',
      );
    }

    // Step 2: generate chapter content.
    final chapterContent = await getIt<ChapterContentService>()
        .generateChapterContent(
          roadmap: roadmapJson,
          chapterNumber: widget.chapter.chapterNumber,
        );

    // Step 3: generate lesson content (lessonNumber is 1-based).
    final lessonNumber =
        widget.chapter.lessons.indexWhere((l) => l.id == widget.lesson.id) + 1;

    return getIt<LessonContentService>().generateContent(
      lessonId: widget.lesson.id,
      roadmap: roadmapJson,
      chapterContent: chapterContent,
      lessonNumber: lessonNumber,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: FutureBuilder<LessonContentModel>(
        future: _contentFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return GeneratingContent(
              lesson: widget.lesson,
              chapter: widget.chapter,
            );
          }
          if (snapshot.hasError) {
            return ErrorContent(
              error: snapshot.error.toString(),
              onRetry: () {
                setState(() {
                  _contentFuture = _loadContent();
                });
              },
              onBack: () => Navigator.pop(context),
            );
          }
          return ContentView(
            lesson: widget.lesson,
            chapter: widget.chapter,
            roadmap: widget.roadmap,
            content: snapshot.data!,
            currentVocabIndex: _currentVocabIndex,
            nextLesson: _nextLesson,
            itemAnswers: _itemAnswers,
            itemCorrect: _itemCorrect,
            onVocabNext: () {
              final max = snapshot.data!.vocabularyItems.length - 1;
              if (_currentVocabIndex < max) {
                setState(() => _currentVocabIndex++);
              }
            },
            onVocabPrev: () {
              if (_currentVocabIndex > 0) {
                setState(() => _currentVocabIndex--);
              }
            },
            onSelectAnswer: _onSelectAnswer,
            onCheckFillBlank: _onCheckFillBlank,
            getShuffledAnswers: _getShuffledAnswers,
            getController: _getController,
            itemKey: _itemKey,
            onMarkDone: _handleMarkDone,
          );
        },
      ),
    );
  }
}
