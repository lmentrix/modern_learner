import 'package:flutter/material.dart';

class ExploreSubject {
  const ExploreSubject({
    required this.slug,
    required this.name,
    required this.category,
    required this.description,
    required this.emoji,
    required this.accentColor,
    required this.workCount,
    required this.works,
  });

  final String slug;
  final String name;
  final String category;
  final String description;
  final String emoji;
  final Color accentColor;
  final int workCount;
  final List<ExploreWork> works;

  bool get isPopular => workCount >= 5000;

  String? get coverUrl => null;

  List<String> get previewTitles => works
      .map((work) => work.title)
      .where((title) => title.isNotEmpty)
      .take(3)
      .toList();
}

class ExploreWork {
  const ExploreWork({
    required this.id,
    required this.title,
    required this.authors,
    this.sourceName,
    this.publicationYear,
    this.citationCount = 0,
    this.type,
    this.isOpenAccess = false,
    this.landingPageUrl,
    this.pdfUrl,
  });

  final String id;
  final String title;
  final String authors;
  final String? sourceName;
  final int? publicationYear;
  final int citationCount;
  final String? type;
  final bool isOpenAccess;
  final String? landingPageUrl;
  final String? pdfUrl;
}
