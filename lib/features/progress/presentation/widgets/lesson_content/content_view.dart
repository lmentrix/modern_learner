import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/data/models/lesson_content_model.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/ai_badge.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/bullet_list_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/context_vocabulary_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/detail_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/dialogue_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/exercise_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/generated_question_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/grammar_example_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/introduction_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/key_phrase_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/lesson_header.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/listening_vocabulary_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/mistake_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/question_answer_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/section_label.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/summary_card.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/vocabulary_carousel.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_content/xp_reward_card.dart';

class ContentView extends StatelessWidget {
  const ContentView({
    super.key,
    required this.lesson,
    required this.chapter,
    required this.roadmap,
    required this.content,
    required this.currentVocabIndex,
    required this.nextLesson,
    required this.itemAnswers,
    required this.itemCorrect,
    required this.onVocabNext,
    required this.onVocabPrev,
    required this.onSelectAnswer,
    required this.onCheckFillBlank,
    required this.getShuffledAnswers,
    required this.getController,
    required this.itemKey,
    required this.onMarkDone,
  });

  final Lesson lesson;
  final Chapter chapter;
  final Roadmap roadmap;
  final LessonContentModel content;
  final int currentVocabIndex;
  final Lesson? nextLesson;
  final Map<String, String?> itemAnswers;
  final Map<String, bool?> itemCorrect;
  final VoidCallback onVocabNext;
  final VoidCallback onVocabPrev;
  final Function(String key, String answer, String correctAnswer) onSelectAnswer;
  final Function(String key, String correctAnswer) onCheckFillBlank;
  final List<String> Function(int exerciseIdx, PracticeExerciseModel)
  getShuffledAnswers;
  final TextEditingController Function(String key) getController;
  final String Function(int exerciseIdx, int itemIdx) itemKey;
  final VoidCallback onMarkDone;

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
              child: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.onSurface,
                size: 20,
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: LessonHeader(
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
              AiBadge(lessonType: content.lessonType),
              const SizedBox(height: 16),

              // ── Introduction ──
              if (content.title.isNotEmpty) ...[
                DetailCard(
                  title: content.title,
                  body: lesson.description,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],
              if (content.introduction.isNotEmpty) ...[
                IntroductionCard(text: content.introduction),
                const SizedBox(height: 20),
              ],

              if (content.explanation.isNotEmpty) ...[
                const SectionLabel(label: 'EXPLANATION', emoji: '🧠'),
                const SizedBox(height: 12),
                DetailCard(
                  title: content.formula.isNotEmpty
                      ? content.formula
                      : 'How it works',
                  body: content.explanation,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              // ── Vocabulary section ──
              if (content.vocabularyItems.isNotEmpty) ...[
                const SectionLabel(label: 'VOCABULARY', emoji: '📖'),
                const SizedBox(height: 12),
                VocabularyCarousel(
                  items: content.vocabularyItems,
                  currentIndex: currentVocabIndex,
                  onNext: onVocabNext,
                  onPrev: onVocabPrev,
                  typeColor: _typeColor,
                ),
                const SizedBox(height: 24),
              ],

              if (content.grammarExamples.isNotEmpty) ...[
                const SectionLabel(label: 'EXAMPLES', emoji: '🧩'),
                const SizedBox(height: 12),
                ...content.grammarExamples.map(
                  (example) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GrammarExampleCard(
                      example: example,
                      typeColor: _typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.commonMistakes.isNotEmpty) ...[
                const SectionLabel(label: 'COMMON MISTAKES', emoji: '⚠️'),
                const SizedBox(height: 12),
                ...content.commonMistakes.map(
                  (mistake) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: MistakeCard(mistake: mistake),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.keyPhrases.isNotEmpty) ...[
                const SectionLabel(label: 'KEY PHRASES', emoji: '💬'),
                const SizedBox(height: 12),
                ...content.keyPhrases.map(
                  (phrase) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: KeyPhraseCard(
                      phrase: phrase,
                      typeColor: _typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.dialogue.isNotEmpty) ...[
                const SectionLabel(label: 'DIALOGUE', emoji: '🗣️'),
                const SizedBox(height: 12),
                DialogueCard(lines: content.dialogue, typeColor: _typeColor),
                const SizedBox(height: 24),
              ],

              if (content.preReadingQuestions.isNotEmpty) ...[
                const SectionLabel(label: 'BEFORE YOU READ', emoji: '🔎'),
                const SizedBox(height: 12),
                BulletListCard(
                  items: content.preReadingQuestions,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.passage.isNotEmpty) ...[
                const SectionLabel(label: 'PASSAGE', emoji: '📄'),
                const SizedBox(height: 12),
                DetailCard(
                  title: 'Read',
                  body: content.passage,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 12),
              ],

              if (content.passageTranslation.isNotEmpty) ...[
                DetailCard(
                  title: 'Translation',
                  body: content.passageTranslation,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.readingVocabulary.isNotEmpty) ...[
                const SectionLabel(label: 'PASSAGE VOCABULARY', emoji: '🧾'),
                const SizedBox(height: 12),
                ...content.readingVocabulary.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ContextVocabularyCard(item: item),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.preListeningQuestions.isNotEmpty) ...[
                const SectionLabel(label: 'BEFORE YOU LISTEN', emoji: '🎧'),
                const SizedBox(height: 12),
                BulletListCard(
                  items: content.preListeningQuestions,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.script.isNotEmpty) ...[
                const SectionLabel(label: 'SCRIPT', emoji: '🎙️'),
                const SizedBox(height: 12),
                DetailCard(
                  title: 'Listen and follow',
                  body: content.script,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 12),
              ],

              if (content.scriptTranslation.isNotEmpty) ...[
                DetailCard(
                  title: 'Translation',
                  body: content.scriptTranslation,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.listeningVocabulary.isNotEmpty) ...[
                const SectionLabel(label: 'LISTENING VOCABULARY', emoji: '📝'),
                const SizedBox(height: 12),
                ...content.listeningVocabulary.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ListeningVocabularyCard(item: item),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.instruction.isNotEmpty) ...[
                const SectionLabel(label: 'INSTRUCTIONS', emoji: '🧭'),
                const SizedBox(height: 12),
                DetailCard(
                  title: 'What to do',
                  body: content.instruction,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.reviewKeyPoints.isNotEmpty) ...[
                const SectionLabel(label: 'REVIEW', emoji: '🔁'),
                const SizedBox(height: 12),
                BulletListCard(
                  items: content.reviewKeyPoints,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 12),
              ],

              if (content.reviewExamples.isNotEmpty) ...[
                ...content.reviewExamples.map(
                  (example) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DetailCard(
                      title: example.example,
                      body: example.explanation,
                      accentColor: _typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // ── Practice exercises ──
              if (content.practiceExercises.isNotEmpty) ...[
                const SectionLabel(label: 'PRACTICE', emoji: '🎯'),
                const SizedBox(height: 12),
                ...content.practiceExercises.asMap().entries.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: ExerciseCard(
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

              if (content.comprehensionQuestions.isNotEmpty) ...[
                const SectionLabel(label: 'CHECK UNDERSTANDING', emoji: '❓'),
                const SizedBox(height: 12),
                ...content.comprehensionQuestions.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: QuestionAnswerCard(
                      item: item,
                      typeColor: _typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.generatedQuestions.isNotEmpty) ...[
                const SectionLabel(label: 'QUESTIONS', emoji: '📝'),
                const SizedBox(height: 12),
                ...content.generatedQuestions.map(
                  (question) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: GeneratedQuestionCard(
                      question: question,
                      typeColor: _typeColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              if (content.rolePlaySuggestions.isNotEmpty) ...[
                const SectionLabel(label: 'ROLE PLAY', emoji: '🎭'),
                const SizedBox(height: 12),
                BulletListCard(
                  items: content.rolePlaySuggestions,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              if (content.discussionQuestions.isNotEmpty) ...[
                const SectionLabel(label: 'DISCUSS', emoji: '🗨️'),
                const SizedBox(height: 12),
                BulletListCard(
                  items: content.discussionQuestions,
                  accentColor: _typeColor,
                ),
                const SizedBox(height: 20),
              ],

              // ── Summary ──
              if (content.summary.isNotEmpty) ...[
                const SectionLabel(label: 'SUMMARY', emoji: '✅'),
                const SizedBox(height: 12),
                SummaryCard(text: content.summary, typeColor: _typeColor),
                const SizedBox(height: 24),
              ],

              // ── XP reward badge ──
              XpRewardCard(
                xp: lesson.xpReward,
                typeColor: _typeColor,
                nextLesson: nextLesson,
                onMarkDone: onMarkDone,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}
