import 'package:equatable/equatable.dart';

import '../../domain/entities/roadmap.dart';
import '../../domain/entities/user_progress.dart';

enum ProgressStatus { initial, loading, loaded, error }

class ProgressState extends Equatable {
  final ProgressStatus status;
  final Roadmap? roadmap;
  final UserProgress? userProgress;
  final String? selectedLessonId;
  final String? selectedChapterId;
  final String? errorMessage;
  final Set<String> claimedRewards;
  final Set<String> expandedChapters;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.roadmap,
    this.userProgress,
    this.selectedLessonId,
    this.selectedChapterId,
    this.errorMessage,
    this.claimedRewards = const {},
    this.expandedChapters = const {},
  });

  ProgressState copyWith({
    ProgressStatus? status,
    Roadmap? roadmap,
    UserProgress? userProgress,
    String? selectedLessonId,
    String? selectedChapterId,
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
        errorMessage,
        claimedRewards,
        expandedChapters,
      ];
}
