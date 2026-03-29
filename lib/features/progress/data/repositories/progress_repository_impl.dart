import 'dart:async';
import 'dart:math';

import '../../domain/entities/skill_node.dart';
import '../../domain/entities/skill_tree.dart';
import '../../domain/entities/user_progress.dart';
import '../../domain/repositories/progress_repository.dart';

class ProgressRepositoryImpl implements ProgressRepository {
  final _progressController = StreamController<UserProgress>.broadcast();

  // Mock data - replace with real API calls
  UserProgress _userProgress = const UserProgress(
    totalXp: 2400,
    level: 8,
    gems: 150,
    streak: 14,
    completedNodes: {},
    nodeProgress: {},
    unlockedAchievements: [],
  );

  @override
  Future<SkillTree> getSkillTree() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simulate API
    return _getMockSkillTree();
  }

  @override
  Future<UserProgress> getUserProgress() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _userProgress;
  }

  @override
  Future<void> startNode(String nodeId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _userProgress = _userProgress.copyWith(
      nodeProgress: {
        ..._userProgress.nodeProgress,
        nodeId: 0.1,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> completeNode(String nodeId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final random = Random();
    final gemsEarned = random.nextInt(10) + 5;

    _userProgress = _userProgress.copyWith(
      totalXp: _userProgress.totalXp + 100,
      level: (_userProgress.totalXp + 100) ~/ 500 + 1,
      gems: _userProgress.gems + gemsEarned,
      completedNodes: {
        ..._userProgress.completedNodes,
        nodeId: DateTime.now(),
      },
      nodeProgress: {
        ..._userProgress.nodeProgress..remove(nodeId),
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Future<void> updateNodeProgress(String nodeId, double progress) async {
    _userProgress = _userProgress.copyWith(
      nodeProgress: {
        ..._userProgress.nodeProgress,
        nodeId: progress,
      },
    );
    _progressController.add(_userProgress);
  }

  @override
  Stream<UserProgress> getProgressStream() => _progressController.stream;

  SkillTree _getMockSkillTree() {
    final nodes = [
      // Path 1: Basics
      const SkillNode(
        id: 'node_1',
        title: 'Basics',
        description: 'Start your journey here',
        emoji: '🌱',
        type: SkillNodeType.core,
        status: SkillNodeStatus.completed,
        positionX: 50,
        positionY: 5,
        prerequisites: [],
        xpReward: 50,
        duration: Duration(minutes: 5),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 5)],
      ),
      const SkillNode(
        id: 'node_2',
        title: 'Greetings',
        description: 'Learn to say hello',
        emoji: '👋',
        type: SkillNodeType.core,
        status: SkillNodeStatus.completed,
        positionX: 35,
        positionY: 15,
        prerequisites: ['node_1'],
        xpReward: 75,
        duration: Duration(minutes: 8),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 8)],
      ),
      const SkillNode(
        id: 'node_3',
        title: 'Introductions',
        description: 'Talk about yourself',
        emoji: '📝',
        type: SkillNodeType.core,
        status: SkillNodeStatus.inProgress,
        positionX: 65,
        positionY: 25,
        prerequisites: ['node_2'],
        xpReward: 100,
        duration: Duration(minutes: 10),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 10)],
      ),
      // Path 2: Conversation
      const SkillNode(
        id: 'node_4',
        title: 'Small Talk',
        description: 'Casual conversations',
        emoji: '💬',
        type: SkillNodeType.core,
        status: SkillNodeStatus.available,
        positionX: 40,
        positionY: 38,
        prerequisites: ['node_3'],
        xpReward: 120,
        duration: Duration(minutes: 12),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 12)],
      ),
      const SkillNode(
        id: 'node_5',
        title: 'Questions',
        description: 'Ask anything',
        emoji: '❓',
        type: SkillNodeType.bonus,
        status: SkillNodeStatus.locked,
        positionX: 20,
        positionY: 48,
        prerequisites: ['node_4'],
        xpReward: 150,
        duration: Duration(minutes: 15),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 15)],
      ),
      const SkillNode(
        id: 'node_6',
        title: 'Directions',
        description: 'Navigate with confidence',
        emoji: '🧭',
        type: SkillNodeType.core,
        status: SkillNodeStatus.locked,
        positionX: 60,
        positionY: 50,
        prerequisites: ['node_4'],
        xpReward: 125,
        duration: Duration(minutes: 10),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 12)],
      ),
      // Path 3: Intermediate
      const SkillNode(
        id: 'node_7',
        title: 'Past Tense',
        description: 'Talk about the past',
        emoji: '⏰',
        type: SkillNodeType.core,
        status: SkillNodeStatus.locked,
        positionX: 50,
        positionY: 63,
        prerequisites: ['node_6'],
        xpReward: 150,
        duration: Duration(minutes: 15),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 15)],
      ),
      const SkillNode(
        id: 'node_8',
        title: 'Future Plans',
        description: 'Discuss your goals',
        emoji: '🎯',
        type: SkillNodeType.challenge,
        status: SkillNodeStatus.locked,
        positionX: 35,
        positionY: 75,
        prerequisites: ['node_7'],
        xpReward: 200,
        duration: Duration(minutes: 20),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 20)],
      ),
      // Boss Battle
      const SkillNode(
        id: 'node_9',
        title: 'Conversation Boss',
        description: 'Test your skills!',
        emoji: '👹',
        type: SkillNodeType.boss,
        status: SkillNodeStatus.locked,
        positionX: 50,
        positionY: 88,
        prerequisites: ['node_8'],
        xpReward: 500,
        duration: Duration(minutes: 30),
        rewards: [
          SkillNodeReward(name: 'Gem', icon: '💎', quantity: 50),
          SkillNodeReward(name: 'Badge', icon: '🏆', quantity: 1),
        ],
      ),
      // Bonus nodes
      const SkillNode(
        id: 'node_10',
        title: 'Cultural Tips',
        description: 'Understand the culture',
        emoji: '🎭',
        type: SkillNodeType.bonus,
        status: SkillNodeStatus.locked,
        positionX: 80,
        positionY: 38,
        prerequisites: ['node_3'],
        xpReward: 100,
        duration: Duration(minutes: 10),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 10)],
      ),
      const SkillNode(
        id: 'node_11',
        title: 'Slang & Idioms',
        description: 'Sound like a local',
        emoji: '😎',
        type: SkillNodeType.bonus,
        status: SkillNodeStatus.locked,
        positionX: 75,
        positionY: 63,
        prerequisites: ['node_7', 'node_10'],
        xpReward: 175,
        duration: Duration(minutes: 18),
        rewards: [SkillNodeReward(name: 'Gem', icon: '💎', quantity: 18)],
      ),
    ];

    final paths = <SkillPath>[];
    for (final node in nodes) {
      for (final prereq in node.prerequisites) {
        paths.add(SkillPath(
          fromNodeId: prereq,
          toNodeId: node.id,
          isUnlocked: node.status != SkillNodeStatus.locked,
        ));
      }
    }

    return SkillTree(
      id: 'tree_1',
      name: 'Language Mastery',
      description: 'Complete your journey to fluency',
      nodes: nodes,
      paths: paths,
    );
  }
}
