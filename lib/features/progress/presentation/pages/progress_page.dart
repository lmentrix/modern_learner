import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/presentation/pages/lesson_content_page.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart'
    as domain;
import 'package:modern_learner_production/features/progress/domain/usecases/start_lesson.dart'
    as start;
import 'package:modern_learner_production/features/progress/domain/usecases/regenerate_roadmap.dart'
    as regen;
import 'package:modern_learner_production/features/progress/domain/usecases/get_roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/get_user_progress.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_event.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_state.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/roadmap_view.dart';
import 'package:modern_learner_production/features/progress/service/progress_navigation_state.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key, this.initialCourseSelection});

  final ProgressCourseSelection? initialCourseSelection;

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage>
    with SingleTickerProviderStateMixin {
  late ProgressBloc _bloc;
  late ProgressNavigationState _navState;
  final ScrollController _scrollController = ScrollController();
  String? _pendingChapterId;
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();

    _bloc = ProgressBloc(
      getRoadmap: GetRoadmap(getIt()),
      getUserProgress: GetUserProgress(getIt()),
      completeLesson: domain.CompleteLesson(getIt()),
      startLesson: start.StartLesson(getIt()),
      regenerateRoadmap: regen.RegenerateRoadmap(getIt()),
    );
    _bloc.add(LoadRoadmap(courseSelection: widget.initialCourseSelection));

    _navState = getIt<ProgressNavigationState>();
    _navState.addListener(_handleNavigationRequest);
  }

  @override
  void didUpdateWidget(covariant ProgressPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.initialCourseSelection != widget.initialCourseSelection) {
      _bloc.add(LoadRoadmap(courseSelection: widget.initialCourseSelection));
    }
  }

  void _handleNavigationRequest() {
    if (_navState.hasSelection && _pendingChapterId == null) {
      _pendingChapterId = _navState.selectedChapterId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToChapter(_pendingChapterId!);
      });
    }
  }

  void _scrollToChapter(String chapterId) {
    _navState.clearSelection();
    _pendingChapterId = null;
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _navState.removeListener(_handleNavigationRequest);
    _scrollController.dispose();
    _shimmerController.dispose();
    _bloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _bloc,
      child: Container(
        color: AppColors.surface,
        child: BlocBuilder<ProgressBloc, ProgressState>(
          builder: (context, state) {
            if (state.status == ProgressStatus.generating) {
              return _GeneratingView(shimmer: _shimmerController);
            }

            if (state.status == ProgressStatus.loading) {
              return _LoadingView(shimmer: _shimmerController);
            }

            if (state.status == ProgressStatus.error) {
              return _ErrorView(
                message: state.errorMessage,
                onRetry: () =>
                    _bloc.add(const LoadRoadmap(useCurrentSelection: true)),
              );
            }

            if (state.roadmap == null || state.userProgress == null) {
              return const SizedBox.shrink();
            }

            return RoadmapView(
              roadmap: state.roadmap!,
              userProgress: state.userProgress!,
              selectedLessonId: state.selectedLessonId,
              expandedChapters: state.expandedChapters,
              scrollController: _scrollController,
              onLessonTap: (lessonId) {
                _bloc.add(SelectLesson(lessonId));
                _showLessonDetail(lessonId, state);
              },
              onChapterTap: (chapterId) => _bloc.add(SelectChapter(chapterId)),
              onChapterToggle: (chapterId, isExpanded) {
                if (isExpanded) {
                  _bloc.add(ExpandChapter(chapterId));
                } else {
                  _bloc.add(CollapseChapter(chapterId));
                }
              },
              onExpandAll: () => _bloc.add(ExpandAllChapters()),
              onCollapseAll: () => _bloc.add(CollapseAllChapters()),
              onRegenerate: () => _bloc.add(RegenerateRoadmap()),
              onRefresh: () async =>
                  _bloc.add(const LoadRoadmap(useCurrentSelection: true)),
            );
          },
        ),
      ),
    );
  }

  void _showLessonDetail(String lessonId, ProgressState state) {
    final chapter = state.roadmap!.chapters.firstWhere(
      (c) => c.lessons.any((l) => l.id == lessonId),
    );
    final lesson = chapter.lessons.firstWhere((l) => l.id == lessonId);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonContentPage(
          lesson: lesson,
          chapter: chapter,
          roadmap: state.roadmap!,
          onLessonCompleted: () => _bloc.add(RefreshProgress()),
        ),
      ),
    );
  }
}

// ── Loading skeleton ─────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView({required this.shimmer});
  final AnimationController shimmer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SkeletonBox(
              shimmer: shimmer,
              width: double.infinity,
              height: 160,
              radius: 20,
            ),
            const SizedBox(height: 20),
            for (int i = 0; i < 4; i++) ...[
              _SkeletonBox(
                shimmer: shimmer,
                width: double.infinity,
                height: 100,
                radius: 16,
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

// ── AI Generating view ───────────────────────────────────────────────────────

class _GeneratingView extends StatelessWidget {
  const _GeneratingView({required this.shimmer});
  final AnimationController shimmer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: shimmer,
              builder: (context, _) {
                return Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: SweepGradient(
                      startAngle: shimmer.value * 6.28,
                      colors: const [
                        AppColors.primary,
                        AppColors.secondary,
                        AppColors.tertiary,
                        AppColors.primary,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('✨', style: TextStyle(fontSize: 32)),
                  ),
                );
              },
            ),
            const SizedBox(height: 28),
            Text(
              'Generating your roadmap',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'AI is crafting a personalised learning path just for you…',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 200),
              child: LinearProgressIndicator(
                backgroundColor: AppColors.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 4,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error view ───────────────────────────────────────────────────────────────

class _ErrorView extends StatelessWidget {
  const _ErrorView({this.message, required this.onRetry});
  final String? message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load roadmap',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.onSurface,
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton box ─────────────────────────────────────────────────────────────

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.shimmer,
    required this.width,
    required this.height,
    this.radius = 8,
  });
  final AnimationController shimmer;
  final double width;
  final double height;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: shimmer,
      builder: (context, _) {
        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            gradient: LinearGradient(
              begin: Alignment(-1 + shimmer.value * 2, 0),
              end: Alignment(shimmer.value * 2, 0),
              colors: [
                AppColors.surfaceContainerHigh,
                AppColors.surfaceContainerHighest,
                AppColors.surfaceContainerHigh,
              ],
            ),
          ),
        );
      },
    );
  }
}
