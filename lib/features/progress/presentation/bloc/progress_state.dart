import 'package:equatable/equatable.dart';

import 'package:modern_learner_production/features/progress/domain/entities/progress_course_selection.dart';
import 'package:modern_learner_production/features/progress/domain/entities/roadmap.dart';
import 'package:modern_learner_production/features/progress/domain/entities/user_progress.dart';

enum ProgressStatus { initial, loading, generating, loaded, error }

const _progressNoChange = Object();

class ProgressState extends Equatable {
  const ProgressState({
    this.status = ProgressStatus.initial,
    this.roadmap,
    this.userProgress,
    this.selectedLessonId,
    this.selectedChapterId,
    this.courseSelection,
    this.errorMessage,
    this.claimedRewards = const {},
    this.expandedChapters = const {},
  });
  final ProgressStatus status;
  final Roadmap? roadmap;
  final UserProgress? userProgress;
  final String? selectedLessonId;
  final String? selectedChapterId;
  final ProgressCourseSelection? courseSelection;
  final String? errorMessage;
  final Set<String> claimedRewards;
  final Set<String> expandedChapters;

  ProgressState copyWith({
    ProgressStatus? status,
    Roadmap? roadmap,
    UserProgress? userProgress,
    String? selectedLessonId,
    String? selectedChapterId,
    Object? courseSelection = _progressNoChange,
    String? errorMessage,
    Set<String>? claimedRewards,
    Set<String>? expandedChapters,
  }) {
    return ProgressState(
      status: status ?? this.status,
      roadmap: roadmap ?? this.roadmap,
      userProgress: userProgress ?? this.userProgress,
      selectedLessonId: selectedLessonId ?? this.selectedLessonId,
      selectedChapterId: selectedChapterId ?? this.selectedChapterId,
      courseSelection: courseSelection == _progressNoChange
          ? this.courseSelection
          : courseSelection as ProgressCourseSelection?,
      errorMessage: errorMessage ?? this.errorMessage,
      claimedRewards: claimedRewards ?? {...this.claimedRewards},
      expandedChapters: expandedChapters ?? {...this.expandedChapters},
    );
  }

  @override
  List<Object?> get props => [
    status,
    roadmap,
    userProgress,
    selectedLessonId,
    selectedChapterId,
    courseSelection,
    errorMessage,
    claimedRewards,
    expandedChapters,
  ];
}
