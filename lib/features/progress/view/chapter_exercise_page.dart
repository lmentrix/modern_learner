import 'dart:async';
import 'dart:convert';

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
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChapterExercisePage extends StatefulWidget {
  const ChapterExercisePage({super.key, required this.args});

  final ChapterExercisePageArgs args;

  @override
  State<ChapterExercisePage> createState() => _ChapterExercisePageState();
}

class _ChapterExercisePageState extends State<ChapterExercisePage> {
  static const _progressCachePrefix = 'chapter_exercise_progress_v1';

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

  String get _progressCacheKey {
    final userId = Supabase.instance.client.auth.currentUser?.id ?? 'guest';
    return [
      _progressCachePrefix,
      userId,
      widget.args.chapterSubcontentId,
      widget.args.subcontentNumber,
    ].join('::');
  }

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
        await _restoreProgress();
        if (!mounted) return;
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
          courseKey: widget.args.courseKey,
          courseId: widget.args.courseId,
        ),
      );
      if (!mounted) return;
      await _restoreProgress();
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
    unawaited(_clearProgress());
    unawaited(_fetchFromNetwork());
  }

  Future<void> _restoreProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progressCacheKey);
    if (raw == null) {
      await _restoreProgressFromSupabase(prefs);
      return;
    }

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic>) return;
      _applyProgressPayload(decoded);
    } catch (_) {
      await prefs.remove(_progressCacheKey);
      await _restoreProgressFromSupabase(prefs);
    }
  }

  Future<void> _restoreProgressFromSupabase(SharedPreferences prefs) async {
    try {
      final payload = await RoadmapService.instance
          .fetchChapterExerciseProgress(
            chapterSubcontentId: widget.args.chapterSubcontentId,
            subcontentNumber: widget.args.subcontentNumber,
          );
      if (payload == null || payload.isEmpty) return;
      await prefs.setString(_progressCacheKey, jsonEncode(payload));
      _applyProgressPayload(payload);
    } catch (_) {}
  }

  Future<void> _saveProgress() async {
    final payload = _progressPayload();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progressCacheKey, jsonEncode(payload));
    unawaited(_saveProgressToSupabase(payload));
  }

  Map<String, dynamic> _progressPayload({DateTime? completedAt}) {
    final textAnswers = {
      for (final entry in _textControllers.entries)
        if (entry.value.text.trim().isNotEmpty) entry.key: entry.value.text,
    };
    final selectedAnswers = {..._selectedAnswers, ...textAnswers};
    return <String, dynamic>{
      'selectedAnswers': selectedAnswers,
      'matchingAnswers': _matchingAnswers,
      'checkedQuestionKeys': _checkedQuestionKeys.toList(),
      'checkedMatchKeys': _checkedMatchKeys.toList(),
      'checkedVoiceStepKeys': _checkedVoiceStepKeys.toList(),
      'checked': _checked,
      'streak': _streak,
      'answeredCount': _answeredCount,
      if (completedAt != null) 'completedAt': completedAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  Future<void> _saveProgressToSupabase(Map<String, dynamic> payload) async {
    final courseKey = widget.args.courseKey;
    if (courseKey == null) return;
    try {
      await RoadmapService.instance.saveChapterExerciseProgress(
        progressJson: payload,
        courseKey: courseKey,
        courseId: widget.args.courseId,
        chapterSubcontentId: widget.args.chapterSubcontentId,
        chapterNumber: widget.args.chapterNumber,
        subcontentNumber: widget.args.subcontentNumber,
        completedAt: DateTime.tryParse(payload['completedAt'] as String? ?? ''),
      );
    } catch (_) {}
  }

  Future<void> _clearProgress() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progressCacheKey);
  }

  void _applyProgressPayload(Map<String, dynamic> decoded) {
    final selectedAnswers = _readStringMap(decoded['selectedAnswers']);
    final matchingAnswers = _readStringMap(decoded['matchingAnswers']);
    final checkedQuestionKeys = _readStringSet(decoded['checkedQuestionKeys']);
    final checkedMatchKeys = _readStringSet(decoded['checkedMatchKeys']);
    final checkedVoiceStepKeys = _readStringSet(
      decoded['checkedVoiceStepKeys'],
    );

    _selectedAnswers
      ..clear()
      ..addAll(selectedAnswers);
    _matchingAnswers
      ..clear()
      ..addAll(matchingAnswers);
    _checkedQuestionKeys
      ..clear()
      ..addAll(checkedQuestionKeys);
    _checkedMatchKeys
      ..clear()
      ..addAll(checkedMatchKeys);
    _checkedVoiceStepKeys
      ..clear()
      ..addAll(checkedVoiceStepKeys);

    _checked = decoded['checked'] == true;
    _streak = (decoded['streak'] as num?)?.toInt() ?? 0;
    _answeredCount =
        (decoded['answeredCount'] as num?)?.toInt() ??
        checkedQuestionKeys.length + checkedMatchKeys.length;

    for (final entry in selectedAnswers.entries) {
      _textControllers.putIfAbsent(entry.key, TextEditingController.new).text =
          entry.value;
    }
  }

  Map<String, String> _readStringMap(Object? value) {
    if (value is! Map) return const {};
    return value.map(
      (key, value) => MapEntry(key.toString(), value?.toString() ?? ''),
    );
  }

  Set<String> _readStringSet(Object? value) {
    if (value is! List) return const {};
    return value.map((item) => item.toString()).toSet();
  }

  // ── Interaction ───────────────────────────────────────────────────────────

  void _checkAnswers() {
    FocusScope.of(context).unfocus();
    setState(() => _checked = true);
    unawaited(_saveProgress());
  }

  void _handlePrimaryAction() {
    if (!_checked) {
      _checkAnswers();
      return;
    }
    unawaited(_completeAndExit());
  }

  Future<void> _completeAndExit() async {
    final completedAt = DateTime.now();
    final payload = _progressPayload(completedAt: completedAt);
    await _saveProgressToSupabase(payload);
    await _clearProgress();
    if (!mounted) return;
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
        child: SafeArea(child: SizedBox.expand(child: _buildBody())),
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
    final response = _response;
    if (response == null) {
      return ExerciseStateScaffold(
        accentColor: AppColors.error,
        title: 'Exercise unavailable',
        subtitle: widget.args.subcontentTitle,
        icon: Icons.error_outline_rounded,
        message: 'The exercise did not finish loading. Try opening it again.',
        actionLabel: 'Try again',
        onAction: _retry,
        onBack: () => Navigator.pop(context),
      );
    }

    final detail = response.chapterDetail;
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
        SliverToBoxAdapter(
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
                      unawaited(_saveProgress());
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
                      unawaited(_saveProgress());
                    },
                    onMatchLeftSelected: (key) {
                      setState(() {
                        _activeMatchKey = _activeMatchKey == key ? null : key;
                        _checked = false;
                      });
                      unawaited(_saveProgress());
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
                      unawaited(_saveProgress());
                    },
                    onMatchCleared: (key) {
                      setState(() {
                        _matchingAnswers.remove(key);
                        _checkedMatchKeys.remove(key);
                        if (_activeMatchKey == key) _activeMatchKey = null;
                        _checked = false;
                      });
                      unawaited(_saveProgress());
                    },
                    onQuestionChecked: (key, {required bool isCorrect}) {
                      setState(() {
                        _checkedQuestionKeys.add(key);
                        _answeredCount =
                            _checkedQuestionKeys.length +
                            _checkedMatchKeys.length;
                        if (isCorrect) {
                          _streak++;
                        } else {
                          _streak = 0;
                        }
                      });
                      unawaited(_saveProgress());
                    },
                    onMatchChecked: (key) {
                      setState(() {
                        _checkedMatchKeys.add(key);
                        _answeredCount =
                            _checkedQuestionKeys.length +
                            _checkedMatchKeys.length;
                      });
                      unawaited(_saveProgress());
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
