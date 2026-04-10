import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/theme/app_colors.dart';
import 'package:modern_learner_production/features/explore/service/library_subject.dart';

class OpenLibraryService {
  OpenLibraryService(this._dio);

  final Dio _dio;

  static List<LibrarySubject>? _cache;

  static const categoryOrder = [
    'All',
    'Language',
    'Science',
    'Math',
    'History',
    'Arts',
    'Technology',
    'Humanities',
  ];

  Future<List<LibrarySubject>> fetchStudySubjects({
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cache != null) {
      return _cache!;
    }

    final subjects = await Future.wait(
      _subjectConfigs.map((config) async {
        try {
          return await _fetchSubject(config);
        } catch (_) {
          return null;
        }
      }),
    );

    final resolvedSubjects = subjects.whereType<LibrarySubject>().toList()
      ..sort((a, b) => b.workCount.compareTo(a.workCount));

    if (resolvedSubjects.isEmpty) {
      throw Exception('Unable to load library subjects from Open Library.');
    }

    _cache = resolvedSubjects;
    return resolvedSubjects;
  }

  Future<LibrarySubject> _fetchSubject(_SubjectConfig config) async {
    final response = await _dio.get<Map<String, dynamic>>(
      'https://openlibrary.org/subjects/${config.slug}.json',
      queryParameters: const {'limit': 8},
      options: Options(
        headers: const {
          'Accept': 'application/json',
          'User-Agent': 'ModernLearner/1.0',
        },
      ),
    );

    final data = response.data ?? <String, dynamic>{};
    final worksJson = (data['works'] as List?)?.cast<Map>() ?? const [];

    final works = worksJson.map((raw) {
      final work = Map<String, dynamic>.from(raw);
      final authors = ((work['authors'] as List?) ?? const [])
          .map((author) => author is Map ? author['name'] as String? : null)
          .whereType<String>()
          .where((name) => name.trim().isNotEmpty)
          .join(', ');
      final coverId = work['cover_id'] as int?;

      return LibraryWork(
        title: (work['title'] as String? ?? config.fallbackName).trim(),
        authors: authors.isEmpty ? 'Open Library' : authors,
        coverUrl: coverId == null
            ? null
            : 'https://covers.openlibrary.org/b/id/$coverId-M.jpg',
        firstPublishYear: work['first_publish_year'] as int?,
        editionCount: work['edition_count'] as int? ?? 0,
      );
    }).toList();

    return LibrarySubject(
      slug: config.slug,
      name: (data['name'] as String? ?? config.fallbackName).trim(),
      category: config.category,
      emoji: config.emoji,
      accentColor: config.accentColor,
      workCount: data['work_count'] as int? ?? works.length,
      works: works,
    );
  }
}

class _SubjectConfig {
  const _SubjectConfig({
    required this.slug,
    required this.fallbackName,
    required this.category,
    required this.emoji,
    required this.accentColor,
  });

  final String slug;
  final String fallbackName;
  final String category;
  final String emoji;
  final Color accentColor;
}

const _subjectConfigs = [
  _SubjectConfig(
    slug: 'spanish_language',
    fallbackName: 'Spanish Language',
    category: 'Language',
    emoji: '🇪🇸',
    accentColor: AppColors.primary,
  ),
  _SubjectConfig(
    slug: 'japanese_language',
    fallbackName: 'Japanese Language',
    category: 'Language',
    emoji: '🇯🇵',
    accentColor: AppColors.tertiary,
  ),
  _SubjectConfig(
    slug: 'biology',
    fallbackName: 'Biology',
    category: 'Science',
    emoji: '🧬',
    accentColor: AppColors.secondary,
  ),
  _SubjectConfig(
    slug: 'chemistry',
    fallbackName: 'Chemistry',
    category: 'Science',
    emoji: '⚗️',
    accentColor: Color(0xFF4CD6B8),
  ),
  _SubjectConfig(
    slug: 'algebra',
    fallbackName: 'Algebra',
    category: 'Math',
    emoji: '📐',
    accentColor: Color(0xFFF4B942),
  ),
  _SubjectConfig(
    slug: 'mathematics',
    fallbackName: 'Mathematics',
    category: 'Math',
    emoji: '➗',
    accentColor: Color(0xFFE96B5A),
  ),
  _SubjectConfig(
    slug: 'history',
    fallbackName: 'History',
    category: 'History',
    emoji: '🏛️',
    accentColor: Color(0xFFDB8E3C),
  ),
  _SubjectConfig(
    slug: 'art',
    fallbackName: 'Art',
    category: 'Arts',
    emoji: '🎨',
    accentColor: Color(0xFFEF6C9C),
  ),
  _SubjectConfig(
    slug: 'computer_science',
    fallbackName: 'Computer Science',
    category: 'Technology',
    emoji: '💻',
    accentColor: Color(0xFF00C2A8),
  ),
  _SubjectConfig(
    slug: 'programming',
    fallbackName: 'Programming',
    category: 'Technology',
    emoji: '🧠',
    accentColor: Color(0xFF5BC0EB),
  ),
  _SubjectConfig(
    slug: 'philosophy',
    fallbackName: 'Philosophy',
    category: 'Humanities',
    emoji: '📚',
    accentColor: Color(0xFF9F86FF),
  ),
];
