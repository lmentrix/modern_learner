import 'package:equatable/equatable.dart';

import '../../domain/entities/skill_tree.dart';
import '../../domain/entities/user_progress.dart';

abstract class ProgressEvent extends Equatable {
  const ProgressEvent();

  @override
  List<Object?> get props => [];
}

class LoadProgress extends ProgressEvent {}

class SelectNode extends ProgressEvent {
  final String nodeId;

  const SelectNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class StartNode extends ProgressEvent {
  final String nodeId;

  const StartNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class CompleteNode extends ProgressEvent {
  final String nodeId;

  const CompleteNode(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}

class ClaimReward extends ProgressEvent {
  final String nodeId;

  const ClaimReward(this.nodeId);

  @override
  List<Object?> get props => [nodeId];
}
