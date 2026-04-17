part of 'achievement_bloc.dart';

enum AchievementStatus { initial, loading, loaded, error }

class AchievementState extends Equatable {
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
    this.filtered = const [],
    this.selectedFilter = 'all',
    this.newlyUnlocked = const [],
  });

  final AchievementStatus status;
  final List<AchievementEntity> achievements;
  final List<AchievementEntity> filtered;
  final String selectedFilter;

  /// Achievements unlocked since the last acknowledgement — used to trigger
  /// the in-app toast notification. Cleared after [AchievementNewlyUnlockedAcknowledged].
  final List<AchievementEntity> newlyUnlocked;

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
  List<Object?> get props => [
        status,
        achievements,
        filtered,
        selectedFilter,
        newlyUnlocked,
      ];

  AchievementState copyWith({
    AchievementStatus? status,
    List<AchievementEntity>? achievements,
    List<AchievementEntity>? filtered,
    String? selectedFilter,
    List<AchievementEntity>? newlyUnlocked,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
      filtered: filtered ?? this.filtered,
      selectedFilter: selectedFilter ?? this.selectedFilter,
      newlyUnlocked: newlyUnlocked ?? this.newlyUnlocked,
    );
  }
}
