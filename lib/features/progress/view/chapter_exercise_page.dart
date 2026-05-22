import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';

class ChapterExercisePage extends StatefulWidget {
  const ChapterExercisePage({super.key, required this.args});

  final ChapterExercisePageArgs args;

  @override
  State<ChapterExercisePage> createState() => _ChapterExercisePageState();
}

class _ChapterExercisePageState extends State<ChapterExercisePage> {
  late Future<ChapterExerciseResponseModel> _exerciseFuture;
  final Map<String, String> _selectedAnswers = <String, String>{};
  final Map<String, String> _matchingAnswers = <String, String>{};
  final Map<String, TextEditingController> _textControllers =
      <String, TextEditingController>{};
  String? _activeMatchKey;
  bool _checked = false;

  Color get _accentColor => Color(widget.args.accentColorValue);

  @override
  void initState() {
    super.initState();
    _exerciseFuture = _loadExercise();
  }

  @override
  void dispose() {
    for (final controller in _textControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<ChapterExerciseResponseModel> _loadExercise() {
    return fetchChapterExercise(
      ChapterExerciseGenerateRequestModel(
        chapterSubcontentId: widget.args.chapterSubcontentId,
        subcontentNumber: widget.args.subcontentNumber,
        model: widget.args.model,
      ),
    );
  }

  void _retry() {
    setState(() {
      _checked = false;
      _selectedAnswers.clear();
      _matchingAnswers.clear();
      _activeMatchKey = null;
      for (final controller in _textControllers.values) {
        controller.clear();
      }
      _exerciseFuture = _loadExercise();
    });
  }

  void _checkAnswers() {
    FocusScope.of(context).unfocus();
    setState(() => _checked = true);
  }

  void _handlePrimaryAction() {
    if (!_checked) {
      _checkAnswers();
      return;
    }

    Navigator.pop(
      context,
      ChapterExerciseCompletionResult(
        chapterNumber: widget.args.chapterNumber,
        subcontentNumber: widget.args.subcontentNumber,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: FutureBuilder<ChapterExerciseResponseModel>(
          future: _exerciseFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return _StateScaffold(
                accentColor: _accentColor,
                title: widget.args.subcontentTitle,
                subtitle: widget.args.chapterTitle,
                icon: Icons.auto_awesome_rounded,
                message: 'Generating the chapter exercise.',
                showSpinner: true,
                onBack: () => Navigator.pop(context),
              );
            }

            if (snapshot.hasError) {
              return _StateScaffold(
                accentColor: AppColors.error,
                title: 'Exercise unavailable',
                subtitle: widget.args.subcontentTitle,
                icon: Icons.error_outline_rounded,
                message: snapshot.error.toString(),
                actionLabel: 'Try again',
                onAction: _retry,
                onBack: () => Navigator.pop(context),
              );
            }

            final response = snapshot.data!;
            final detail = response.chapterDetail;
            final score = _score(detail);
            final total = _totalScoredItems(detail);

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: _Header(
                    detail: detail,
                    accentColor: _accentColor,
                    checked: _checked,
                    score: score,
                    total: total,
                    onBack: () => Navigator.pop(context),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: _IntroCard(
                      detail: detail,
                      accentColor: _accentColor,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: ProfilePageConstants.sectionSpacing),
                ),
                SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: detail.isVoice
                        ? _VoiceExerciseBody(
                            detail: detail,
                            accentColor: _accentColor,
                          )
                        : _SchoolExerciseBody(
                            detail: detail,
                            accentColor: _accentColor,
                            checked: _checked,
                            selectedAnswers: _selectedAnswers,
                            matchingAnswers: _matchingAnswers,
                            activeMatchKey: _activeMatchKey,
                            textControllers: _textControllers,
                            onAnswerSelected: (key, answer) {
                              setState(() {
                                _selectedAnswers[key] = answer;
                                _checked = false;
                              });
                            },
                            onMatchLeftSelected: (key) {
                              setState(() {
                                _activeMatchKey = _activeMatchKey == key
                                    ? null
                                    : key;
                                _checked = false;
                              });
                            },
                            onMatchRightSelected: (answer) {
                              final activeKey = _activeMatchKey;
                              if (activeKey == null) return;
                              setState(() {
                                _matchingAnswers.removeWhere(
                                  (key, value) =>
                                      key != activeKey && value == answer,
                                );
                                _matchingAnswers[activeKey] = answer;
                                _activeMatchKey = null;
                                _checked = false;
                              });
                            },
                            onMatchCleared: (key) {
                              setState(() {
                                _matchingAnswers.remove(key);
                                if (_activeMatchKey == key) {
                                  _activeMatchKey = null;
                                }
                                _checked = false;
                              });
                            },
                          ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),
                SliverPadding(
                  padding: ProfilePageConstants.pagePadding,
                  sliver: SliverToBoxAdapter(
                    child: _ActionCard(
                      checked: _checked,
                      score: score,
                      total: total,
                      accentColor: _accentColor,
                      onPrimaryAction: _handlePrimaryAction,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  int _totalScoredItems(ChapterExerciseDetailModel detail) {
    var total = 0;
    for (final group in detail.exerciseGroups) {
      total += group.exerciseType == 'matching'
          ? group.pairs.length
          : group.questions.length;
    }
    return total;
  }

  int _score(ChapterExerciseDetailModel detail) {
    var score = 0;
    for (
      var groupIndex = 0;
      groupIndex < detail.exerciseGroups.length;
      groupIndex++
    ) {
      final group = detail.exerciseGroups[groupIndex];
      if (group.exerciseType == 'matching') {
        for (final pair in group.pairs) {
          final key = _matchingKey(groupIndex, pair.pairNumber);
          if (_matchingAnswers[key] == pair.rightItem) {
            score++;
          }
        }
        continue;
      }
      for (final question in group.questions) {
        final key = _questionKey(groupIndex, question.questionNumber);
        final answer = group.exerciseType == 'fill_in_the_blank'
            ? _textControllers[key]?.text
            : _selectedAnswers[key];
        if (_matchesAnswer(answer, question.answer)) {
          score++;
        }
      }
    }
    return score;
  }

  bool _matchesAnswer(String? input, String expected) {
    final actual = input?.trim().toLowerCase();
    final normalizedExpected = expected.trim().toLowerCase();
    return actual != null &&
        actual.isNotEmpty &&
        (actual == normalizedExpected || actual.contains(normalizedExpected));
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.detail,
    required this.accentColor,
    required this.checked,
    required this.score,
    required this.total,
    required this.onBack,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final bool checked;
  final int score;
  final int total;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
      decoration: const BoxDecoration(
        gradient: ProfilePageConstants.headerGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.10),
                ),
              ),
              const Spacer(),
              _HeaderPill(
                label: checked && total > 0 ? '$score/$total' : 'Exercise',
                color: accentColor,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            'Chapter ${detail.chapterNumber}.${detail.subcontentNumber}',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.white.withValues(alpha: 0.62),
              letterSpacing: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail.subcontentTitle,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.05,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            detail.chapterTitle,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.detail, required this.accentColor});

  final ChapterExerciseDetailModel detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final chips = <String>[
      _titleCase(detail.subcontentType),
      if (detail.isVoice) 'Voice lesson' else 'Practice set',
      if (detail.learningFocus.isNotEmpty)
        '${detail.learningFocus.length} focus areas',
    ];

    return _Panel(
      accentColor: accentColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail.introduction,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.6,
            ),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chips
                  .map((chip) => _Chip(chip, color: accentColor))
                  .toList(),
            ),
          ],
          if (detail.learningFocus.isNotEmpty) ...[
            const SizedBox(height: 18),
            const _Label('Learning focus'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: detail.learningFocus.map(_Chip.new).toList(),
            ),
          ],
        ],
      ),
    );
  }
}

class _SchoolExerciseBody extends StatelessWidget {
  const _SchoolExerciseBody({
    required this.detail,
    required this.accentColor,
    required this.checked,
    required this.selectedAnswers,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.textControllers,
    required this.onAnswerSelected,
    required this.onMatchLeftSelected,
    required this.onMatchRightSelected,
    required this.onMatchCleared,
  });

  final ChapterExerciseDetailModel detail;
  final Color accentColor;
  final bool checked;
  final Map<String, String> selectedAnswers;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;
  final ValueChanged<String> onMatchLeftSelected;
  final ValueChanged<String> onMatchRightSelected;
  final ValueChanged<String> onMatchCleared;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (
          var groupIndex = 0;
          groupIndex < detail.exerciseGroups.length;
          groupIndex++
        )
          Padding(
            padding: EdgeInsets.only(
              bottom: groupIndex < detail.exerciseGroups.length - 1 ? 16 : 0,
            ),
            child: _ExerciseGroupCard(
              groupIndex: groupIndex,
              group: detail.exerciseGroups[groupIndex],
              accentColor: accentColor,
              checked: checked,
              selectedAnswers: selectedAnswers,
              matchingAnswers: matchingAnswers,
              activeMatchKey: activeMatchKey,
              textControllers: textControllers,
              onAnswerSelected: onAnswerSelected,
              onMatchLeftSelected: onMatchLeftSelected,
              onMatchRightSelected: onMatchRightSelected,
              onMatchCleared: onMatchCleared,
            ),
          ),
      ],
    );
  }
}

class _ExerciseGroupCard extends StatelessWidget {
  const _ExerciseGroupCard({
    required this.groupIndex,
    required this.group,
    required this.accentColor,
    required this.checked,
    required this.selectedAnswers,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.textControllers,
    required this.onAnswerSelected,
    required this.onMatchLeftSelected,
    required this.onMatchRightSelected,
    required this.onMatchCleared,
  });

  final int groupIndex;
  final ChapterExerciseGroupModel group;
  final Color accentColor;
  final bool checked;
  final Map<String, String> selectedAnswers;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;
  final ValueChanged<String> onMatchLeftSelected;
  final ValueChanged<String> onMatchRightSelected;
  final ValueChanged<String> onMatchCleared;

  @override
  Widget build(BuildContext context) {
    return _Panel(
      accentColor: _typeColor(group.exerciseType, accentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _GroupHeader(
            group: group,
            accentColor: _typeColor(group.exerciseType, accentColor),
          ),
          const SizedBox(height: 16),
          if (group.exerciseType == 'matching')
            _MatchingBoard(
              groupIndex: groupIndex,
              pairs: group.pairs,
              accentColor: _typeColor(group.exerciseType, accentColor),
              checked: checked,
              matchingAnswers: matchingAnswers,
              activeMatchKey: activeMatchKey,
              onLeftSelected: onMatchLeftSelected,
              onRightSelected: onMatchRightSelected,
              onMatchCleared: onMatchCleared,
            )
          else
            ...group.questions.map(
              (question) => _QuestionBlock(
                groupIndex: groupIndex,
                group: group,
                question: question,
                accentColor: _typeColor(group.exerciseType, accentColor),
                checked: checked,
                selectedAnswers: selectedAnswers,
                textControllers: textControllers,
                onAnswerSelected: onAnswerSelected,
              ),
            ),
        ],
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.groupIndex,
    required this.group,
    required this.question,
    required this.accentColor,
    required this.checked,
    required this.selectedAnswers,
    required this.textControllers,
    required this.onAnswerSelected,
  });

  final int groupIndex;
  final ChapterExerciseGroupModel group;
  final ChapterExerciseQuestionModel question;
  final Color accentColor;
  final bool checked;
  final Map<String, String> selectedAnswers;
  final Map<String, TextEditingController> textControllers;
  final void Function(String key, String answer) onAnswerSelected;

  @override
  Widget build(BuildContext context) {
    final key = _questionKey(groupIndex, question.questionNumber);
    final selected = selectedAnswers[key];
    final controller = textControllers.putIfAbsent(
      key,
      TextEditingController.new,
    );
    final isFillBlank = group.exerciseType == 'fill_in_the_blank';
    final isCorrect = _matchesAnswer(
      isFillBlank ? controller.text : selected,
      question.answer,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question.prompt,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.35,
            ),
          ),
          if ((question.clue ?? '').trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            _SmallNote(
              icon: Icons.lightbulb_outline_rounded,
              text: question.clue!,
            ),
          ],
          const SizedBox(height: 12),
          if (isFillBlank)
            TextField(
              controller: controller,
              onChanged: (_) {
                if (checked) onAnswerSelected(key, controller.text);
              },
              decoration: InputDecoration(
                hintText: 'Type your answer',
                filled: true,
                fillColor: AppColors.surfaceContainer,
                focusedBorder: _inputBorder(accentColor),
                enabledBorder: _inputBorder(AppColors.outlineVariant),
              ),
            )
          else
            Column(
              children: question.options
                  .map(
                    (option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _AnswerOption(
                        label: option,
                        selected: selected == option,
                        checked: checked,
                        isCorrectAnswer: option == question.answer,
                        accentColor: accentColor,
                        onTap: () => onAnswerSelected(key, option),
                      ),
                    ),
                  )
                  .toList(),
            ),
          if (checked) ...[
            const SizedBox(height: 12),
            _ResultNote(
              isCorrect: isCorrect,
              answer: question.answer,
              explanation: question.explanation,
            ),
          ],
        ],
      ),
    );
  }
}

class _VoiceExerciseBody extends StatelessWidget {
  const _VoiceExerciseBody({required this.detail, required this.accentColor});

  final ChapterExerciseDetailModel detail;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Panel(
          accentColor: accentColor,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Speaking practice'),
              const SizedBox(height: 12),
              if ((detail.speakingFocus ?? '').trim().isNotEmpty)
                Text(
                  detail.speakingFocus!,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
              const SizedBox(height: 14),
              ...detail.practiceSteps.map(
                (step) => _VoiceStepRow(step: step, accentColor: accentColor),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _Panel(
          accentColor: AppColors.secondary,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Label('Vocabulary'),
              const SizedBox(height: 12),
              ...detail.vocabularyItems.map(_VocabularyRow.new),
            ],
          ),
        ),
        if ((detail.performanceTask ?? '').trim().isNotEmpty) ...[
          const SizedBox(height: 16),
          _Panel(
            accentColor: AppColors.tertiary,
            child: _SmallNote(
              icon: Icons.record_voice_over_rounded,
              text: detail.performanceTask!,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.checked,
    required this.score,
    required this.total,
    required this.accentColor,
    required this.onPrimaryAction,
  });

  final bool checked;
  final int score;
  final int total;
  final Color accentColor;
  final VoidCallback onPrimaryAction;

  @override
  Widget build(BuildContext context) {
    final hasScore = total > 0;
    return _Panel(
      accentColor: accentColor,
      child: Row(
        children: [
          Expanded(
            child: Text(
              checked
                  ? hasScore
                        ? 'Score: $score of $total'
                        : 'Practice checked'
                  : hasScore
                  ? 'Ready to review your answers'
                  : 'Ready to complete this practice',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
          ),
          FilledButton.icon(
            onPressed: onPrimaryAction,
            icon: Icon(
              checked ? Icons.arrow_forward_rounded : Icons.check_rounded,
              size: 18,
            ),
            label: Text(checked ? 'Continue' : 'Check'),
            style: FilledButton.styleFrom(backgroundColor: accentColor),
          ),
        ],
      ),
    );
  }
}

class _StateScaffold extends StatelessWidget {
  const _StateScaffold({
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.message,
    required this.onBack,
    this.showSpinner = false,
    this.actionLabel,
    this.onAction,
  });

  final Color accentColor;
  final String title;
  final String subtitle;
  final IconData icon;
  final String message;
  final VoidCallback onBack;
  final bool showSpinner;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            decoration: const BoxDecoration(
              gradient: ProfilePageConstants.headerGradient,
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: onBack,
                  icon: const Icon(Icons.arrow_back_rounded),
                  color: Colors.white,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
        SliverPadding(
          padding: ProfilePageConstants.pagePadding,
          sliver: SliverToBoxAdapter(
            child: _Panel(
              accentColor: accentColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _IconBox(
                    icon: icon,
                    color: accentColor,
                    showSpinner: showSpinner,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subtitle,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          message,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            color: AppColors.onSurfaceVariant,
                            height: 1.5,
                          ),
                        ),
                        if (actionLabel != null && onAction != null) ...[
                          const SizedBox(height: 12),
                          TextButton.icon(
                            onPressed: onAction,
                            icon: const Icon(Icons.refresh_rounded, size: 16),
                            label: Text(actionLabel!),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.accentColor, required this.child});

  final Color accentColor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainer,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentColor.withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.group, required this.accentColor});

  final ChapterExerciseGroupModel group;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _IconBox(icon: _groupIcon(group.exerciseType), color: accentColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                group.title,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                group.instructions,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _IconBox extends StatelessWidget {
  const _IconBox({
    required this.icon,
    required this.color,
    this.showSpinner = false,
  });

  final IconData icon;
  final Color color;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.20)),
      ),
      child: showSpinner
          ? Padding(
              padding: const EdgeInsets.all(11),
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            )
          : Icon(icon, color: color, size: 22),
    );
  }
}

class _AnswerOption extends StatefulWidget {
  const _AnswerOption({
    required this.label,
    required this.selected,
    required this.checked,
    required this.isCorrectAnswer,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final bool checked;
  final bool isCorrectAnswer;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  State<_AnswerOption> createState() => _AnswerOptionState();
}

class _AnswerOptionState extends State<_AnswerOption> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final showCorrect = widget.checked && widget.isCorrectAnswer;
    final showWrong =
        widget.checked && widget.selected && !widget.isCorrectAnswer;
    final tone = showCorrect
        ? AppColors.tertiary
        : showWrong
        ? AppColors.error
        : widget.accentColor;
    final isActive = widget.selected || showCorrect || showWrong;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) => setState(() => _pressed = false),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 120),
        scale: _pressed ? 0.985 : 1,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: isActive
                    ? tone.withValues(alpha: 0.12)
                    : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isActive
                      ? tone.withValues(alpha: 0.55)
                      : AppColors.outlineVariant.withValues(alpha: 0.14),
                  width: isActive ? 1.4 : 1,
                ),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: tone.withValues(alpha: 0.08),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ]
                    : null,
              ),
              child: Row(
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: tone.withValues(alpha: isActive ? 0.18 : 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isActive
                            ? tone.withValues(alpha: 0.45)
                            : AppColors.outlineVariant.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      showCorrect
                          ? Icons.check_rounded
                          : showWrong
                          ? Icons.close_rounded
                          : widget.selected
                          ? Icons.radio_button_checked
                          : Icons.radio_button_off,
                      size: 16,
                      color: isActive ? tone : AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchingBoard extends StatelessWidget {
  const _MatchingBoard({
    required this.groupIndex,
    required this.pairs,
    required this.accentColor,
    required this.checked,
    required this.matchingAnswers,
    required this.activeMatchKey,
    required this.onLeftSelected,
    required this.onRightSelected,
    required this.onMatchCleared,
  });

  final int groupIndex;
  final List<ChapterExerciseMatchingPairModel> pairs;
  final Color accentColor;
  final bool checked;
  final Map<String, String> matchingAnswers;
  final String? activeMatchKey;
  final ValueChanged<String> onLeftSelected;
  final ValueChanged<String> onRightSelected;
  final ValueChanged<String> onMatchCleared;

  @override
  Widget build(BuildContext context) {
    final rightItems = pairs.map((pair) => pair.rightItem).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _Label('Tap a prompt, then choose its match'),
        const SizedBox(height: 10),
        ...pairs.map((pair) {
          final key = _matchingKey(groupIndex, pair.pairNumber);
          final selectedAnswer = matchingAnswers[key];
          final isActive = activeMatchKey == key;
          final isCorrect = selectedAnswer == pair.rightItem;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _MatchPromptCard(
              label: pair.leftItem,
              selectedAnswer: selectedAnswer,
              checked: checked,
              isActive: isActive,
              isCorrect: isCorrect,
              accentColor: accentColor,
              onTap: () => onLeftSelected(key),
              onClear: selectedAnswer == null
                  ? null
                  : () => onMatchCleared(key),
            ),
          );
        }),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: rightItems.map((answer) {
            final isUsed = matchingAnswers.containsValue(answer);
            return _MatchChoiceChip(
              label: answer,
              disabled: isUsed && activeMatchKey == null,
              accentColor: accentColor,
              onTap: () => onRightSelected(answer),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _MatchPromptCard extends StatelessWidget {
  const _MatchPromptCard({
    required this.label,
    required this.selectedAnswer,
    required this.checked,
    required this.isActive,
    required this.isCorrect,
    required this.accentColor,
    required this.onTap,
    required this.onClear,
  });

  final String label;
  final String? selectedAnswer;
  final bool checked;
  final bool isActive;
  final bool isCorrect;
  final Color accentColor;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final hasAnswer = selectedAnswer != null;
    final showCorrect = checked && hasAnswer && isCorrect;
    final showWrong = checked && hasAnswer && !isCorrect;
    final tone = showCorrect
        ? AppColors.tertiary
        : showWrong
        ? AppColors.error
        : accentColor;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: (isActive || hasAnswer)
                ? tone.withValues(alpha: 0.10)
                : AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: (isActive || hasAnswer)
                  ? tone.withValues(alpha: 0.36)
                  : AppColors.outlineVariant.withValues(alpha: 0.14),
              width: isActive ? 1.6 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.drag_indicator_rounded, size: 18, color: tone),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      label,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                        height: 1.35,
                      ),
                    ),
                  ),
                  if (onClear != null)
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.close_rounded, size: 16),
                      color: AppColors.onSurfaceVariant,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      padding: EdgeInsets.zero,
                    ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: tone.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    Icon(
                      showCorrect
                          ? Icons.check_circle_rounded
                          : showWrong
                          ? Icons.error_rounded
                          : hasAnswer
                          ? Icons.link_rounded
                          : Icons.add_link_rounded,
                      size: 16,
                      color: tone,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        selectedAnswer ?? 'Choose a matching answer',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: hasAnswer
                              ? AppColors.onSurface
                              : AppColors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchChoiceChip extends StatelessWidget {
  const _MatchChoiceChip({
    required this.label,
    required this.disabled,
    required this.accentColor,
    required this.onTap,
  });

  final String label;
  final bool disabled;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 160),
      opacity: disabled ? 0.45 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled ? null : onTap,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: accentColor.withValues(alpha: 0.22)),
            ),
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultNote extends StatelessWidget {
  const _ResultNote({
    required this.isCorrect,
    required this.answer,
    required this.explanation,
  });

  final bool isCorrect;
  final String answer;
  final String explanation;

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? AppColors.tertiary : AppColors.error;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Text(
        '${isCorrect ? 'Correct' : 'Answer: $answer'}\n$explanation',
        style: GoogleFonts.inter(
          fontSize: 12,
          color: AppColors.onSurfaceVariant,
          height: 1.45,
        ),
      ),
    );
  }
}

class _VoiceStepRow extends StatelessWidget {
  const _VoiceStepRow({required this.step, required this.accentColor});

  final VoicePracticeStepModel step;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withValues(alpha: 0.14)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Chip('Step ${step.stepNumber}', color: accentColor),
          const SizedBox(height: 10),
          Text(
            step.prompt,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurface,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 8),
          _SmallNote(
            icon: Icons.tips_and_updates_rounded,
            text: step.coachingTip,
          ),
        ],
      ),
    );
  }
}

class _VocabularyRow extends StatelessWidget {
  const _VocabularyRow(this.item);

  final VoiceVocabularyItemModel item;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${item.term} - ${item.translation}',
            style: GoogleFonts.spaceGrotesk(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            item.exampleLine,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 6),
          _SmallNote(
            icon: Icons.volume_up_rounded,
            text: item.pronunciationTip,
          ),
        ],
      ),
    );
  }
}

class _SmallNote extends StatelessWidget {
  const _SmallNote({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 15, color: AppColors.secondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _Label extends StatelessWidget {
  const _Label(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: AppColors.onSurfaceVariant,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip(this.label, {this.color});

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: c != null
            ? c.withValues(alpha: 0.12)
            : AppColors.secondary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(999),
        border: c != null ? Border.all(color: c.withValues(alpha: 0.22)) : null,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: c ?? AppColors.onSurface,
        ),
      ),
    );
  }
}

class _HeaderPill extends StatelessWidget {
  const _HeaderPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }
}

OutlineInputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color.withValues(alpha: 0.45)),
  );
}

String _questionKey(int groupIndex, int questionNumber) {
  return '$groupIndex:$questionNumber';
}

String _matchingKey(int groupIndex, int pairNumber) {
  return 'match:$groupIndex:$pairNumber';
}

bool _matchesAnswer(String? input, String expected) {
  final actual = input?.trim().toLowerCase();
  final normalizedExpected = expected.trim().toLowerCase();
  return actual != null &&
      actual.isNotEmpty &&
      (actual == normalizedExpected || actual.contains(normalizedExpected));
}

IconData _groupIcon(String type) {
  switch (type) {
    case 'multiple_choice':
      return Icons.checklist_rounded;
    case 'fill_in_the_blank':
      return Icons.edit_note_rounded;
    case 'matching':
      return Icons.hub_rounded;
    default:
      return Icons.quiz_rounded;
  }
}

Color _typeColor(String type, Color fallback) {
  switch (type) {
    case 'multiple_choice':
      return AppColors.primary;
    case 'fill_in_the_blank':
      return AppColors.secondary;
    case 'matching':
      return AppColors.tertiary;
    default:
      return fallback;
  }
}

String _titleCase(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Untitled';
  return trimmed
      .split('_')
      .expand((part) => part.split(' '))
      .where((part) => part.trim().isNotEmpty)
      .map((part) {
        final normalized = part.trim();
        return '${normalized[0].toUpperCase()}${normalized.substring(1).toLowerCase()}';
      })
      .join(' ');
}
