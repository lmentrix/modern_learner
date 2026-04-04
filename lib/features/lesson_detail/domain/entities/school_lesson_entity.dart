import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SchoolLessonEntity extends Equatable {
  const SchoolLessonEntity({
    required this.id,
    required this.title,
    required this.subject,
    required this.emoji,
    required this.color,
    required this.duration,
    required this.difficulty,
    required this.description,
    required this.sections,
    required this.quiz,
  });

  final String id;
  final String title;
  final String subject;
  final String emoji;
  final Color color;
  final String duration;
  final String difficulty;
  final String description;
  final List<SchoolSection> sections;
  final List<QuizQuestion> quiz;

  int get sectionCount => sections.length;

  @override
  List<Object?> get props => [id, title, subject];
}

class SchoolSection extends Equatable {
  const SchoolSection({
    required this.id,
    required this.title,
    required this.icon,
    required this.content,
    this.concepts = const [],
    this.vocabulary = const [],
  });

  final String id;
  final String title;
  final String icon;
  final String content;
  final List<SchoolConcept> concepts;
  final List<VocabWord> vocabulary;

  @override
  List<Object?> get props => [id, title];
}

class SchoolConcept extends Equatable {
  const SchoolConcept({
    required this.term,
    required this.definition,
    required this.example,
  });

  final String term;
  final String definition;
  final String example;

  @override
  List<Object?> get props => [term, definition];
}

class VocabWord extends Equatable {
  const VocabWord({
    required this.word,
    required this.definition,
    required this.partOfSpeech,
  });

  final String word;
  final String definition;
  final String partOfSpeech;

  @override
  List<Object?> get props => [word, definition];
}

class QuizQuestion extends Equatable {
  const QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });

  final String id;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  @override
  List<Object?> get props => [id, question];
}
