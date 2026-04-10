import 'package:equatable/equatable.dart';
import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoadmap extends ProgressEvent {
  const LoadRoadmap({this.courseSelection, this.useCurrentSelection = false});

  final ProgressCourseSelection? courseSelection;
  final bool useCurrentSelection;

  @override
  List<Object?> get props => [courseSelection, useCurrentSelection];
}

class SelectLesson extends ProgressEvent {
  const SelectLesson(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class SelectChapter extends ProgressEvent {
  const SelectChapter(this.chapterId);
  final String chapterId;

  @override
  List<Object?> get props => [chapterId];
}

class StartLessonEvent extends ProgressEvent {
  const StartLessonEvent(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class CompleteLessonEvent extends ProgressEvent {
  const CompleteLessonEvent(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class ClaimReward extends ProgressEvent {
  const ClaimReward(this.lessonId);
  final String lessonId;

  @override
  List<Object?> get props => [lessonId];
}

class ExpandChapter extends ProgressEvent {
  const ExpandChapter(this.chapterId);
  final String chapterId;

  @override
  List<Object?> get props => [chapterId];
}

class CollapseChapter extends ProgressEvent {
  const CollapseChapter(this.chapterId);
  final String chapterId;

  @override
  List<Object?> get props => [chapterId];
}

class ExpandAllChapters extends ProgressEvent {}

class CollapseAllChapters extends ProgressEvent {}

class RegenerateRoadmap extends ProgressEvent {}

/// Re-applies user progress to the roadmap silently (no loading skeleton).
/// Used after completing a lesson to unlock the next lessons/chapters.
class RefreshProgress extends ProgressEvent {}
