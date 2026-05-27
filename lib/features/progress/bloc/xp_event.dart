part of 'xp_bloc.dart';

sealed class XpEvent {}

final class XpEarned extends XpEvent {
  XpEarned(this.amount);

  final int amount;
}

final class _XpDataChanged extends XpEvent {
  _XpDataChanged(this.data);

  final CourseXpData data;
}
