import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/service/lesson_content_service.dart';

class LessonContentPage extends StatefulWidget {
  const LessonContentPage({
    super.key,
    required this.lesson,
    required this.chapter,
    required this.roadmap,
  });

  final Lesson lesson;
  final Chapter chapter;
  final Roadmap roadmap;

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
      _itemCorrect[key] = answer.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    });
  }

  void _onCheckFillBlank(String key, String correctAnswer) {
    final entered = _fillControllers[key]?.text ?? '';
    setState(() {
      _itemCorrect[key] = entered.trim().toLowerCase() == correctAnswer.trim().toLowerCase();
    });
  }

  Future<LessonContentModel> _loadContent() async {
    String nativeLanguage = 'English';
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('native_language')
            .eq('id', userId)
            .single();
        nativeLanguage = row['native_language'] as String? ?? nativeLanguage;
      }
    } catch (_) {}

    return getIt<LessonContentService>().generateContent(
      lessonId: widget.lesson.id,
      topic: widget.roadmap.title,
      language: widget.roadmap.targetLanguage,
      level: widget.roadmap.level,
      chapterTitle: widget.chapter.title,
      lessonTitle: widget.lesson.title,
      lessonType: widget.lesson.type.name,
      lessonDescription: widget.lesson.description,
      nativeLanguage: nativeLanguage,
      chapterId: widget.chapter.id,
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
            return _GeneratingContent(lesson: widget.lesson, chapter: widget.chapter);
          }
          if (snapshot.hasError) {
            return _ErrorContent(
              error: snapshot.error.toString(),
              onRetry: () => setState(() => _contentFuture = _loadContent()),
              onBack: () => Navigator.pop(context),
            );
          }
          return _ContentView(
            lesson: widget.lesson,
            chapter: widget.chapter,
            roadmap: widget.roadmap,
            content: snapshot.data!,
            currentVocabIndex: _currentVocabIndex,
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
          );
        },
      ),
    );
  }
}

// ── Generating state ─────────────────────────────────────────────────────────

class _GeneratingContent extends StatefulWidget {
  const _GeneratingContent({required this.lesson, required this.chapter});
  final Lesson lesson;
  final Chapter chapter;

  @override
  State<_GeneratingContent> createState() => _GeneratingContentState();
}

class _GeneratingContentState extends State<_GeneratingContent>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.all(16),
            child: Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: AppColors.onSurface, size: 20),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedBuilder(
                    animation: _ctrl,
                    builder: (_, _) => Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: SweepGradient(
                          startAngle: _ctrl.value * 6.28,
                          colors: const [
                            AppColors.primary,
                            AppColors.secondary,
                            AppColors.tertiary,
                            AppColors.primary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text('✨', style: TextStyle(fontSize: 28)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Generating lesson content',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '"${widget.lesson.title}"',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.chapter.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: 180,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 3,
                      borderRadius: BorderRadius.circular(2),
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

// ── Error state ──────────────────────────────────────────────────────────────

class _ErrorContent extends StatelessWidget {
  const _ErrorContent({
    required this.error,
    required this.onRetry,
    required this.onBack,
  });
  final String error;
  final VoidCallback onRetry;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onBack,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.arrow_back_rounded,
                    color: AppColors.onSurface, size: 20),
              ),
            ),
            const Spacer(),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.error_outline_rounded,
                        size: 32, color: AppColors.error),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to generate content',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error,
                    style: GoogleFonts.inter(
                        fontSize: 12, color: AppColors.onSurfaceVariant),
                    textAlign: TextAlign.center,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    label: const Text('Try again'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ── Main content view ─────────────────────────────────────────────────────────

class _ContentView extends StatelessWidget {
  const _ContentView({
    required this.lesson,
    required this.chapter,
    required this.roadmap,
    required this.content,
    required this.currentVocabIndex,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.onVocabNext,
    required this.onVocabPrev,
    required this.onSelectAnswer,
    required this.onCheckFillBlank,
    required this.getShuffledAnswers,
    required this.getController,
    required this.itemKey,
  });

  final Lesson lesson;
  final Chapter chapter;
  final Roadmap roadmap;
  final LessonContentModel content;
  final int currentVocabIndex;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final VoidCallback onVocabNext;
  final VoidCallback onVocabPrev;
  final Function(String key, String answer, String correctAnswer) onSelectAnswer;
  final Function(String key, String correctAnswer) onCheckFillBlank;
  final List<String> Function(int exerciseIdx, PracticeExerciseModel) getShuffledAnswers;
  final TextEditingController Function(String key) getController;
  final String Function(int exerciseIdx, int itemIdx) itemKey;

  Color get _typeColor {
    switch (lesson.type) {
      case LessonType.vocabulary:
        return AppColors.primary;
      case LessonType.grammar:
        return AppColors.secondary;
      case LessonType.exercise:
        return AppColors.tertiary;
      case LessonType.listening:
        return AppColors.secondary;
      case LessonType.reading:
        return const Color(0xFFFFB347);
      case LessonType.conversation:
        return AppColors.tertiary;
    }
  }

  String get _typeEmoji {
    switch (lesson.type) {
      case LessonType.vocabulary:
        return '📚';
      case LessonType.grammar:
        return '📝';
      case LessonType.exercise:
        return '💪';
      case LessonType.listening:
        return '🎧';
      case LessonType.reading:
        return '📖';
      case LessonType.conversation:
        return '💬';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── App bar ────────────────────────────────────────────────────────
        SliverAppBar(
          backgroundColor: AppColors.surface,
          expandedHeight: 200,
          pinned: true,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_back_rounded,
                  color: AppColors.onSurface, size: 20),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _LessonHeader(
              lesson: lesson,
              chapter: chapter,
              roadmap: roadmap,
              typeColor: _typeColor,
              typeEmoji: _typeEmoji,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: AppColors.outlineVariant.withValues(alpha: 0.2),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── AI badge ──
              _AiBadge(lessonType: content.lessonType),
              const SizedBox(height: 16),

              // ── Introduction ──
              _IntroductionCard(text: content.introduction),
              const SizedBox(height: 20),

              // ── Vocabulary section ──
              if (content.vocabularyItems.isNotEmpty) ...[
                const _SectionLabel(label: 'VOCABULARY', emoji: '📖'),
                const SizedBox(height: 12),
                _VocabularyCarousel(
                  items: content.vocabularyItems,
                  currentIndex: currentVocabIndex,
                  onNext: onVocabNext,
                  onPrev: onVocabPrev,
                  typeColor: _typeColor,
                ),
                const SizedBox(height: 24),
              ],

              // ── Practice exercises ──
              if (content.practiceExercises.isNotEmpty) ...[
                const _SectionLabel(label: 'PRACTICE', emoji: '🎯'),
                const SizedBox(height: 12),
                ...content.practiceExercises.asMap().entries.map(
                      (e) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ExerciseCard(
                          exerciseIdx: e.key,
                          exercise: e.value,
                          itemAnswers: itemAnswers,
                          itemCorrect: itemCorrect,
                          typeColor: _typeColor,
                          onSelectAnswer: onSelectAnswer,
                          onCheckFillBlank: onCheckFillBlank,
                          getShuffledAnswers: getShuffledAnswers,
                          getController: getController,
                          itemKey: itemKey,
                        ),
                      ),
                    ),
                const SizedBox(height: 12),
              ],

              // ── Summary ──
              if (content.summary.isNotEmpty) ...[
                const _SectionLabel(label: 'SUMMARY', emoji: '✅'),
                const SizedBox(height: 12),
                _SummaryCard(text: content.summary, typeColor: _typeColor),
                const SizedBox(height: 24),
              ],

              // ── XP reward badge ──
              _XpRewardCard(xp: lesson.xpReward, typeColor: _typeColor),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Header ───────────────────────────────────────────────────────────────────

class _LessonHeader extends StatelessWidget {
  const _LessonHeader({
    required this.lesson,
    required this.chapter,
    required this.roadmap,
    required this.typeColor,
    required this.typeEmoji,
  });
  final Lesson lesson;
  final Chapter chapter;
  final Roadmap roadmap;
  final Color typeColor;
  final String typeEmoji;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 56,
        left: 20,
        right: 20,
        bottom: 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.15),
            AppColors.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Breadcrumb
          Row(
            children: [
              Text(
                chapter.icon,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${chapter.title}  ·  Ch. ${chapter.chapterNumber}',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Lesson title
          Text(
            lesson.title,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(typeEmoji, style: const TextStyle(fontSize: 11)),
                    const SizedBox(width: 4),
                    Text(
                      lesson.type.name.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: typeColor,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 12, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      '+${lesson.xpReward} XP',
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
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

// ── Reusable widgets ──────────────────────────────────────────────────────────

class _AiBadge extends StatelessWidget {
  const _AiBadge({required this.lessonType});
  final String lessonType;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('✨', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 6),
          Text(
            'AI-generated $lessonType lesson',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label, required this.emoji});
  final String label;
  final String emoji;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 14)),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurfaceVariant,
            letterSpacing: 1.4,
          ),
        ),
      ],
    );
  }
}

class _IntroductionCard extends StatelessWidget {
  const _IntroductionCard({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 14,
          color: AppColors.onSurface,
          height: 1.65,
        ),
      ),
    );
  }
}

// ── Vocabulary carousel ───────────────────────────────────────────────────────

class _VocabularyCarousel extends StatelessWidget {
  const _VocabularyCarousel({
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
                        horizontal: 8, vertical: 3),
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
                      horizontal: 12, vertical: 8),
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

// ── Exercise card (dispatcher) ────────────────────────────────────────────────

class _ExerciseCard extends StatelessWidget {
  const _ExerciseCard({
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
  final Function(String key, String answer, String correctAnswer) onSelectAnswer;
  final Function(String key, String correctAnswer) onCheckFillBlank;
  final List<String> Function(int, PracticeExerciseModel) getShuffledAnswers;
  final TextEditingController Function(String key) getController;
  final String Function(int exerciseIdx, int itemIdx) itemKey;

  @override
  Widget build(BuildContext context) {
    // Count how many items are correctly answered
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
                    fontSize: 11, color: AppColors.onSurfaceVariant),
              ),
              const Spacer(),
              if (allDone)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 14, color: AppColors.tertiary),
                    const SizedBox(width: 4),
                    Text(
                      'Complete',
                      style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              else
                Text(
                  '$correctCount / $totalItems',
                  style: GoogleFonts.inter(
                      fontSize: 11, color: AppColors.onSurfaceVariant),
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
            _MatchExercise(
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
            _FillBlankExercise(
              exerciseIdx: exerciseIdx,
              items: exercise.items,
              itemCorrect: itemCorrect,
              typeColor: typeColor,
              itemKey: itemKey,
              getController: getController,
              onCheck: onCheckFillBlank,
            )
          else
            _SelectCorrectExercise(
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

// ── Match exercise ─────────────────────────────────────────────────────────────
// Shows each term with all shuffled answers as tappable chips.
// Correct tap locks the pair green; wrong tap flashes red and allows retry.

class _MatchExercise extends StatelessWidget {
  const _MatchExercise({
    required this.exerciseIdx,
    required this.items,
    required this.shuffledAnswers,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.onSelect,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final List<String> shuffledAnswers;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final Function(String key, String answer, String correctAnswer) onSelect;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final isCorrect = itemCorrect[key] == true;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question term
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  color: typeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.question,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    if (isCorrect) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_circle_rounded,
                          size: 15, color: AppColors.tertiary),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Answer chips (hidden once correct)
              if (!isCorrect)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: shuffledAnswers.map((answer) {
                    final selected = itemAnswers[key] == answer;
                    final isWrong = selected && itemCorrect[key] == false;
                    return GestureDetector(
                      onTap: () => onSelect(key, answer, item.answer),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 7),
                        decoration: BoxDecoration(
                          color: isWrong
                              ? AppColors.error.withValues(alpha: 0.1)
                              : selected
                                  ? typeColor.withValues(alpha: 0.15)
                                  : AppColors.surfaceContainer,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isWrong
                                ? AppColors.error.withValues(alpha: 0.4)
                                : selected
                                    ? typeColor.withValues(alpha: 0.4)
                                    : AppColors.outlineVariant
                                        .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isWrong) ...[
                              const Icon(Icons.close_rounded,
                                  size: 12, color: AppColors.error),
                              const SizedBox(width: 4),
                            ],
                            Text(
                              answer,
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: isWrong
                                    ? AppColors.error
                                    : selected
                                        ? typeColor
                                        : AppColors.onSurface,
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                // Locked correct answer
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.tertiary.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_rounded,
                          size: 13, color: AppColors.tertiary),
                      const SizedBox(width: 5),
                      Text(
                        item.answer,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: AppColors.tertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Fill-blank exercise ────────────────────────────────────────────────────────
// Shows the question with __ highlighted, a TextField, and a Check button.

class _FillBlankExercise extends StatelessWidget {
  const _FillBlankExercise({
    required this.exerciseIdx,
    required this.items,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.getController,
    required this.onCheck,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final TextEditingController Function(String key) getController;
  final Function(String key, String correctAnswer) onCheck;

  static List<TextSpan> _buildBlankSpans(String question, Color color) {
    final parts = question.split('__');
    if (parts.length <= 1) return [TextSpan(text: question)];
    final spans = <TextSpan>[];
    for (int i = 0; i < parts.length; i++) {
      if (parts[i].isNotEmpty) spans.add(TextSpan(text: parts[i]));
      if (i < parts.length - 1) {
        spans.add(TextSpan(
          text: ' _____ ',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.underline,
            decorationColor: color,
          ),
        ));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final controller = getController(key);
        final correctness = itemCorrect[key];
        final isCorrect = correctness == true;
        final isWrong = correctness == false;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Question with highlighted blank
              RichText(
                text: TextSpan(
                  style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurface,
                      height: 1.5),
                  children: _buildBlankSpans(item.question, typeColor),
                ),
              ),
              const SizedBox(height: 10),

              // Input row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,
                      enabled: !isCorrect,
                      onSubmitted: (_) => onCheck(key, item.answer),
                      style: GoogleFonts.inter(
                          fontSize: 14, color: AppColors.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Type your answer…',
                        hintStyle: GoogleFonts.inter(
                            fontSize: 14,
                            color: AppColors.onSurfaceVariant
                                .withValues(alpha: 0.5)),
                        filled: true,
                        fillColor: isCorrect
                            ? AppColors.tertiary.withValues(alpha: 0.08)
                            : isWrong
                                ? AppColors.error.withValues(alpha: 0.08)
                                : AppColors.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isWrong
                                ? AppColors.error.withValues(alpha: 0.4)
                                : AppColors.outlineVariant
                                    .withValues(alpha: 0.3),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                              color: typeColor.withValues(alpha: 0.5)),
                        ),
                        suffixIcon: isCorrect
                            ? const Icon(Icons.check_circle_rounded,
                                color: AppColors.tertiary, size: 18)
                            : isWrong
                                ? const Icon(Icons.cancel_rounded,
                                    color: AppColors.error, size: 18)
                                : null,
                      ),
                    ),
                  ),
                  if (!isCorrect) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onCheck(key, item.answer),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: typeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Check',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              // Wrong feedback with correct answer
              if (isWrong) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 13, color: AppColors.error),
                      const SizedBox(width: 6),
                      Text(
                        'Correct answer: ',
                        style: GoogleFonts.inter(
                            fontSize: 12, color: AppColors.error),
                      ),
                      Text(
                        item.answer,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Correct feedback
              if (isCorrect) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        size: 13, color: AppColors.tertiary),
                    const SizedBox(width: 5),
                    Text(
                      'Correct!',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

// ── Select-correct exercise ────────────────────────────────────────────────────
// Parses options from the question string (split by " | ").
// Displays as tappable option cards; correct/incorrect shown instantly.

class _SelectCorrectExercise extends StatelessWidget {
  const _SelectCorrectExercise({
    required this.exerciseIdx,
    required this.items,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.typeColor,
    required this.itemKey,
    required this.onSelect,
  });

  final int exerciseIdx;
  final List<ExerciseItemModel> items;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final Color typeColor;
  final String Function(int, int) itemKey;
  final Function(String key, String answer, String correctAnswer) onSelect;

  static List<String> _parseOptions(String question) =>
      question.split(' | ').map((s) => s.trim()).toList();

  // Extracts the leading key from an option like "A: some text" → "A"
  static String _optionKey(String option) {
    final m = RegExp(r'^([A-Z]):').firstMatch(option.trim());
    return m?.group(1) ?? option.trim();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((e) {
        final key = itemKey(exerciseIdx, e.key);
        final item = e.value;
        final options = _parseOptions(item.question);
        final selectedKey = itemAnswers[key];
        final correctness = itemCorrect[key];
        final isAnswered = correctness != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: options.map((option) {
              final optKey = _optionKey(option);
              final isSelected = selectedKey == optKey;
              final isThisCorrect = optKey == item.answer.trim();
              final isThisWrong = isSelected && correctness == false;
              final showCorrect = isAnswered && isThisCorrect;

              Color? bgColor;
              Color? borderColor;
              Color textColor = AppColors.onSurface;
              Widget? trailingIcon;

              if (showCorrect) {
                bgColor = AppColors.tertiary.withValues(alpha: 0.1);
                borderColor = AppColors.tertiary.withValues(alpha: 0.4);
                textColor = AppColors.tertiary;
                trailingIcon = const Icon(Icons.check_circle_rounded,
                    size: 16, color: AppColors.tertiary);
              } else if (isThisWrong) {
                bgColor = AppColors.error.withValues(alpha: 0.08);
                borderColor = AppColors.error.withValues(alpha: 0.35);
                textColor = AppColors.error;
                trailingIcon = const Icon(Icons.cancel_rounded,
                    size: 16, color: AppColors.error);
              } else if (isSelected) {
                bgColor = typeColor.withValues(alpha: 0.1);
                borderColor = typeColor.withValues(alpha: 0.35);
                textColor = typeColor;
              } else {
                bgColor = AppColors.surfaceContainer;
                borderColor = AppColors.outlineVariant.withValues(alpha: 0.3);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: GestureDetector(
                  onTap: isAnswered && correctness == true
                      ? null
                      : () => onSelect(key, optKey, item.answer.trim()),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 11),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: borderColor),
                    ),
                    child: Row(
                      children: [
                        // Option key badge
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: showCorrect
                                ? AppColors.tertiary.withValues(alpha: 0.2)
                                : isThisWrong
                                    ? AppColors.error.withValues(alpha: 0.15)
                                    : typeColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              optKey,
                              style: GoogleFonts.inter(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: showCorrect
                                    ? AppColors.tertiary
                                    : isThisWrong
                                        ? AppColors.error
                                        : typeColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            // Strip the leading "A: " key from display
                            option.replaceFirst(
                                RegExp(r'^[A-Z]:\s*'), ''),
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: textColor,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              height: 1.4,
                            ),
                          ),
                        ),
                        if (trailingIcon != null) ...[
                          const SizedBox(width: 8),
                          trailingIcon,
                        ],
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}

// ── Summary card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.text, required this.typeColor});
  final String text;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            typeColor.withValues(alpha: 0.1),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: typeColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.onSurface,
          height: 1.65,
        ),
      ),
    );
  }
}

// ── XP reward card ────────────────────────────────────────────────────────────

class _XpRewardCard extends StatelessWidget {
  const _XpRewardCard({required this.xp, required this.typeColor});
  final int xp;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.15),
            AppColors.surfaceContainerHigh,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
            ),
            child: const Center(
              child: Icon(Icons.star_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Complete to earn',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '+$xp XP',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              'Mark done',
              style: GoogleFonts.inter(
                  fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
