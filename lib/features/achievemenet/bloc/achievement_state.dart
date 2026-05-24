part of 'achievement_bloc.dart';

enum AchievementStatus { initial, loading, success, error }

class AchievementState extends Equatable {
  const AchievementState({
    this.status = AchievementStatus.initial,
    this.achievements = const [],
    this.recentlyUnlocked = const [],
    this.selectedCategory,
    this.errorMessage,
  });

  final AchievementStatus status;
  final List<UserAchievement> achievements;
  final List<UserAchievement> recentlyUnlocked;
  final AchievementCategory? selectedCategory;
  final String? errorMessage;

  List<UserAchievement> get visibleAchievements {
    final category = selectedCategory;
    if (category == null) return achievements;
    return achievements
        .where((achievement) => achievement.definition.category == category)
        .toList(growable: false);
  }

  AchievementSummary get summary {
    final unlocked = achievements.where((item) => item.isUnlocked).toList();
    return AchievementSummary(
      total: achievements.length,
      unlocked: unlocked.length,
      unseen: achievements.where((item) => item.isUnseen).length,
      totalXpRewarded: unlocked.fold<int>(
        0,
        (total, item) => total + item.definition.xpReward,
      ),
    );
  }

  AchievementState copyWith({
    AchievementStatus? status,
    List<UserAchievement>? achievements,
    List<UserAchievement>? recentlyUnlocked,
    AchievementCategory? selectedCategory,
    bool clearSelectedCategory = false,
    String? errorMessage,
  }) {
    return AchievementState(
      status: status ?? this.status,
      achievements: achievements ?? this.achievements,
      recentlyUnlocked: recentlyUnlocked ?? this.recentlyUnlocked,
      selectedCategory: clearSelectedCategory
          ? null
          : selectedCategory ?? this.selectedCategory,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    achievements,
    recentlyUnlocked,
    selectedCategory,
    errorMessage,
  ];
}
