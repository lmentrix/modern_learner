import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/bloc/voice_lesson_bloc.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/widgets/voice_lesson_widgets.dart';

class VoiceLessonPage extends StatefulWidget {
  const VoiceLessonPage({
    super.key,
    required this.lessonId,
  });

  final String lessonId;

  @override
  State<VoiceLessonPage> createState() => _VoiceLessonPageState();
}

class _VoiceLessonPageState extends State<VoiceLessonPage> {
  late final VoiceLessonBloc _bloc;
  final PageController _pageController = PageController();
  int _currentTabIndex = 0; // 0 = phrases, 1 = exercises

  @override
  void initState() {
    super.initState();
    _bloc = VoiceLessonBloc();
    _bloc.add(VoiceLessonLoadRequested(widget.lessonId));
  }

  @override
  void dispose() {
    _bloc.close();
    _pageController.dispose();
    super.dispose();
  }

  void _onPhraseSelected(int index) {
    _bloc.add(VoiceLessonPhraseSelected(index));
    setState(() => _currentTabIndex = 0);
  }

  void _onAnswerSelected(String exerciseId, int answerIndex) {
    _bloc.add(VoiceLessonAnswerSelected(exerciseId, answerIndex));
  }

  int _getCorrectAnswersCount() {
    final state = _bloc.state;
    if (state.lesson == null) return 0;
    int count = 0;
    for (final exercise in state.lesson!.exercises) {
      if (state.selectedAnswers[exercise.id] == exercise.correctIndex) {
        count++;
      }
    }
    return count;
  }

  double _getExercisesProgress() {
    final state = _bloc.state;
    if (state.lesson == null || state.lesson!.exercises.isEmpty) return 0.0;
    return state.selectedAnswers.length / state.lesson!.exercises.length;
  }

  void _submitExercises() {
    _bloc.add(const VoiceLessonExercisesSubmitted());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Score: ${_getCorrectAnswersCount()}/${_bloc.state.lesson?.exercises.length ?? 0}',
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.surfaceContainerHigh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: BlocBuilder<VoiceLessonBloc, VoiceLessonState>(
        builder: (context, state) {
          if (state.status == VoiceLessonStatus.loading) {
            return const _LoadingView();
          }

          if (state.status == VoiceLessonStatus.error || state.lesson == null) {
            return _ErrorView(onRetry: () {
              _bloc.add(VoiceLessonLoadRequested(widget.lessonId));
            });
          }

          final lesson = state.lesson!;

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: CustomScrollView(
              slivers: [
                _buildAppBar(lesson),
                SliverToBoxAdapter(child: _buildTabBar()),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 500,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) => setState(() => _currentTabIndex = index),
                      children: [
                        _buildPhrasesTab(state),
                        _buildExercisesTab(state),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            bottomNavigationBar: _buildBottomBar(state),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(dynamic lesson) {
    return SliverAppBar(
      expandedHeight: 180,
      pinned: true,
      backgroundColor: AppColors.surface,
      leading: IconButton(
        onPressed: () => Navigator.of(context).pop(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.arrow_back_ios_rounded,
            size: 16,
            color: AppColors.onSurface,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    lesson.accentColor.withValues(alpha: 0.3),
                    lesson.accentColor.withValues(alpha: 0.1),
                    AppColors.surface,
                  ],
                ),
              ),
            ),
            Positioned(
              right: -60,
              top: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      lesson.accentColor.withValues(alpha: 0.2),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 24,
              right: 24,
              bottom: 24,
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: lesson.accentColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(lesson.emoji, style: const TextStyle(fontSize: 30)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VOICE LESSON',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: lesson.accentColor,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lesson.title,
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    final lesson = _bloc.state.lesson;
    if (lesson == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildTabItem('Phrases', lesson.phrases.length, 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabItem('Exercises', lesson.exercises.length, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int count, int index) {
    final isSelected = _currentTabIndex == index;
    final lesson = _bloc.state.lesson;
    if (lesson == null) return const SizedBox.shrink();
    
    final color = lesson.accentColor;

    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
        setState(() => _currentTabIndex = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.15) : AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color.withValues(alpha: 0.5) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? color : AppColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhrasesTab(VoiceLessonState state) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        VoicePhraseSelector(
          phrases: state.lesson!.phrases,
          currentIndex: state.currentPhraseIndex,
          accentColor: state.lesson!.accentColor,
          onPhraseSelected: _onPhraseSelected,
        ),
        const SizedBox(height: 20),
        VoicePhraseCard(
          phrase: state.lesson!.phrases[state.currentPhraseIndex],
          accentColor: state.lesson!.accentColor,
          isPlaying: state.isPlaying,
          onPlayTap: () => _bloc.add(const VoiceLessonPlayToggled()),
        ),
        const SizedBox(height: 20),
        _buildNavigationButtons(state),
      ],
    );
  }

  Widget _buildNavigationButtons(VoiceLessonState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 48,
              child: OutlinedButton(
                onPressed: state.isFirstPhrase ? null : () {
                  _bloc.add(const VoiceLessonPreviousPhrase());
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.onSurface,
                  side: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_ios_rounded, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Previous',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: FilledButton(
                onPressed: state.isLastPhrase ? null : () {
                  _bloc.add(const VoiceLessonNextPhrase());
                },
                style: FilledButton.styleFrom(
                  backgroundColor: state.lesson!.accentColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Next',
                      style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesTab(VoiceLessonState state) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        VoiceExercisesProgress(
          answeredCount: state.selectedAnswers.length,
          totalCount: state.lesson!.exercises.length,
          accentColor: state.lesson!.accentColor,
          progress: _getExercisesProgress(),
        ),
        const SizedBox(height: 16),
        ...state.lesson!.exercises.map(
          (exercise) => VoiceExerciseCard(
            exercise: exercise,
            accentColor: state.lesson!.accentColor,
            selectedAnswer: state.selectedAnswers[exercise.id],
            showResult: state.exercisesSubmitted,
            onAnswerSelected: (index) => _onAnswerSelected(exercise.id, index),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(VoiceLessonState state) {
    final canSubmit = state.allExercisesAnswered && !state.exercisesSubmitted;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant.withValues(alpha: 0.2), width: 1),
        ),
      ),
      child: Row(
        children: [
          if (_currentTabIndex == 0) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${state.currentPhraseIndex + 1}/${state.lesson!.phrases.length}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    'Phrase ${state.currentPhraseIndex + 1}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (_currentTabIndex == 1) ...[
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.exercisesSubmitted
                        ? 'Completed!'
                        : '${state.selectedAnswers.length}/${state.lesson!.exercises.length}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Text(
                    state.exercisesSubmitted ? 'Great job!' : 'exercises answered',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(width: 16),
          if (_currentTabIndex == 1)
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: canSubmit ? _submitExercises : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canSubmit ? state.lesson!.accentColor : AppColors.surfaceContainerHighest,
                  foregroundColor: canSubmit ? Colors.white : AppColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      state.exercisesSubmitted ? 'Done' : 'Submit',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!state.exercisesSubmitted) ...[
                      const SizedBox(width: 6),
                      const Icon(Icons.check_rounded, size: 18),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Loading View ──────────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}

// ── Error View ────────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              'Failed to load lesson',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 48,
              child: FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: Text('Retry', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
