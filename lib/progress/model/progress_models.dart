enum SkillTier { beginner, intermediate, advanced, master }

enum NodeState { locked, available, inProgress, unlocked }

class SkillNode {
  const SkillNode({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.tier,
    required this.state,
    required this.xpReward,
    this.prerequisiteIds = const [],
  });

  final String id;
  final String title;
  final String description;
  final int icon; // IconData codePoint
  final SkillTier tier;
  final NodeState state;
  final int xpReward;
  final List<String> prerequisiteIds;
}

class Achievement {
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.unlockedDate,
    required this.rarityColor,
  });

  final String id;
  final String title;
  final String description;
  final int icon;
  final bool unlocked;
  final String unlockedDate;
  final int rarityColor;
}

class SavedNoteRef {
  const SavedNoteRef({
    required this.noteId,
    required this.title,
    required this.subject,
    required this.tagColor,
    required this.savedDate,
    required this.excerpt,
  });

  final String noteId;
  final String title;
  final String subject;
  final int tagColor;
  final String savedDate;
  final String excerpt;
}
