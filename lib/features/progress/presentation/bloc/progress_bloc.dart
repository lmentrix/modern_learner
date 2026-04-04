import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';
import 'package:modern_learner_production/features/progress/domain/usecases/complete_lesson.dart' as domain;
import 'package:modern_learner_production/features/progress/domain/usecases/start_lesson.dart' as start;
import 'package:modern_learner_production/features/progress/domain/usecases/regenerate_roadmap.dart' as regen;
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
    on<RegenerateRoadmap>(_onRegenerateRoadmap);
    on<SelectLesson>(_onSelectLesson);
    on<SelectChapter>(_onSelectChapter);
    on<StartLessonEvent>(_onStartLesson);
    on<CompleteLessonEvent>(_onCompleteLesson);
    on<ClaimReward>(_onClaimReward);
    on<ExpandChapter>(_onExpandChapter);
    on<CollapseChapter>(_onCollapseChapter);
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

    try {
      final results = await Future.wait([
        getRoadmap(),
        getUserProgress(),
      ]);

      final roadmap = results[0] as Roadmap;
      // Auto-expand the first available chapter
      final firstAvailableChapter = roadmap.chapters.firstWhere(
        (c) => c.lessons.any((l) => l.status != LessonStatus.locked),
        orElse: () => roadmap.chapters.first,
      );

      emit(state.copyWith(
        status: ProgressStatus.loaded,
        roadmap: roadmap,
        userProgress: results[1] as UserProgress,
        expandedChapters: {firstAvailableChapter.id},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      ));
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
      emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      ));
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
      emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRegenerateRoadmap(
    RegenerateRoadmap event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.generating));
    try {
      final results = await Future.wait([regenerateRoadmap(), getUserProgress()]);
      final roadmap = results[0] as Roadmap;
      final firstAvailable = roadmap.chapters.firstWhere(
        (c) => c.lessons.any((l) => l.status != LessonStatus.locked),
        orElse: () => roadmap.chapters.first,
      );
      emit(state.copyWith(
        status: ProgressStatus.loaded,
        roadmap: roadmap,
        userProgress: results[1] as UserProgress,
        expandedChapters: {firstAvailable.id},
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onClaimReward(ClaimReward event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      claimedRewards: {...state.claimedRewards, event.lessonId},
    ));
  }

  void _onExpandChapter(ExpandChapter event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      expandedChapters: {...state.expandedChapters, event.chapterId},
    ));
  }

  void _onCollapseChapter(CollapseChapter event, Emitter<ProgressState> emit) {
    emit(state.copyWith(
      expandedChapters: {...state.expandedChapters}..remove(event.chapterId),
    ));
  }

}
