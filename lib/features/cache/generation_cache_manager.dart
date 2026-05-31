import 'package:flutter_cache_manager/flutter_cache_manager.dart';

/// A file-based cache manager for AI-generated content (roadmaps, chapter
/// subcontent, exercises). Entries are stored in the device's cache directory
/// and automatically invalidated after 7 days.
class GenerationCacheManager extends CacheManager {
  factory GenerationCacheManager() => _instance;
  GenerationCacheManager._()
    : super(
        Config(
          _cacheKey,
          stalePeriod: const Duration(days: 7),
          maxNrOfCacheObjects: 300,
        ),
      );

  static const _cacheKey = 'generationCache';
  static final GenerationCacheManager _instance = GenerationCacheManager._();
}
