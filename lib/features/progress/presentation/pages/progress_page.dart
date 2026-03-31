import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart' as domain;
import 'package:modern_learner_production/features/progress/domain/usecases/start_lesson.dart' as start;
import 'package:modern_learner_production/features/progress/domain/usecases/get_roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/get_user_progress.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_event.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_state.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/celebration_overlay.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/roadmap_view.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/progress_stats_header.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/lesson_detail_sheet.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  late ProgressBloc _bloc;

  @override
  void initState() {
    super.initState();
    _bloc = ProgressBloc(
      getRoadmap: GetRoadmap(getIt()),
      getUserProgress: GetUserProgress(getIt()),
      completeLesson: domain.CompleteLesson(getIt()),
      startLesson: start.StartLesson(getIt()),
    );
    _bloc.add(LoadRoadmap());
  }

  @override
  void dispose() {
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
            if (state.status == ProgressStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              );
            }

            if (state.status == ProgressStatus.error) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load roadmap',
                      style: GoogleFonts.inter(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _bloc.add(LoadRoadmap()),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (state.roadmap == null || state.userProgress == null) {
              return const SizedBox.shrink();
            }

            return Column(
              children: [
                ProgressStatsHeader(progress: state.userProgress!),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: AppColors.outlineVariant.withValues(alpha: 0.25),
                ),
                Expanded(
                  child: RoadmapView(
                    roadmap: state.roadmap!,
                    userProgress: state.userProgress!,
                    selectedLessonId: state.selectedLessonId,
                    expandedChapters: state.expandedChapters,
                    onLessonTap: (lessonId) {
                      _bloc.add(SelectLesson(lessonId));
                      _showLessonDetail(lessonId, state);
                    },
                    onChapterTap: (chapterId) {
                      _bloc.add(SelectChapter(chapterId));
                    },
                    onChapterToggle: (chapterId, isExpanded) {
                      if (isExpanded) {
                        _bloc.add(ExpandChapter(chapterId));
                      } else {
                        _bloc.add(CollapseChapter(chapterId));
                      }
                    },
                  ),
                ),
              ],
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
    final isCompleted = state.userProgress!.completedLessons.containsKey(lessonId);
    final isInProgress = state.userProgress!.lessonProgress.containsKey(lessonId);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return LessonDetailSheet(
          chapter: chapter,
          lesson: lesson,
          canClaim: isCompleted && !isInProgress,
          onStart: () {
            Navigator.pop(context);
            _bloc.add(StartLessonEvent(lessonId));
            _showLessonCompleteCelebration();
          },
          onClaim: () {
            Navigator.pop(context);
            _bloc.add(CompleteLessonEvent(lessonId));
            _showLessonCompleteCelebration();
          },
        );
      },
    );
  }

  void _showLessonCompleteCelebration() {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return CelebrationOverlay(
          xpGained: 100,
          gemsGained: 12,
          onComplete: () => Navigator.pop(context),
        );
      },
    );
  }
}
