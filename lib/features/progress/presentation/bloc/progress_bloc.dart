import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/roadmap.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/usecases/complete_lesson.dart' as domain;
import '../../domain/usecases/start_lesson.dart' as start;
import '../../domain/usecases/get_roadmap.dart';
import '../../domain/usecases/get_user_progress.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetRoadmap getRoadmap;
  final GetUserProgress getUserProgress;
  final domain.CompleteLesson completeLesson;
  final start.StartLesson startLesson;

  ProgressBloc({
    required this.getRoadmap,
    required this.getUserProgress,
    required this.completeLesson,
    required this.startLesson,
  }) : super(const ProgressState()) {
    on<LoadRoadmap>(_onLoadRoadmap);
    on<SelectLesson>(_onSelectLesson);
    on<SelectChapter>(_onSelectChapter);
    on<StartLessonEvent>(_onStartLesson);
    on<CompleteLessonEvent>(_onCompleteLesson);
    on<ClaimReward>(_onClaimReward);
    on<ExpandChapter>(_onExpandChapter);
    on<CollapseChapter>(_onCollapseChapter);
  }

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

  @override
  Future<void> close() {
    return super.close();
  }
}
