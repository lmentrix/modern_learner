part of 'achievement_bloc.dart';

enum AchievementStatus { initial, loading, loaded, error }

class AchievementState extends Equatable {
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
    this.filtered = const [],
    this.selectedFilter = 'all',
  });

  final AchievementStatus status;
  final List<AchievementEntity> achievements;
  final List<AchievementEntity> filtered;
  final String selectedFilter;

  int get unlockedCount => achievements.where((a) => !a.isLocked).length;

  Map<String, List<AchievementEntity>> get groupedFiltered {
    final map = {
      for (final cat in AchievementBloc.categoryOrder) cat: <AchievementEntity>[],
    };
    for (final a in filtered) {
      map[a.category]?.add(a);
    }
    return map;
  }

  @override
  List<Object?> get props => [status, achievements, filtered, selectedFilter];

  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementEntity>? achievements,
    List<AchievementEntity>? filtered,
    String? selectedFilter,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }
}
