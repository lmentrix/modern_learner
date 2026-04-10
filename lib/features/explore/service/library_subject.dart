import 'package:flutter/material.dart';

class LibrarySubject {
  const LibrarySubject({
    required this.slug,
    required this.name,
    required this.category,
    required this.emoji,
    required this.accentColor,
    required this.workCount,
    required this.works,
  });

  final String slug;
  final String name;
  final String category;
  final String emoji;
  final Color accentColor;
  final int workCount;
  final List<LibraryWork> works;

  bool get isPopular => workCount >= 1000;

  String? get coverUrl {
    for (final work in works) {
      if (work.coverUrl != null && work.coverUrl!.isNotEmpty) {
        return work.coverUrl;
      }
    }
    return null;
  }

  List<String> get previewTitles => works
      .map((work) => work.title)
      .where((title) => title.isNotEmpty)
      .take(3)
      .toList();
}

class LibraryWork {
  const LibraryWork({
    required this.title,
    required this.authors,
    this.coverUrl,
    this.firstPublishYear,
    this.editionCount = 0,
  });

  final String title;
  final String authors;
  final String? coverUrl;
  final int? firstPublishYear;
  final int editionCount;
}
