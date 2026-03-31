import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../lesson_detail/presentation/pages/lesson_detail_page.dart';

enum ExerciseType {
  multipleChoice,
  fillBlank,
  speaking,
  matching,
  trueFalse,
  writing,
}

class ExercisePage extends StatefulWidget {
  final LessonType lessonType;
  final String title;
  final String sectionTitle;
  final Color accentColor;
  final String emoji;

  const ExercisePage({
    super.key,
    required this.lessonType,
    required this.title,
    required this.sectionTitle,
    required this.accentColor,
    required this.emoji,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

class _ExercisePageState extends State<ExercisePage> {
  int _currentExerciseIndex = 0;
  int _correctAnswers = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isCorrect = false;

  late List<Exercise> _exercises;

  @override
  void initState() {
    super.initState();
    _exercises = _generateExercises();
  }

  List<Exercise> _generateExercises() {
    switch (widget.lessonType) {
      case LessonType.voice:
        return _generateVoiceExercises();
      case LessonType.school:
        return _generateSchoolExercises();
      case LessonType.continueLearning:
        return _generateGeneralExercises();
    }
  }

  List<Exercise> _generateVoiceExercises() {
    return [
      const Exercise(
        type: ExerciseType.speaking,
        question: 'Listen and repeat the following phrase:',
        content: 'The quick brown fox jumps over the lazy dog',
        hint: 'Focus on clear pronunciation of each word',
        correctAnswer: 'speech recognition',
      ),
      const Exercise(
        type: ExerciseType.multipleChoice,
        question: 'Which word has a different vowel sound?',
        options: ['cat', 'bat', 'cake', 'mat'],
        correctAnswer: 'cake',
        hint: 'Think about the "a" sound in each word',
      ),
      const Exercise(
        type: ExerciseType.matching,
        question: 'Match the words with their pronunciations:',
        pairs: [
          {'word': 'Through', 'pronunciation': 'θruː'},
          {'word': 'Thought', 'pronunciation': 'θɔːt'},
          {'word': 'Tough', 'pronunciation': 'tʌf'},
        ],
        hint: 'Listen carefully to each sound',
      ),
      const Exercise(
        type: ExerciseType.fillBlank,
        question: 'Complete the tongue twister:',
        content: 'She sells _____ shells by the seashore',
        correctAnswer: 'seashell',
        hint: 'It rhymes with "treasure"',
      ),
      const Exercise(
        type: ExerciseType.trueFalse,
        question: 'True or False: The "th" sound is made with the tongue between the teeth',
        correctAnswer: 'true',
        hint: 'Think about how you position your tongue',
      ),
    ];
  }

  List<Exercise> _generateSchoolExercises() {
    return [
      const Exercise(
        type: ExerciseType.multipleChoice,
        question: 'What is the capital of France?',
        options: ['London', 'Berlin', 'Paris', 'Madrid'],
        correctAnswer: 'Paris',
        hint: 'It\'s known for the Eiffel Tower',
      ),
      const Exercise(
        type: ExerciseType.trueFalse,
        question: 'The mitochondria is the powerhouse of the cell',
        correctAnswer: 'true',
        hint: 'Think about cellular respiration',
      ),
      const Exercise(
        type: ExerciseType.fillBlank,
        question: 'Complete the equation: E = _____',
        content: 'E = _____',
        correctAnswer: 'mc²',
        hint: 'Einstein\'s famous equation',
      ),
      const Exercise(
        type: ExerciseType.writing,
        question: 'Explain the water cycle in 2-3 sentences:',
        hint: 'Include evaporation, condensation, and precipitation',
        correctAnswer: 'written response',
      ),
      const Exercise(
        type: ExerciseType.matching,
        question: 'Match the historical events with their dates:',
        pairs: [
          {'event': 'Moon Landing', 'date': '1969'},
          {'event': 'WWII Ended', 'date': '1945'},
          {'event': 'Berlin Wall Fell', 'date': '1989'},
        ],
        hint: 'Think about the timeline',
      ),
    ];
  }

  List<Exercise> _generateGeneralExercises() {
    return [
      const Exercise(
        type: ExerciseType.multipleChoice,
        question: 'What does the prefix "un-" mean?',
        options: ['Again', 'Not', 'Before', 'After'],
        correctAnswer: 'Not',
        hint: 'Think about words like "unable" or "unhappy"',
      ),
      const Exercise(
        type: ExerciseType.fillBlank,
        question: 'Choose the correct word:',
        content: 'Their/There/They\'re going to the park',
        correctAnswer: 'They\'re',
        hint: 'It\'s a contraction of "they are"',
      ),
      const Exercise(
        type: ExerciseType.trueFalse,
        question: 'A noun is a person, place, thing, or idea',
        correctAnswer: 'true',
        hint: 'This is the basic definition',
      ),
      const Exercise(
        type: ExerciseType.writing,
        question: 'Write a sentence using a metaphor:',
        hint: 'Compare two things without using "like" or "as"',
        correctAnswer: 'written response',
      ),
      const Exercise(
        type: ExerciseType.matching,
        question: 'Match the synonyms:',
        pairs: [
          {'word': 'Happy', 'synonym': 'Joyful'},
          {'word': 'Sad', 'synonym': 'Melancholy'},
          {'word': 'Angry', 'synonym': 'Furious'},
        ],
        hint: 'Find words with similar meanings',
      ),
    ];
  }

  Exercise get _currentExercise => _exercises[_currentExerciseIndex];

  double get _progress => (_currentExerciseIndex) / _exercises.length;

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

    // Auto advance after delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _nextExercise();
      }
    });
  }

  bool _evaluateAnswer(String answer) {
    final correct = _currentExercise.correctAnswer?.toLowerCase();
    if (correct == null) return true; // For written/speaking, accept any attempt

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
      builder: (context) => _CompletionDialog(
        accentColor: widget.accentColor,
        totalQuestions: _exercises.length,
        correctAnswers: _correctAnswers,
        onContinue: () {
          // Pop back to home dashboard
          Navigator.of(context, rootNavigator: true).pop(); // Close dialog
          Navigator.of(context, rootNavigator: true).pop(); // Close exercise page
          Navigator.of(context, rootNavigator: true).pop(); // Close lesson detail page
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
            _buildHeader(),
            _buildProgressBar(),
            Expanded(child: _buildExerciseContent()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  widget.sectionTitle,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: widget.accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on_rounded,
                  size: 16,
                  color: widget.accentColor,
                ),
                const SizedBox(width: 4),
                Text(
                  '$_correctAnswers',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Question ${_currentExerciseIndex + 1} of ${_exercises.length}',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              Text(
                '${((_progress) * 100).round()}%',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: widget.accentColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 6,
              backgroundColor: AppColors.surfaceContainerHigh,
              valueColor: AlwaysStoppedAnimation<Color>(widget.accentColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildQuestionCard(),
          const SizedBox(height: 24),
          _buildAnswerSection(),
        ],
      ),
    );
  }

  Widget _buildQuestionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.accentColor.withValues(alpha: 0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: widget.accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _getExerciseTypeLabel(),
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: widget.accentColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentExercise.question,
            style: GoogleFonts.spaceGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.onSurface,
              height: 1.4,
            ),
          ),
          if (_currentExercise.content != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _currentExercise.content!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: AppColors.onSurface,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerSection() {
    switch (_currentExercise.type) {
      case ExerciseType.multipleChoice:
        return _buildMultipleChoice();
      case ExerciseType.fillBlank:
        return _buildFillBlank();
      case ExerciseType.speaking:
        return _buildSpeaking();
      case ExerciseType.matching:
        return _buildMatching();
      case ExerciseType.trueFalse:
        return _buildTrueFalse();
      case ExerciseType.writing:
        return _buildWriting();
    }
  }

  Widget _buildMultipleChoice() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 16),
        ...(_currentExercise.options ?? []).map((option) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AnswerOption(
                option: option,
                isSelected: _selectedAnswer == option,
                isCorrect: _answered && option == _currentExercise.correctAnswer,
                isWrong: _answered && _selectedAnswer == option && option != _currentExercise.correctAnswer,
                onTap: () => _checkAnswer(option),
                accentColor: widget.accentColor,
              ),
            )),
      ],
    );
  }

  Widget _buildFillBlank() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 16),
        TextField(
          enabled: !_answered,
          decoration: InputDecoration(
            hintText: 'Type your answer here...',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.accentColor, width: 2),
            ),
          ),
          onSubmitted: (value) => _checkAnswer(value),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _answered
                ? null
                : () {
                    // Get text from field and check
                    _checkAnswer('submitted');
                  },
            style: FilledButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _answered ? 'Submitted' : 'Check Answer',
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

  Widget _buildSpeaking() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                widget.accentColor.withValues(alpha: 0.2),
                widget.accentColor.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.accentColor.withValues(alpha: 0.2),
                  boxShadow: _answered
                      ? [
                          BoxShadow(
                            color: (_isCorrect ? Colors.green : Colors.red)
                                .withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: widget.accentColor.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: Icon(
                  _answered
                      ? (_isCorrect ? Icons.check_rounded : Icons.close_rounded)
                      : Icons.mic_rounded,
                  size: 40,
                  color: _answered
                      ? (_isCorrect ? Colors.green : Colors.red)
                      : widget.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _answered
                    ? (_isCorrect ? 'Great pronunciation!' : 'Keep practicing!')
                    : 'Tap to speak',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _answered ? null : () => _checkAnswer('spoken'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _answered ? 'Completed' : 'Practice',
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

  Widget _buildMatching() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 16),
        ...(_currentExercise.pairs ?? []).map((pair) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        pair.values.first,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pair.values.last,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: widget.accentColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: () => _checkAnswer('matched'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              'Continue',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _AnswerOption(
                option: 'True',
                isSelected: _selectedAnswer == 'true',
                isCorrect: _answered && _currentExercise.correctAnswer == 'true',
                isWrong: _answered && _selectedAnswer == 'true' && _currentExercise.correctAnswer != 'true',
                onTap: () => _checkAnswer('true'),
                accentColor: widget.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _AnswerOption(
                option: 'False',
                isSelected: _selectedAnswer == 'false',
                isCorrect: _answered && _currentExercise.correctAnswer == 'false',
                isWrong: _answered && _selectedAnswer == 'false' && _currentExercise.correctAnswer != 'false',
                onTap: () => _checkAnswer('false'),
                accentColor: widget.accentColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWriting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_currentExercise.hint != null && !_answered)
          _buildHint(),
        const SizedBox(height: 16),
        TextField(
          enabled: !_answered,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Write your answer here...',
            filled: true,
            fillColor: AppColors.surfaceContainerHighest,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: widget.accentColor, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: FilledButton(
            onPressed: _answered ? null : () => _checkAnswer('written'),
            style: FilledButton.styleFrom(
              backgroundColor: widget.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Text(
              _answered ? 'Submitted' : 'Submit',
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

  Widget _buildHint() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline_rounded,
            size: 18,
            color: AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _currentExercise.hint!,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: AppColors.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _answered ? 'Nice work!' : 'Take your time',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  _answered ? 'Ready for the next one' : 'Think carefully before answering',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_answered)
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: _nextExercise,
                style: FilledButton.styleFrom(
                  backgroundColor: widget.accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _currentExerciseIndex < _exercises.length - 1 ? 'Next' : 'Finish',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      _currentExerciseIndex < _exercises.length - 1
                          ? Icons.arrow_forward_rounded
                          : Icons.check_rounded,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _getExerciseTypeLabel() {
    return switch (_currentExercise.type) {
      ExerciseType.multipleChoice => 'MULTIPLE CHOICE',
      ExerciseType.fillBlank => 'FILL IN THE BLANK',
      ExerciseType.speaking => 'SPEAKING EXERCISE',
      ExerciseType.matching => 'MATCHING',
      ExerciseType.trueFalse => 'TRUE OR FALSE',
      ExerciseType.writing => 'WRITING EXERCISE',
    };
  }
}

// ── Exercise Model ─────────────────────────────────────────────────────────────

class Exercise {
  final ExerciseType type;
  final String question;
  final String? content;
  final List<String>? options;
  final List<Map<String, String>>? pairs;
  final String? correctAnswer;
  final String? hint;

  const Exercise({
    required this.type,
    required this.question,
    this.content,
    this.options,
    this.pairs,
    this.correctAnswer,
    this.hint,
  });
}

// ── Answer Option Widget ───────────────────────────────────────────────────────

class _AnswerOption extends StatelessWidget {
  final String option;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  final Color accentColor;

  const _AnswerOption({
    required this.option,
    required this.isSelected,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor;
    Color backgroundColor;
    Color textColor;

    if (isCorrect) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      textColor = Colors.green.shade700;
    } else if (isWrong) {
      borderColor = Colors.red;
      backgroundColor = Colors.red.withValues(alpha: 0.1);
      textColor = Colors.red.shade700;
    } else if (isSelected) {
      borderColor = accentColor;
      backgroundColor = accentColor.withValues(alpha: 0.15);
      textColor = accentColor;
    } else {
      borderColor = AppColors.outlineVariant.withValues(alpha: 0.3);
      backgroundColor = AppColors.surfaceContainerHighest;
      textColor = AppColors.onSurface;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                option,
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ),
            if (isCorrect)
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 22),
            if (isWrong)
              const Icon(Icons.error_rounded, color: Colors.red, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Completion Dialog ──────────────────────────────────────────────────────────

class _CompletionDialog extends StatelessWidget {
  final Color accentColor;
  final int totalQuestions;
  final int correctAnswers;
  final VoidCallback onContinue;

  const _CompletionDialog({
    required this.accentColor,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = correctAnswers / totalQuestions;
    final isPerfect = percentage == 1.0;
    final isGood = percentage >= 0.7;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: isPerfect
                      ? [const Color(0xFFFFD700), const Color(0xFFFFA500)]
                      : isGood
                          ? [accentColor.withValues(alpha: 0.5), accentColor]
                          : [AppColors.outlineVariant, AppColors.onSurfaceVariant],
                ),
              ),
              child: Center(
                child: Text(
                  isPerfect ? '🏆' : isGood ? '🎉' : '💪',
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isPerfect ? 'Perfect!' : isGood ? 'Great Job!' : 'Keep Practicing!',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You got $correctAnswers out of $totalQuestions correct',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: onContinue,
                style: FilledButton.styleFrom(
                  backgroundColor: accentColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
