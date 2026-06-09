import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:modern_learner_production/core/l10n/app_text.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/exercise/models/exercise.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_answer_option.dart';
import 'package:modern_learner_production/features/exercise/widgets/exercise_hint.dart';
import 'package:modern_learner_production/features/voice/service/qwen_pronunciation_service.dart';
import 'package:modern_learner_production/features/voice/service/voice_pronunciation_scorer.dart';
import 'package:modern_learner_production/features/voice/service/voice_recognition_service.dart';

class ExerciseAnswerSection extends StatelessWidget {
  const ExerciseAnswerSection({
    super.key,
    required this.exercise,
    required this.accentColor,
    required this.selectedAnswer,
    required this.answered,
    required this.isCorrect,
    required this.onCheckAnswer,
    this.language,
  });

  final Exercise exercise;
  final Color accentColor;
  final String? selectedAnswer;
  final bool answered;
  final bool isCorrect;
  final ValueChanged<String> onCheckAnswer;
  final String? language;

  @override
  Widget build(BuildContext context) {
    switch (exercise.type) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice();
      case ExerciseType.fillBlank:
        return _buildFillBlank(context);
      case ExerciseType.speaking:
        return _SpeakingExerciseCard(
          exercise: exercise,
          accentColor: accentColor,
          answered: answered,
          onCheckAnswer: onCheckAnswer,
          language: language,
        );
      case ExerciseType.matching:
        return _buildMatching(context);
      case ExerciseType.trueFalse:
        return _buildTrueFalse();
      case ExerciseType.writing:
        return _buildWriting(context);
    }
  }

  Widget _buildMultipleChoice() {
    final hint = exercise.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && !answered) ExerciseHint(hint: hint),
        const SizedBox(height: 16),
        ...(exercise.options ?? []).map(
          (option) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: ExerciseAnswerOption(
              option: option,
              isSelected: selectedAnswer == option,
              isCorrect: answered && option == exercise.correctAnswer,
              isWrong:
                  answered &&
                  selectedAnswer == option &&
                  option != exercise.correctAnswer,
              onTap: () => onCheckAnswer(option),
              accentColor: accentColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFillBlank(BuildContext context) {
    final hint = exercise.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && !answered) ExerciseHint(hint: hint),
        SizedBox(height: 16),
        TextField(
          enabled: !answered,
          decoration: InputDecoration(
            hintText: context.tr('Type your answer here...'),
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
              context.tr(answered ? 'Submitted' : 'Check Answer'),
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

  Widget _buildMatching(BuildContext context) {
    final hint = exercise.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && !answered) ExerciseHint(hint: hint),
        SizedBox(height: 16),
        ...(exercise.pairs ?? []).map(
          (pair) => Padding(
            padding: EdgeInsets.only(bottom: 10),
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final left = Text(
                    pair.values.first,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  );
                  final right = Text(
                    pair.values.last,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: accentColor,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                  if (constraints.maxWidth < 260) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        left,
                        SizedBox(height: 8),
                        Icon(
                          Icons.arrow_downward_rounded,
                          size: 18,
                          color: AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(height: 8),
                        right,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: left),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: right),
                    ],
                  );
                },
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
              context.tr('Continue'),
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
    final hint = exercise.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && !answered) ExerciseHint(hint: hint),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final trueOption = ExerciseAnswerOption(
              option: 'True',
              isSelected: selectedAnswer == 'true',
              isCorrect: answered && exercise.correctAnswer == 'true',
              isWrong:
                  answered &&
                  selectedAnswer == 'true' &&
                  exercise.correctAnswer != 'true',
              onTap: () => onCheckAnswer('true'),
              accentColor: accentColor,
            );
            final falseOption = ExerciseAnswerOption(
              option: 'False',
              isSelected: selectedAnswer == 'false',
              isCorrect: answered && exercise.correctAnswer == 'false',
              isWrong:
                  answered &&
                  selectedAnswer == 'false' &&
                  exercise.correctAnswer != 'false',
              onTap: () => onCheckAnswer('false'),
              accentColor: accentColor,
            );
            if (constraints.maxWidth < 300) {
              return Column(
                children: [trueOption, const SizedBox(height: 10), falseOption],
              );
            }
            return Row(
              children: [
                Expanded(child: trueOption),
                const SizedBox(width: 12),
                Expanded(child: falseOption),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildWriting(BuildContext context) {
    final hint = exercise.hint;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && !answered) ExerciseHint(hint: hint),
        SizedBox(height: 16),
        TextField(
          enabled: !answered,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: context.tr('Write your answer here...'),
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
              context.tr(answered ? 'Submitted' : 'Submit'),
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

// ── Speaking exercise card ─────────────────────────────────────────────────────

enum _SpeakPhase { idle, listening, scoring, done }

class _SpeakingExerciseCard extends StatefulWidget {
  const _SpeakingExerciseCard({
    required this.exercise,
    required this.accentColor,
    required this.answered,
    required this.onCheckAnswer,
    this.language,
  });

  final Exercise exercise;
  final Color accentColor;
  final bool answered;
  final ValueChanged<String> onCheckAnswer;
  final String? language;

  @override
  State<_SpeakingExerciseCard> createState() => _SpeakingExerciseCardState();
}

class _SpeakingExerciseCardState extends State<_SpeakingExerciseCard> {
  _SpeakPhase _phase = _SpeakPhase.idle;
  String _transcript = '';
  double _confidence = 0;
  QwenPronunciationResult? _result;

  @override
  void initState() {
    super.initState();
    if (widget.answered) _phase = _SpeakPhase.done;
  }

  @override
  void dispose() {
    unawaited(VoiceRecognitionService.instance.cancelListening());
    super.dispose();
  }

  Future<void> _startListening() async {
    final ok = await VoiceRecognitionService.instance.initialize();
    if (!mounted || !ok) return;

    setState(() {
      _phase = _SpeakPhase.listening;
      _transcript = '';
      _confidence = 0;
      _result = null;
    });

    await VoiceRecognitionService.instance.startListening(
      onResult: (words, confidence) {
        if (!mounted) return;
        setState(() {
          _transcript = words;
          _confidence = confidence;
        });
      },
      onDone: _onListeningDone,
    );
  }

  Future<void> _stopListening() async {
    await VoiceRecognitionService.instance.stopListening();
    _onListeningDone();
  }

  void _onListeningDone() {
    if (!mounted || _phase != _SpeakPhase.listening) return;
    setState(() => _phase = _SpeakPhase.scoring);
    unawaited(_runQwenScoring());
  }

  QwenPronunciationResult _localFallback(String expected) {
    final local = VoicePronunciationScorer.score(
      expected: expected,
      spoken: _transcript,
      sttConfidence: _confidence,
    );
    final pct = (local.score * 100).round().clamp(0, 100);
    final grade = pct >= 90
        ? 'Excellent'
        : pct >= 75
            ? 'Good'
            : pct >= 50
                ? 'Fair'
                : 'Needs Practice';
    final expectedWords = expected.toLowerCase().split(RegExp(r'\s+'));
    final spokenWords = _transcript.toLowerCase().split(RegExp(r'\s+'));
    final wordDetails = expectedWords.map((w) {
      final correct = spokenWords.contains(w);
      return QwenWordDetail(word: w, correct: correct);
    }).toList();
    return QwenPronunciationResult(
      scorePercent: pct,
      grade: grade,
      feedback: local.matchedWords == 0
          ? 'Keep practicing — try speaking more clearly.'
          : 'You got ${local.matchedWords} of ${expectedWords.length} words right.',
      wordDetails: wordDetails,
      encouragement: pct >= 75 ? 'Great job! Keep it up!' : 'You\'re improving!',
    );
  }

  Future<void> _runQwenScoring() async {
    final expected = widget.exercise.content ?? widget.exercise.question;
    final qwenResult = await QwenPronunciationService.instance.score(
      expected: expected,
      spoken: _transcript,
      language: widget.language ?? 'English',
      sttConfidence: _confidence,
    );
    if (!mounted) return;
    setState(() {
      _result = qwenResult ?? _localFallback(expected);
      _phase = _SpeakPhase.done;
    });
  }

  void _retry() {
    setState(() {
      _phase = _SpeakPhase.idle;
      _transcript = '';
      _result = null;
    });
  }

  void _continue() => widget.onCheckAnswer('spoken');

  @override
  Widget build(BuildContext context) {
    final hint = widget.exercise.hint;
    final phrase = widget.exercise.content ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hint != null && _phase == _SpeakPhase.idle) ExerciseHint(hint: hint),
        const SizedBox(height: 16),
        _buildCard(phrase),
      ],
    );
  }

  Widget _buildCard(String phrase) {
    return switch (_phase) {
      _SpeakPhase.idle => _buildIdle(phrase),
      _SpeakPhase.listening => _buildListening(),
      _SpeakPhase.scoring => _buildScoring(),
      _SpeakPhase.done => _buildDone(phrase),
    };
  }

  Widget _buildIdle(String phrase) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: widget.accentColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: widget.accentColor.withValues(alpha: 0.25)),
          ),
          child: Column(
            children: [
              Icon(Icons.mic_rounded, size: 40, color: widget.accentColor),
              const SizedBox(height: 12),
              Text(
                context.tr('Tap to speak'),
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              if (phrase.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '"$phrase"',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _startListening,
            icon: const Icon(Icons.mic_rounded, size: 18),
            label: Text(
              context.tr('Speak now'),
              style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListening() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.error.withValues(alpha: 0.30)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.fiber_manual_record, size: 12, color: AppColors.error),
                  const SizedBox(width: 6),
                  Text(
                    'Listening…',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
              if (_transcript.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  _transcript,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: AppColors.onSurface,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton.icon(
            onPressed: _stopListening,
            icon: const Icon(Icons.stop_rounded, size: 18),
            label: Text(
              context.tr('Done'),
              style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildScoring() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: widget.accentColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.20)),
      ),
      child: Column(
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(widget.accentColor),
            strokeWidth: 3,
          ),
          const SizedBox(height: 14),
          Text(
            'AI is scoring your pronunciation…',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDone(String phrase) {
    final result = _result;
    final scoreColor = result == null
        ? widget.accentColor
        : result.scorePercent >= 78
        ? AppColors.tertiary
        : result.scorePercent >= 50
        ? const Color(0xFFFFD580)
        : AppColors.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Score card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: scoreColor.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: scoreColor.withValues(alpha: 0.28)),
          ),
          child: result == null
              ? _buildNoResultBody(scoreColor)
              : _buildResultBody(result, scoreColor),
        ),

        const SizedBox(height: 14),

        // Action row
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.mic_rounded, size: 16),
                label: Text(
                  context.tr('Try again'),
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: widget.accentColor,
                  side: BorderSide(color: widget.accentColor.withValues(alpha: 0.40)),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton(
                onPressed: widget.answered ? null : _continue,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  context.tr(widget.answered ? 'Completed' : 'Continue'),
                  style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNoResultBody(Color scoreColor) {
    return Column(
      children: [
        Icon(Icons.check_circle_rounded, size: 40, color: scoreColor),
        const SizedBox(height: 8),
        Text(
          context.tr('Great pronunciation!'),
          style: GoogleFonts.spaceGrotesk(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildResultBody(QwenPronunciationResult result, Color scoreColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grade + score
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: scoreColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: scoreColor.withValues(alpha: 0.32)),
              ),
              child: Text(
                result.grade,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: scoreColor,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${result.scorePercent}%',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: scoreColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Score bar
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: result.score,
            minHeight: 7,
            backgroundColor: AppColors.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(scoreColor),
          ),
        ),
        const SizedBox(height: 12),

        // Transcript
        if (_transcript.isNotEmpty)
          Text(
            '"$_transcript"',
            style: GoogleFonts.inter(
              fontSize: 12,
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        const SizedBox(height: 8),

        // Feedback
        Text(
          result.feedback,
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.onSurfaceVariant,
            height: 1.45,
          ),
        ),

        // Encouragement
        if (result.encouragement.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 13, color: scoreColor),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  result.encouragement,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: scoreColor,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],

        // Word details chips
        if (result.wordDetails.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: result.wordDetails.map((w) {
              final c = w.correct ? AppColors.tertiary : AppColors.error;
              return Tooltip(
                message: w.tip ?? '',
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: c.withValues(alpha: 0.30)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        w.word,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: c,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Icon(
                        w.correct ? Icons.check_rounded : Icons.close_rounded,
                        size: 11,
                        color: c,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
