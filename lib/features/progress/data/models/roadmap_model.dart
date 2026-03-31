import '../../domain/entities/roadmap.dart';
import 'lesson_model.dart';

class RoadmapModel {
  final String id;
  final String title;
  final String description;
  final String targetLanguage;
  final String level;
  final int totalXp;
  final int estimatedHours;
  final List<ChapterModel> chapters;

  RoadmapModel({
    required this.id,
    required this.title,
    required this.description,
    required this.targetLanguage,
    required this.level,
    required this.totalXp,
    required this.estimatedHours,
    required this.chapters,
  });

  factory RoadmapModel.fromJson(Map<String, dynamic> json) {
    return RoadmapModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      targetLanguage: json['targetLanguage'] as String,
      level: json['level'] as String,
      totalXp: json['totalXp'] as int,
      estimatedHours: json['estimatedHours'] as int,
      chapters: (json['chapters'] as List<dynamic>)
          .map((c) => ChapterModel.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'targetLanguage': targetLanguage,
      'level': level,
      'totalXp': totalXp,
      'estimatedHours': estimatedHours,
      'chapters': chapters.map((c) => c.toJson()).toList(),
    };
  }

  Roadmap toEntity() {
    return Roadmap(
      id: id,
      title: title,
      description: description,
      targetLanguage: targetLanguage,
      level: level,
      totalXp: totalXp,
      estimatedHours: estimatedHours,
      chapters: chapters.map((c) => c.toEntity()).toList(),
    );
  }

  static RoadmapModel fromEntity(Roadmap roadmap) {
    return RoadmapModel(
      id: roadmap.id,
      title: roadmap.title,
      description: roadmap.description,
      targetLanguage: roadmap.targetLanguage,
      level: roadmap.level,
      totalXp: roadmap.totalXp,
      estimatedHours: roadmap.estimatedHours,
      chapters: roadmap.chapters.map((c) => ChapterModel.fromEntity(c)).toList(),
    );
  }
}

class ChapterModel {
  final String id;
  final int chapterNumber;
  final String title;
  final String description;
  final String icon;
  final String type;
  final int xpReward;
  final int gemReward;
  final List<String> prerequisites;
  final List<String> skills;
  final List<LessonModel> lessons;

  ChapterModel({
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

  factory ChapterModel.fromJson(Map<String, dynamic> json) {
    return ChapterModel(
      id: json['id'] as String,
      chapterNumber: json['chapterNumber'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      icon: json['icon'] as String,
      type: json['type'] as String,
      xpReward: json['xpReward'] as int,
      gemReward: json['gemReward'] as int,
      prerequisites: (json['prerequisites'] as List<dynamic>?)?.cast<String>() ?? [],
      skills: (json['skills'] as List<dynamic>?)?.cast<String>() ?? [],
      lessons: (json['lessons'] as List<dynamic>?)
              ?.map((l) => LessonModel.fromJson(l as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chapterNumber': chapterNumber,
      'title': title,
      'description': description,
      'icon': icon,
      'type': type,
      'xpReward': xpReward,
      'gemReward': gemReward,
      'prerequisites': prerequisites,
      'skills': skills,
      'lessons': lessons.map((l) => l.toJson()).toList(),
    };
  }

  Chapter toEntity() {
    return Chapter(
      id: id,
      chapterNumber: chapterNumber,
      title: title,
      description: description,
      icon: icon,
      type: ChapterType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => ChapterType.lesson,
      ),
      xpReward: xpReward,
      gemReward: gemReward,
      prerequisites: prerequisites,
      skills: skills,
      lessons: lessons.map((l) => l.toEntity()).toList(),
    );
  }

  static ChapterModel fromEntity(Chapter chapter) {
    return ChapterModel(
      id: chapter.id,
      chapterNumber: chapter.chapterNumber,
      title: chapter.title,
      description: chapter.description,
      icon: chapter.icon,
      type: chapter.type.name,
      xpReward: chapter.xpReward,
      gemReward: chapter.gemReward,
      prerequisites: chapter.prerequisites,
      skills: chapter.skills,
      lessons: chapter.lessons.map((l) => LessonModel.fromEntity(l)).toList(),
    );
  }
}
