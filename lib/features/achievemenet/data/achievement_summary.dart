import 'package:equatable/equatable.dart';

class AchievementSummary extends Equatable {
  const AchievementSummary({
    required this.total,
    required this.unlocked,
    required this.unseen,
    required this.totalXpRewarded,
  });

  final int total;
  final int unlocked;
  final int unseen;
  final int totalXpRewarded;

  double get unlockedRatio {
    if (total == 0) return 0;
    return unlocked / total;
  }

  @override
  List<Object?> get props => [total, unlocked, unseen, totalXpRewarded];
}
