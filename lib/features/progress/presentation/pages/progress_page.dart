import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:modern_learner_production/core/di/injection.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/lesson_detail/presentation/pages/lesson_detail_page.dart' as detail;
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart' as domain;
import 'package:modern_learner_production/features/progress/domain/usecases/start_lesson.dart' as start;
import 'package:modern_learner_production/features/progress/domain/usecases/get_roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/get_user_progress.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_bloc.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_event.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_state.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/roadmap_view.dart';
import 'package:modern_learner_production/features/progress/presentation/widgets/progress_stats_header.dart';

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
                    const Icon(
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
    final progress = isInProgress ? 0.5 : isCompleted ? 1.0 : 0.0;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => detail.LessonDetailPage(
          type: _mapLessonType(lesson.type),
          title: lesson.title,
          subtitle: '${chapter.title} · ${chapter.chapterNumber}',
          emoji: _getLessonEmoji(lesson.type),
          duration: '15 min',
          accentColor: _getLessonColor(lesson.type),
          progress: progress,
          totalLessons: chapter.lessons.length,
          completedLessons: isCompleted ? chapter.lessons.length : (progress * chapter.lessons.length).round(),
          learningObjectives: chapter.skills,
          sections: chapter.lessons
              .map(
                (l) => detail.LessonSection(
                  title: l.title,
                  emoji: _getLessonEmoji(l.type),
                  duration: '10 min',
                  lessonCount: 1,
                  status: _mapLessonStatus(l.status),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  detail.LessonType _mapLessonType(LessonType type) {
    return switch (type) {
      LessonType.vocabulary => detail.LessonType.continueLearning,
      LessonType.grammar => detail.LessonType.school,
      LessonType.exercise => detail.LessonType.voice,
      LessonType.listening => detail.LessonType.continueLearning,
      LessonType.reading => detail.LessonType.continueLearning,
      LessonType.conversation => detail.LessonType.voice,
    };
  }

  detail.LessonSectionStatus _mapLessonStatus(LessonStatus status) {
    return switch (status) {
      LessonStatus.locked => detail.LessonSectionStatus.locked,
      LessonStatus.available => detail.LessonSectionStatus.next,
      LessonStatus.inProgress => detail.LessonSectionStatus.current,
      LessonStatus.completed => detail.LessonSectionStatus.completed,
    };
  }

  String _getLessonEmoji(LessonType type) {
    return switch (type) {
      LessonType.vocabulary => '📚',
      LessonType.grammar => '📝',
      LessonType.exercise => '💪',
      LessonType.listening => '🎧',
      LessonType.reading => '📖',
      LessonType.conversation => '💬',
    };
  }

  Color _getLessonColor(LessonType type) {
    return switch (type) {
      LessonType.vocabulary => AppColors.primary,
      LessonType.grammar => AppColors.primary,
      LessonType.exercise => AppColors.tertiary,
      LessonType.listening => AppColors.secondary,
      LessonType.reading => AppColors.secondary,
      LessonType.conversation => AppColors.tertiary,
    };
  }
}
