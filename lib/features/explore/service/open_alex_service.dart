import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/explore/service/explore_subject.dart';

class OpenAlexService {
  OpenAlexService(this._dio);

  final Dio _dio;
  final Map<String, List<ExploreSubject>> _cache = {};

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

  Future<List<ExploreSubject>> fetchSubjects({
    String search = '',
    String category = 'All',
    bool forceRefresh = false,
  }) async {
    final normalizedSearch = search.trim();
    final cacheKey =
        '${category.toLowerCase()}::${normalizedSearch.toLowerCase()}';

    if (!forceRefresh && _cache.containsKey(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final response = await _dio.get<Map<String, dynamic>>(
      '${ApiConstants.baseUrl}${ApiConstants.exploreSubjects}',
      queryParameters: {
        if (normalizedSearch.isNotEmpty) 'search': normalizedSearch,
        if (category != 'All') 'category': category,
        'limit': 12,
        'previewLimit': 8,
      },
    );

    final body = response.data ?? <String, dynamic>{};
    final data = (body['data'] as List?) ?? const [];
    final subjects = data
        .whereType<Map>()
        .map((raw) => _mapSubject(Map<String, dynamic>.from(raw)))
        .toList();

    if (subjects.isEmpty && normalizedSearch.isEmpty) {
      throw Exception('Unable to load explore subjects from OpenAlex.');
    }

    _cache[cacheKey] = subjects;
    return subjects;
  }

  ExploreSubject _mapSubject(Map<String, dynamic> raw) {
    final worksJson = (raw['works'] as List?) ?? const [];

    return ExploreSubject(
      slug: raw['slug'] as String? ?? '',
      name: raw['name'] as String? ?? 'OpenAlex Topic',
      category: raw['category'] as String? ?? 'General',
      description: raw['description'] as String? ?? '',
      emoji: raw['emoji'] as String? ?? '📚',
      accentColor: _parseColor(raw['accentColor'] as String?),
      workCount: (raw['workCount'] as num?)?.toInt() ?? worksJson.length,
      works: worksJson
          .whereType<Map>()
          .map((work) => _mapWork(Map<String, dynamic>.from(work)))
          .toList(),
    );
  }

  ExploreWork _mapWork(Map<String, dynamic> raw) {
    return ExploreWork(
      id: raw['id'] as String? ?? '',
      title: raw['title'] as String? ?? 'Untitled work',
      authors: raw['authors'] as String? ?? 'OpenAlex',
      sourceName: raw['sourceName'] as String?,
      publicationYear: (raw['publicationYear'] as num?)?.toInt(),
      citationCount: (raw['citationCount'] as num?)?.toInt() ?? 0,
      type: raw['type'] as String?,
      isOpenAccess: raw['isOpenAccess'] as bool? ?? false,
      landingPageUrl: raw['landingPageUrl'] as String?,
      pdfUrl: raw['pdfUrl'] as String?,
    );
  }

  Color _parseColor(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return const Color(0xFF4A8BFF);
    }

    final normalized = raw.replaceFirst('#', '');
    final hex = normalized.length == 6 ? 'FF$normalized' : normalized;
    final value = int.tryParse(hex, radix: 16);
    if (value == null) {
      return const Color(0xFF4A8BFF);
    }

    return Color(value);
  }
}
