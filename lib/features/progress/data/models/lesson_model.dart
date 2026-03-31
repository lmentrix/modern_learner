import '../../domain/entities/roadmap.dart';

class LessonModel {
  final String id;
  final String title;
  final String type;
  final String description;
  final int xpReward;
  final String status;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    required this.description,
    required this.xpReward,
    required this.status,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      xpReward: json['xpReward'] as int,
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'description': description,
      'xpReward': xpReward,
      'status': status,
    };
  }

  Lesson toEntity() {
    return Lesson(
      id: id,
      title: title,
      type: LessonType.values.firstWhere(
        (t) => t.name == type,
        orElse: () => LessonType.exercise,
      ),
      description: description,
      xpReward: xpReward,
      status: LessonStatus.values.firstWhere(
        (s) => s.name == status,
        orElse: () => LessonStatus.locked,
      ),
    );
  }

  static LessonModel fromEntity(Lesson lesson) {
    return LessonModel(
      id: lesson.id,
      title: lesson.title,
      type: lesson.type.name,
      description: lesson.description,
      xpReward: lesson.xpReward,
      status: lesson.status.name,
    );
  }
}
