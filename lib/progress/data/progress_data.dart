import 'package:modern_learner_production/progress/model/progress_models.dart';

// ── Skill tree nodes ─────────────────────────────────────────────────────────

const skillTree = [
  // ── Beginner tier ──────────────────────────────────────────────────────────
  SkillNode(
    id: 'b1',
    title: 'First Steps',
    description: 'Complete your first lesson.',
    icon: 0xe80c,
    tier: SkillTier.beginner,
    state: NodeState.locked,
    xpReward: 100,
    requiredXp: 50,
  ),
  SkillNode(
    id: 'b2',
    title: 'Note Taker',
    description: 'Save 3 notes from any study session.',
    icon: 0xe3b7,
    tier: SkillTier.beginner,
    state: NodeState.locked,
    xpReward: 150,
    prerequisiteIds: ['b1'],
    requiredXp: 100,
  ),
  SkillNode(
    id: 'b3',
    title: 'Curious Mind',
    description: 'Use AI Explain on 5 passages.',
    icon: 0xe0da,
    tier: SkillTier.beginner,
    state: NodeState.locked,
    xpReward: 200,
    prerequisiteIds: ['b1'],
    requiredXp: 200,
  ),

  // ── Intermediate tier ──────────────────────────────────────────────────────
  SkillNode(
    id: 'i1',
    title: 'Week Warrior',
    description: 'Maintain a 7-day learning streak.',
    icon: 0xe61c,
    tier: SkillTier.intermediate,
    state: NodeState.locked,
    xpReward: 300,
    prerequisiteIds: ['b2'],
    requiredXp: 300,
  ),
  SkillNode(
    id: 'i2',
    title: 'Deep Diver',
    description: 'Finish a note with 10+ min read time.',
    icon: 0xe1a1,
    tier: SkillTier.intermediate,
    state: NodeState.locked,
    xpReward: 350,
    prerequisiteIds: ['b2', 'b3'],
    requiredXp: 450,
  ),
  SkillNode(
    id: 'i3',
    title: 'Visual Thinker',
    description: 'Generate 10 AI images from study content.',
    icon: 0xe3f4,
    tier: SkillTier.intermediate,
    state: NodeState.locked,
    xpReward: 400,
    prerequisiteIds: ['b3'],
    requiredXp: 600,
  ),

  // ── Advanced tier ──────────────────────────────────────────────────────────
  SkillNode(
    id: 'a1',
    title: 'Scholar',
    description: 'Complete 50 lessons across any subjects.',
    icon: 0xe870,
    tier: SkillTier.advanced,
    state: NodeState.locked,
    xpReward: 600,
    prerequisiteIds: ['i1', 'i2'],
    requiredXp: 900,
  ),
  SkillNode(
    id: 'a2',
    title: 'Synthesiser',
    description: 'Cross-reference notes from 3 different subjects.',
    icon: 0xe8d5,
    tier: SkillTier.advanced,
    state: NodeState.locked,
    xpReward: 700,
    prerequisiteIds: ['i2', 'i3'],
    requiredXp: 1200,
  ),

  // ── Master tier ────────────────────────────────────────────────────────────
  SkillNode(
    id: 'm1',
    title: 'Grand Master',
    description: 'Unlock all advanced skills and reach 5000 XP.',
    icon: 0xe3d3,
    tier: SkillTier.master,
    state: NodeState.locked,
    xpReward: 1500,
    prerequisiteIds: ['a1', 'a2'],
    requiredXp: 2000,
  ),
];

// ── Achievements ─────────────────────────────────────────────────────────────

const achievements = [
  Achievement(
    id: 'ach1',
    title: '14-Day Streak 🔥',
    description: 'Studied every day for two weeks straight.',
    icon: 0xe61c,
    unlocked: true,
    unlockedDate: 'Jun 12',
    rarityColor: 0xFFFDE68A,
    requiredXp: 100,
  ),
  Achievement(
    id: 'ach2',
    title: 'Top 5 Learner',
    description: 'Reached the top 5 on the weekly leaderboard.',
    icon: 0xe870,
    unlocked: true,
    unlockedDate: 'Jun 10',
    rarityColor: 0xFFBBF0D9,
    requiredXp: 500,
  ),
  Achievement(
    id: 'ach3',
    title: 'AI Explorer',
    description: 'Used every AI feature at least once.',
    icon: 0xe0da,
    unlocked: true,
    unlockedDate: 'Jun 8',
    rarityColor: 0xFFE9D5FF,
    requiredXp: 1000,
  ),
  Achievement(
    id: 'ach4',
    title: 'Night Owl',
    description: 'Completed a lesson after midnight.',
    icon: 0xe518,
    unlocked: false,
    unlockedDate: '',
    rarityColor: 0xFFBBF0D9,
    requiredXp: 2000,
  ),
  Achievement(
    id: 'ach5',
    title: 'Speed Reader',
    description: 'Finished a 10-min note in under 6 minutes.',
    icon: 0xe425,
    unlocked: false,
    unlockedDate: '',
    rarityColor: 0xFFFDE68A,
    requiredXp: 3500,
  ),
];

// ── Saved notes (mirrored from study) ────────────────────────────────────────

const savedNotes = [
  SavedNoteRef(
    noteId: '1',
    title: 'Intro to Neural Networks',
    subject: 'Machine Learning',
    tagColor: 0xFFBBF0D9,
    savedDate: 'Jun 13',
    excerpt:
        'Training a neural network involves forward propagation, loss calculation, and backpropagation.',
  ),
  SavedNoteRef(
    noteId: '2',
    title: 'The Stoic Mindset',
    subject: 'Philosophy',
    tagColor: 0xFFE9D5FF,
    savedDate: 'Jun 11',
    excerpt:
        '"You have power over your mind, not outside events. Realise this, and you will find strength."',
  ),
];

// ── XP summary ───────────────────────────────────────────────────────────────

const totalXp = 3760;
const xpGoal = 5000;
const currentLevel = 14;
const lessonsCompleted = 124;
const hoursStudied = 38;
