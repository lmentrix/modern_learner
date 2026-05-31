import 'dart:async';

import 'package:flutter/material.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/profile/data/profile_page_constants.dart';
import 'package:modern_learner_production/features/profile/view/widgets/learning_activity_scope.dart';
import 'package:modern_learner_production/features/progress/service/request/exercise_request.dart';
import 'package:modern_learner_production/features/progress/view/helpers/exercise_helpers.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_action_card.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_header.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_intro_card.dart';
import 'package:modern_learner_production/features/progress/view/section/exercise_skeleton_section.dart';
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
  // ── Load state ────────────────────────────────────────────────────────────
  ChapterExerciseResponseModel? _response;
  Object? _error;

  /// True while the disk-cache lookup is in progress.
  /// Kept separate from [_isGenerating] so the UI can distinguish a fast
  /// local read (no skeleton) from a slow network generation (full skeleton).
  bool _isResolvingCache = true;

  /// True when a network request is in flight (cache miss path).
  bool _isGenerating = false;

  // ── Exercise interaction state ────────────────────────────────────────────
  final Map<String, String> _selectedAnswers = {};
  final Map<String, String> _matchingAnswers = {};
  final Map<String, TextEditingController> _textControllers = {};
  final Set<String> _checkedQuestionKeys = {};
  final Set<String> _checkedMatchKeys = {};
  final Set<String> _checkedVoiceStepKeys = {};
  String? _activeMatchKey;
  bool _checked = false;
  int _lastScore = 0;
  int _lastTotal = 0;

  // ── Gamification state ────────────────────────────────────────────────────
  int _streak = 0;
  int _answeredCount = 0;

  Color get _accentColor => Color(widget.args.accentColorValue);

  @override
  void initState() {
    super.initState();
    unawaited(_initLoad());
  }

  @override
  void dispose() {
    for (final c in _textControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  /// Entry point called once from [initState].
  /// 1. Reads the persistent cache (GenerationCacheManager / flutter_cache_manager).
  /// 2. If a valid entry exists → resolves immediately, no skeleton shown.
  /// 3. If cache miss → switches to generating state and hits the network.
  Future<void> _initLoad() async {
    final rawJson = await const GenerationCache().readExercise(
      chapterSubcontentId: widget.args.chapterSubcontentId,
      subcontentNumber: widget.args.subcontentNumber,
    );

    if (!mounted) return;

    if (rawJson != null) {
      ChapterExerciseResponseModel? parsed;
      try {
        parsed = ChapterExerciseResponseModel.fromRawJson(rawJson);
      } catch (_) {
        // Corrupt cache entry — fall through to network fetch.
      }

      if (parsed != null) {
        setState(() {
          _response = parsed;
          _isResolvingCache = false;
        });
        return;
      }
    }

    // Cache miss: show the skeleton and start generating.
    setState(() {
      _isResolvingCache = false;
      _isGenerating = true;
    });

    await _fetchFromNetwork();
  }

  Future<void> _fetchFromNetwork() async {
    try {
      final result = await fetchChapterExercise(
        ChapterExerciseGenerateRequestModel(
          chapterSubcontentId: widget.args.chapterSubcontentId,
          subcontentNumber: widget.args.subcontentNumber,
          model: widget.args.model,
          context: widget.args.context,
        ),
      );
      if (!mounted) return;
      setState(() {
        _response = result;
        _isGenerating = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e;
        _isGenerating = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _error = null;
      _isGenerating = true;
      _checked = false;
      _response = null;
      _streak = 0;
      _answeredCount = 0;
      _selectedAnswers.clear();
      _matchingAnswers.clear();
      _checkedQuestionKeys.clear();
      _checkedMatchKeys.clear();
      _checkedVoiceStepKeys.clear();
      _activeMatchKey = null;
      for (final c in _textControllers.values) {
        c.clear();
      }
    });
    unawaited(_fetchFromNetwork());
  }

  // ── Interaction ───────────────────────────────────────────────────────────

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
        score: _lastScore,
        totalQuestions: _lastTotal,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: LearningActivityScope(
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    // Brief cache-check moment: show nothing (white flash avoided by surface bg).
    // This resolves in milliseconds so no visual artifact occurs.
    if (_isResolvingCache) {
      return const SizedBox.shrink();
    }

    // Network generation in progress → full skeleton.
    if (_isGenerating) {
      return ExerciseSkeletonSection(
        accentColor: _accentColor,
        title: widget.args.subcontentTitle,
        subtitle: widget.args.chapterTitle,
        onBack: () => Navigator.pop(context),
      );
    }

    // Error state.
    if (_error != null) {
      return ExerciseStateScaffold(
        accentColor: AppColors.error,
        title: 'Exercise unavailable',
        subtitle: widget.args.subcontentTitle,
        icon: Icons.error_outline_rounded,
        message: _error.toString(),
        actionLabel: 'Try again',
        onAction: _retry,
        onBack: () => Navigator.pop(context),
      );
    }

    // Loaded — render the exercise.
    final detail = _response!.chapterDetail;
    final score = _score(detail);
    final total = _totalScoredItems(detail);
    _lastScore = score;
    _lastTotal = total;

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
            answeredCount: _answeredCount,
            streak: _streak,
            onBack: () => Navigator.pop(context),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        SliverPadding(
          padding: ProfilePageConstants.pagePadding,
          sliver: SliverToBoxAdapter(
            child: ExerciseIntroCard(detail: detail, accentColor: _accentColor),
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
                    checkedVoiceStepKeys: _checkedVoiceStepKeys,
                    onVoiceStepChecked: (key) {
                      setState(() => _checkedVoiceStepKeys.add(key));
                    },
                  )
                : SchoolExerciseBody(
                    detail: detail,
                    accentColor: _accentColor,
                    checked: _checked,
                    checkedQuestionKeys: _checkedQuestionKeys,
                    checkedMatchKeys: _checkedMatchKeys,
                    selectedAnswers: _selectedAnswers,
                    matchingAnswers: _matchingAnswers,
                    activeMatchKey: _activeMatchKey,
                    textControllers: _textControllers,
                    onAnswerSelected: (key, answer) {
                      setState(() {
                        _selectedAnswers[key] = answer;
                        _checked = false;
                        _checkedQuestionKeys.remove(key);
                      });
                    },
                    onMatchLeftSelected: (key) {
                      setState(() {
                        _activeMatchKey =
                            _activeMatchKey == key ? null : key;
                        _checked = false;
                      });
                    },
                    onMatchRightSelected: (answer) {
                      final activeKey = _activeMatchKey;
                      if (activeKey == null) return;
                      setState(() {
                        _matchingAnswers.removeWhere(
                          (k, v) => k != activeKey && v == answer,
                        );
                        _matchingAnswers[activeKey] = answer;
                        _activeMatchKey = null;
                        _checked = false;
                        _checkedMatchKeys.remove(activeKey);
                      });
                    },
                    onMatchCleared: (key) {
                      setState(() {
                        _matchingAnswers.remove(key);
                        _checkedMatchKeys.remove(key);
                        if (_activeMatchKey == key) _activeMatchKey = null;
                        _checked = false;
                      });
                    },
                    onQuestionChecked: (key, {required bool isCorrect}) {
                      setState(() {
                        _checkedQuestionKeys.add(key);
                        _answeredCount =
                            _checkedQuestionKeys.length + _checkedMatchKeys.length;
                        if (isCorrect) {
                          _streak++;
                        } else {
                          _streak = 0;
                        }
                      });
                    },
                    onMatchChecked: (key) {
                      setState(() {
                        _checkedMatchKeys.add(key);
                        _answeredCount =
                            _checkedQuestionKeys.length + _checkedMatchKeys.length;
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
  }

  // ── Scoring ───────────────────────────────────────────────────────────────

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
    for (var gi = 0; gi < detail.exerciseGroups.length; gi++) {
      final group = detail.exerciseGroups[gi];
      if (group.exerciseType == 'matching') {
        for (final pair in group.pairs) {
          if (_matchingAnswers[matchingKey(gi, pair.pairNumber)] ==
              pair.rightItem) {
            score++;
          }
        }
        continue;
      }
      for (final question in group.questions) {
        final key = questionKey(gi, question.questionNumber);
        final answer = group.exerciseType == 'fill_in_the_blank'
            ? _textControllers[key]?.text
            : _selectedAnswers[key];
        if (matchesAnswer(answer, question.answer)) score++;
      }
    }
    return score;
  }
}
