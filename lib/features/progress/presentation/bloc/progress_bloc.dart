import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/complete_node.dart' as domain;
import '../../domain/usecases/get_skill_tree.dart';
import '../../domain/usecases/get_user_progress.dart';
import 'progress_event.dart';
import 'progress_state.dart';

class ProgressBloc extends Bloc<ProgressEvent, ProgressState> {
  final GetSkillTree getSkillTree;
  final GetUserProgress getUserProgress;
  final domain.CompleteNode completeNode;

  StreamSubscription? _progressSubscription;

  ProgressBloc({
    required this.getSkillTree,
    required this.getUserProgress,
    required this.completeNode,
  }) : super(const ProgressState()) {
    on<LoadProgress>(_onLoadProgress);
    on<SelectNode>(_onSelectNode);
    on<StartNode>(_onStartNode);
    on<CompleteNodeEvent>(_onCompleteNode);
    on<ClaimReward>(_onClaimReward);

    // Listen to progress stream
    getUserProgress.stream().listen((progress) {
      if (!isClosed) {
        add(_ProgressUpdated(progress));
      }
    });
  }

  Future<void> _onLoadProgress(
    LoadProgress event,
    Emitter<ProgressState> emit,
  ) async {
    emit(state.copyWith(status: ProgressStatus.loading));

    try {
      final results = await Future.wait([
        getSkillTree(),
        getUserProgress(),
      ]);

      emit(state.copyWith(
        status: ProgressStatus.loaded,
        skillTree: results[0] as dynamic,
        userProgress: results[1] as dynamic,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProgressStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onSelectNode(SelectNode event, Emitter<ProgressState> emit) {
    emit(state.copyWith(selectedNodeId: event.nodeId));
  }

  void _onProgressUpdated(_ProgressUpdated event, Emitter<ProgressState> emit) {
    emit(state.copyWith(userProgress: event.progress));
  }

  Future<void> _onStartNode(
    StartNode event,
    Emitter<ProgressState> emit,
  ) async {
    // Navigate to lesson screen (handled by presentation layer)
  }

  Future<void> _onCompleteNode(
    CompleteNodeEvent event,
    Emitter<ProgressState> emit,
  ) async {
    try {
      await completeNode(event.nodeId);
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
      claimedRewards: {...state.claimedRewards, event.nodeId},
    ));
  }

  @override
  Future<void> close() {
    _progressSubscription?.cancel();
    return super.close();
  }
}

class _ProgressUpdated extends ProgressEvent {
  final dynamic progress;

  const _ProgressUpdated(this.progress);

  @override
  List<Object?> get props => [progress];
}

class CompleteNodeEvent extends ProgressEvent {
  final String nodeId;

  const CompleteNodeEvent(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}
