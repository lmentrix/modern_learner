import 'package:flutter_test/flutter_test.dart';
import 'package:modern_learner_production/progress/data/progress_data.dart';
import 'package:modern_learner_production/progress/model/progress_models.dart';
import 'package:modern_learner_production/progress/repo/xp_achievement_calculator.dart';

void main() {
  const calculator = XpAchievementCalculator();

  group('XpAchievementCalculator', () {
    test('keeps all milestones locked at zero XP', () {
      final result = calculator.calculate(
        xp: 0,
        skillNodes: skillTree,
        achievements: achievements,
      );

      expect(result.xp, 0);
      expect(result.skillNodes.first.state, NodeState.available);
      expect(
        result.skillNodes.skip(1),
        everyElement(_hasState(NodeState.locked)),
      );
      expect(result.achievements, everyElement(_isLockedAchievement));
      expect(result.nextMilestone?.requiredXp, 50);
    });

    test('unlocks skills and achievements when XP crosses thresholds', () {
      final result = calculator.calculate(
        xp: 600,
        skillNodes: skillTree,
        achievements: achievements,
      );

      expect(
        result.skillNodes
            .where((node) => node.state == NodeState.unlocked)
            .map((node) => node.id),
        containsAll(<String>['b1', 'b2', 'b3', 'i1', 'i2', 'i3']),
      );
      expect(
        result.achievements
            .where((achievement) => achievement.unlocked)
            .map((achievement) => achievement.id),
        containsAll(<String>['ach1', 'ach2']),
      );
      expect(result.nextMilestone?.id, 'a1');
      expect(result.nextMilestone?.requiredXp, 900);
    });

    test('reports only unlocks that were not previously emitted', () {
      final result = calculator.calculate(
        xp: 100,
        skillNodes: skillTree,
        achievements: achievements,
        previouslyUnlockedSkillIds: const {'b1'},
        previouslyUnlockedAchievementIds: const {'ach1'},
      );

      expect(result.newlyUnlockedSkillIds, ['b2']);
      expect(result.newlyUnlockedAchievementIds, isEmpty);
    });

    test('normalizes negative XP to zero', () {
      final result = calculator.calculate(
        xp: -200,
        skillNodes: skillTree,
        achievements: achievements,
      );

      expect(result.xp, 0);
      expect(result.newlyUnlockedSkillIds, isEmpty);
      expect(result.newlyUnlockedAchievementIds, isEmpty);
    });
  });
}

Matcher _hasState(NodeState state) =>
    isA<SkillNode>().having((node) => node.state, 'state', state);

final Matcher _isLockedAchievement = isA<Achievement>().having(
  (achievement) => achievement.unlocked,
  'unlocked',
  isFalse,
);
