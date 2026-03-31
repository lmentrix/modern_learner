import 'package:equatable/equatable.dart';

enum ChapterType {
  lesson,
  checkpoint,
  bossChallenge,
}

enum LessonType {
  vocabulary,
  grammar,
  exercise,
  listening,
  reading,
  conversation,
}

enum LessonStatus {
  locked,
  available,
  inProgress,
  completed,
}

class Roadmap extends Equatable {
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String level;
  final int totalXp;
  final int estimatedHours;
  final List<Chapter> chapters;

  const Roadmap({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLanguage,
    required this.level,
    required this.totalXp,
    required this.estimatedHours,
    required this.chapters,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        targetLanguage,
        level,
        totalXp,
        estimatedHours,
        chapters,
      ];
}

class Chapter extends Equatable {
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final String icon;
  final ChapterType type;
  final int xpReward;
  final int gemReward;
  final List<String> prerequisites; // Chapter IDs
  final List<String> skills;
  final List<Lesson> lessons;

  const Chapter({
    required this.id,
    required this.chapterNumber,
    required this.title,
    required this.description,
    required this.icon,
    required this.type,
    required this.xpReward,
    required this.gemReward,
    required this.prerequisites,
    required this.skills,
    required this.lessons,
  });

  @override
  List<Object?> get props => [
        id,
        chapterNumber,
        title,
        description,
        icon,
        type,
        xpReward,
        gemReward,
        prerequisites,
        skills,
        lessons,
      ];
}

class Lesson extends Equatable {
  final String id;
  final String title;
  final LessonType type;
  final String description;
  final int xpReward;
  final LessonStatus status;

  const Lesson({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.xpReward,
    required this.status,
  });

  Lesson copyWith({LessonStatus? status}) {
    return Lesson(
      id: id,
      title: title,
      type: type,
      description: description,
      xpReward: xpReward,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        type,
        description,
        xpReward,
        status,
      ];
}
