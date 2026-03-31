import 'package:equatable/equatable.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadRoadmap extends ProgressEvent {}

class SelectLesson extends ProgressEvent {
  final String lessonId;

  const SelectLesson(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class SelectChapter extends ProgressEvent {
  final String chapterId;

  const SelectChapter(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

class StartLessonEvent extends ProgressEvent {
  final String lessonId;

  const StartLessonEvent(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class CompleteLessonEvent extends ProgressEvent {
  final String lessonId;

  const CompleteLessonEvent(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class ClaimReward extends ProgressEvent {
  final String lessonId;

  const ClaimReward(this.lessonId);

  @override
  List<Object?> get props => [lessonId];
}

class ExpandChapter extends ProgressEvent {
  final String chapterId;

  const ExpandChapter(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}

class CollapseChapter extends ProgressEvent {
  final String chapterId;

  const CollapseChapter(this.chapterId);

  @override
  List<Object?> get props => [chapterId];
}
