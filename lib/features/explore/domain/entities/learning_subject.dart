import 'package:flutter/material.dart';

enum DifficultyLevel { beginner, intermediate, advanced, allLevels }

enum SubjectCategory {
  stem,
  humanities,
  arts,
  socialSciences,
  languages,
  professional,
}

extension SubjectCategoryLabel on SubjectCategory {
  String get label {
    switch (this) {
      case SubjectCategory.stem:
        return 'STEM';
      case SubjectCategory.humanities:
        return 'Humanities';
      case SubjectCategory.arts:
        return 'Arts';
      case SubjectCategory.socialSciences:
        return 'Social Sciences';
      case SubjectCategory.languages:
        return 'Languages';
      case SubjectCategory.professional:
        return 'Professional';
    }
  }
}

extension DifficultyLevelLabel on DifficultyLevel {
  String get label {
    switch (this) {
      case DifficultyLevel.beginner:
        return 'Beginner';
      case DifficultyLevel.intermediate:
        return 'Intermediate';
      case DifficultyLevel.advanced:
        return 'Advanced';
      case DifficultyLevel.allLevels:
        return 'All Levels';
    }
  }
}

class LearningTopic {
  const LearningTopic({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.difficulty,
    required this.estimatedMinutes,
  });

  final String id;
  final String name;
  final String description;
  final String emoji;
  final DifficultyLevel difficulty;
  final int estimatedMinutes;
}

class LearningSubject {
  const LearningSubject({
    required this.id,
    required this.name,
    required this.category,
    required this.categoryEnum,
    required this.description,
    required this.emoji,
    required this.accentColorValue,
    required this.topics,
    required this.difficulty,
  });

  final String id;
  final String name;
  final String category;
  final SubjectCategory categoryEnum;
  final String description;
  final String emoji;
  final int accentColorValue;
  final List<LearningTopic> topics;
  final DifficultyLevel difficulty;

  Color get accentColor => Color(accentColorValue);
  int get topicCount => topics.length;
}
