import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/bloc/school_lesson_bloc.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/widgets/school_lesson_widgets.dart';

class SchoolLessonPage extends StatefulWidget {
  const SchoolLessonPage({
    super.key,
    required this.lessonId,
  });

  final String lessonId;

  @override
  State<SchoolLessonPage> createState() => _SchoolLessonPageState();
}

class _SchoolLessonPageState extends State<SchoolLessonPage> {
  late final SchoolLessonBloc _bloc;
  int _currentTabIndex = 0; // 0 = sections, 1 = quiz

  @override
  void initState() {
    super.initState();
    _bloc = SchoolLessonBloc();
    _bloc.add(SchoolLessonLoadRequested(widget.lessonId));
  }

  @override
  void dispose() {
    _bloc.close();
    super.dispose();
  }

  void _onSectionToggled(String sectionId) {
    _bloc.add(SchoolLessonSectionToggled(sectionId));
  }

  void _onAnswerSelected(String questionId, int answerIndex) {
    _bloc.add(SchoolLessonAnswerSelected(questionId, answerIndex));
  }

  void _submitQuiz() {
    _bloc.add(const SchoolLessonQuizSubmitted());
    final state = _bloc.state;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Score: ${state.score}/${state.lesson?.quiz.length ?? 0}'),
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
      child: BlocBuilder<SchoolLessonBloc, SchoolLessonState>(
        builder: (context, state) {
          if (state.status == SchoolLessonStatus.loading) {
            return const _LoadingView();
          }

          if (state.status == SchoolLessonStatus.error || state.lesson == null) {
            return _ErrorView(onRetry: () {
              _bloc.add(SchoolLessonLoadRequested(widget.lessonId));
            });
          }

          final lesson = state.lesson!;

          return Scaffold(
            backgroundColor: AppColors.surface,
            body: CustomScrollView(
              slivers: [
                _buildAppBar(lesson),
                SliverToBoxAdapter(child: _buildHeader(lesson)),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
                SliverToBoxAdapter(child: _buildTabBar()),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height - 280,
                    child: PageView(
                      onPageChanged: (index) => setState(() => _currentTabIndex = index),
                      children: [
                        _buildSectionsTab(state),
                        _buildQuizTab(state),
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
                    lesson.color.withValues(alpha: 0.3),
                    lesson.color.withValues(alpha: 0.1),
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
                      lesson.color.withValues(alpha: 0.2),
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
                      color: lesson.color.withValues(alpha: 0.2),
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
                          'SCHOOL LESSON',
                          style: GoogleFonts.inter(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: lesson.color,
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

  Widget _buildHeader(dynamic lesson) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.description,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.onSurfaceVariant,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatChip('⏱️', lesson.duration),
              const SizedBox(width: 8),
              _buildStatChip('📊', lesson.difficulty),
              const SizedBox(width: 8),
              _buildStatChip('📚', '${lesson.sections.length} sections'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _bloc.state.lesson?.color.withValues(alpha: 0.15) ?? AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _bloc.state.lesson?.color ?? AppColors.onSurfaceVariant,
            ),
          ),
        ],
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
            child: _buildTabItem('Sections', lesson.sections.length, 0),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildTabItem('Quiz', lesson.quiz.length, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int count, int index) {
    final isSelected = _currentTabIndex == index;
    final lesson = _bloc.state.lesson;
    if (lesson == null) return const SizedBox.shrink();
    
    final color = lesson.color;

    return GestureDetector(
      onTap: () => setState(() => _currentTabIndex = index),
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

  Widget _buildSectionsTab(SchoolLessonState state) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: state.lesson!.sections.length,
      itemBuilder: (context, index) {
        final section = state.lesson!.sections[index];
        final isExpanded = state.expandedSectionIds.contains(section.id);
        return SchoolSectionCard(
          section: section,
          color: state.lesson!.color,
          isExpanded: isExpanded,
          onTap: () => _onSectionToggled(section.id),
        );
      },
    );
  }

  Widget _buildQuizTab(SchoolLessonState state) {
    return ListView(
      children: [
        const SizedBox(height: 16),
        if (state.quizSubmitted)
          SchoolScoreCard(
            score: state.score ?? 0,
            totalQuestions: state.lesson!.quiz.length,
            color: state.lesson!.color,
          )
        else
          SchoolQuizProgress(
            answeredCount: state.selectedAnswers.length,
            totalCount: state.lesson!.quiz.length,
            color: state.lesson!.color,
          ),
        const SizedBox(height: 16),
        ...state.lesson!.quiz.map(
          (question) => SchoolQuizCard(
            question: question,
            color: state.lesson!.color,
            selectedAnswer: state.selectedAnswers[question.id],
            showResult: state.quizSubmitted,
            onAnswerSelected: (index) => _onAnswerSelected(question.id, index),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar(SchoolLessonState state) {
    final canSubmit = state.allAnswered && !state.quizSubmitted;

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
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _currentTabIndex == 0
                      ? '${state.expandedSectionIds.length}/${state.lesson!.sections.length} sections'
                      : state.quizSubmitted
                          ? 'Completed!'
                          : '${state.selectedAnswers.length}/${state.lesson!.quiz.length}',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onSurface,
                  ),
                ),
                Text(
                  _currentTabIndex == 0
                      ? 'sections expanded'
                      : state.quizSubmitted
                          ? 'Great job!'
                          : 'questions answered',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (_currentTabIndex == 1 && !state.quizSubmitted)
            SizedBox(
              height: 50,
              child: FilledButton(
                onPressed: canSubmit ? _submitQuiz : null,
                style: FilledButton.styleFrom(
                  backgroundColor: canSubmit ? state.lesson!.color : AppColors.surfaceContainerHighest,
                  foregroundColor: canSubmit ? Colors.white : AppColors.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Submit',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.check_rounded, size: 18),
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: const Center(
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
