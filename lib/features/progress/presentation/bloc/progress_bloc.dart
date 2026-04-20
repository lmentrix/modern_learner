import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart'
    as domain;
import 'package:modern_learner_production/features/progress/domain/usecases/start_lesson.dart'
    as start;
import 'package:modern_learner_production/features/progress/domain/usecases/regenerate_roadmap.dart'
    as regen;
import 'package:modern_learner_production/features/progress/domain/usecases/get_roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/get_user_progress.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_event.dart';
import 'package:modern_learner_production/features/progress/presentation/bloc/progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  ProgressBloc({
    required this.getRoadmap,
    required this.getUserProgress,
    required this.completeLesson,
    required this.startLesson,
    required this.regenerateRoadmap,
  }) : super(const ProgressState()) {
    on<LoadRoadmap>(_onLoadRoadmap);
    on<RefreshProgress>(_onRefreshProgress);
    on<RegenerateRoadmap>(_onRegenerateRoadmap);
    on<SelectLesson>(_onSelectLesson);
    on<SelectChapter>(_onSelectChapter);
    on<StartLessonEvent>(_onStartLesson);
    on<CompleteLessonEvent>(_onCompleteLesson);
    on<ClaimReward>(_onClaimReward);
    on<ExpandChapter>(_onExpandChapter);
    on<CollapseChapter>(_onCollapseChapter);
    on<ExpandAllChapters>(_onExpandAllChapters);
    on<CollapseAllChapters>(_onCollapseAllChapters);
  }
  final GetRoadmap getRoadmap;
  final GetUserProgress getUserProgress;
  final domain.CompleteLesson completeLesson;
  final start.StartLesson startLesson;
  final regen.RegenerateRoadmap regenerateRoadmap;

  Future<void> _onLoadRoadmap(
    LoadRoadmap event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading));

    final courseSelection = event.useCurrentSelection
        ? state.courseSelection
        : event.courseSelection;

    try {
      final results = await Future.wait([
        getRoadmap(courseSelection: courseSelection),
        getUserProgress(),
      ]);

      final roadmap = results[0] as Roadmap;
      // Auto-expand the first available chapter
      final firstAvailableChapter = roadmap.chapters.firstWhere(
        (c) => c.lessons.any((l) => l.status != LessonStatus.locked),
        orElse: () => roadmap.chapters.first,
      );

      emit(
        state.copyWith(
          status: ProgressStatus.loaded,
          roadmap: roadmap,
          userProgress: results[1] as UserProgress,
          courseSelection: courseSelection,
          expandedChapters: {firstAvailableChapter.id},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProgressStatus.error,
          errorMessage: e.toString(),
          courseSelection: courseSelection,
        ),
      );
    }
  }

  void _onSelectLesson(SelectLesson event, Emitter<ProgressState> emit) {
    emit(state.copyWith(selectedLessonId: event.lessonId));
  }

  void _onSelectChapter(SelectChapter event, Emitter<ProgressState> emit) {
    emit(state.copyWith(selectedChapterId: event.chapterId));
  }

  Future<void> _onStartLesson(
    StartLessonEvent event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      await startLesson(event.lessonId);
      // Navigate to lesson screen (handled by presentation layer)
    } catch (e) {
      emit(
        state.copyWith(
          status: ProgressStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCompleteLesson(
    CompleteLessonEvent event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      await completeLesson(event.lessonId);
      // Show celebration (handled by presentation layer)
    } catch (e) {
      emit(
        state.copyWith(
          status: ProgressStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Silently re-applies user progress without showing the loading skeleton.
  /// Preserves the current expanded-chapters set so the UI doesn't jump.
  Future<void> _onRefreshProgress(
    RefreshProgress event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      final results = await Future.wait([
        getRoadmap(courseSelection: state.courseSelection),
        getUserProgress(),
      ]);
      emit(
        state.copyWith(
          roadmap: results[0] as Roadmap,
          userProgress: results[1] as UserProgress,
        ),
      );
    } catch (_) {
      // Ignore — progress page keeps working with the previous roadmap.
    }
  }

  Future<void> _onRegenerateRoadmap(
    RegenerateRoadmap event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.generating));
    try {
      final results = await Future.wait([
        regenerateRoadmap(courseSelection: state.courseSelection),
        getUserProgress(),
      ]);
      final roadmap = results[0] as Roadmap;
      final firstAvailable = roadmap.chapters.firstWhere(
        (c) => c.lessons.any((l) => l.status != LessonStatus.locked),
        orElse: () => roadmap.chapters.first,
      );
      emit(
        state.copyWith(
          status: ProgressStatus.loaded,
          roadmap: roadmap,
          userProgress: results[1] as UserProgress,
          courseSelection: state.courseSelection,
          expandedChapters: {firstAvailable.id},
          claimedRewards: {},
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProgressStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onClaimReward(ClaimReward event, Emitter<ProgressState> emit) {
    emit(
      state.copyWith(claimedRewards: {...state.claimedRewards, event.lessonId}),
    );
  }

  void _onExpandChapter(ExpandChapter event, Emitter<ProgressState> emit) {
    emit(
      state.copyWith(
        expandedChapters: {...state.expandedChapters, event.chapterId},
      ),
    );
  }

  void _onCollapseChapter(CollapseChapter event, Emitter<ProgressState> emit) {
    emit(
      state.copyWith(
        expandedChapters: {...state.expandedChapters}..remove(event.chapterId),
      ),
    );
  }

  void _onExpandAllChapters(
    ExpandAllChapters event,
    Emitter<ProgressState> emit,
  ) {
    final roadmap = state.roadmap;
    if (roadmap == null) return;

    emit(
      state.copyWith(
        expandedChapters: {for (final chapter in roadmap.chapters) chapter.id},
      ),
    );
  }

  void _onCollapseAllChapters(
    CollapseAllChapters event,
    Emitter<ProgressState> emit,
  ) {
    emit(state.copyWith(expandedChapters: {}));
  }
}
