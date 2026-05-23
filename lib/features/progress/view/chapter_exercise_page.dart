import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_action_card.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_header.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_intro_card.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_state_scaffold.dart';
import 'package:modern_learner_production/features/progress/view/section/school_exercise_body.dart';
import 'package:modern_learner_production/features/progress/view/section/voice_exercise_body.dart';

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
              return ExerciseStateScaffold(
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
              return ExerciseStateScaffold(
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
                  child: ExerciseHeader(
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
                    child: ExerciseIntroCard(
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
                        ? VoiceExerciseBody(
                            detail: detail,
                            accentColor: _accentColor,
                          )
                        : SchoolExerciseBody(
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
                    child: ExerciseActionCard(
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
          final key = matchingKey(groupIndex, pair.pairNumber);
          if (_matchingAnswers[key] == pair.rightItem) {
            score++;
          }
        }
        continue;
      }
      for (final question in group.questions) {
        final key = questionKey(groupIndex, question.questionNumber);
        final answer = group.exerciseType == 'fill_in_the_blank'
            ? _textControllers[key]?.text
            : _selectedAnswers[key];
        if (matchesAnswer(answer, question.answer)) {
          score++;
        }
      }
    }
    return score;
  }
}
