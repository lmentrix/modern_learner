import 'package:equatable/equatable.dart';

import '../../domain/entities/skill_tree.dart';
import '../../domain/entities/user_progress.dart';

enum ProgressStatus { initial, loading, loaded, error }

class ProgressState extends Equatable {
  final ProgressStatus status;
  final SkillTree? skillTree;
  final UserProgress? userProgress;
  final String? selectedNodeId;
  final String? errorMessage;
  final Set<String> claimedRewards;

  const ProgressState({
    this.status = ProgressStatus.initial,
    this.skillTree,
    this.userProgress,
    this.selectedNodeId,
    this.errorMessage,
    this.claimedRewards = const {},
  });

  ProgressState copyWith({
    ProgressStatus? status,
    SkillTree? skillTree,
    UserProgress? userProgress,
    String? selectedNodeId,
    String? errorMessage,
    Set<String>? claimedRewards,
  }) {
    return ProgressState(
      status: status ?? this.status,
      skillTree: skillTree ?? this.skillTree,
      userProgress: userProgress ?? this.userProgress,
      selectedNodeId: selectedNodeId ?? this.selectedNodeId,
      errorMessage: errorMessage ?? this.errorMessage,
      claimedRewards: claimedRewards ?? {...this.claimedRewards},
    );
  }

  @override
  List<Object?> get props => [
        status,
        skillTree,
        userProgress,
        selectedNodeId,
        errorMessage,
        claimedRewards,
      ];
}
