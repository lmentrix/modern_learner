import 'dart:async';
import 'dart:convert';

import 'package:modern_learner_production/features/cache/generation_cache_manager.dart';

/// Local cache for AI-generated content (roadmap, chapter subcontent, exercise).
/// Entries expire after 7 days, managed automatically by [GenerationCacheManager].
/// Raw JSON strings from the backend are stored as UTF-8 files so the originating
/// response models can be reconstructed via their `fromRawJson` factories without
/// any lossy re-serialisation.
class GenerationCache {
  const GenerationCache();

  // Key namespaces — kept identical to the old SharedPreferences prefixes so
  // any migration between the two storage backends is straightforward.
  static const _roadmapPrefix = 'gen_cache_roadmap::';
  static const _subcontentPrefix = 'gen_cache_subcontent::';
  static const _exercisePrefix = 'gen_cache_exercise::';

  // ── Roadmap ──────────────────────────────────────────────────────────────

  Future<String?> readRoadmap(String cacheKey) =>
      _read(_roadmapPrefix + _normalize(cacheKey));

  Future<void> saveRoadmap(String cacheKey, String rawJson) =>
      _write(_roadmapPrefix + _normalize(cacheKey), rawJson);

  Future<void> clearRoadmap(String cacheKey) =>
      _remove(_roadmapPrefix + _normalize(cacheKey));

  // ── Chapter subcontent ───────────────────────────────────────────────────

  Future<String?> readChapterSubcontent({
    required String roadmapKey,
    required int chapterNumber,
  }) => _read(_subcontentPrefix + _subcontentKey(roadmapKey, chapterNumber));

  Future<void> saveChapterSubcontent({
    required String roadmapKey,
    required int chapterNumber,
    required String rawJson,
  }) => _write(
    _subcontentPrefix + _subcontentKey(roadmapKey, chapterNumber),
    rawJson,
  );

  Future<void> clearChapterSubcontent({
    required String roadmapKey,
    required int chapterNumber,
  }) => _remove(_subcontentPrefix + _subcontentKey(roadmapKey, chapterNumber));

  // ── Exercise ─────────────────────────────────────────────────────────────

  Future<String?> readExercise({
    required String chapterSubcontentId,
    required int subcontentNumber,
  }) => _read(
    _exercisePrefix + _exerciseKey(chapterSubcontentId, subcontentNumber),
  );

  Future<void> saveExercise({
    required String chapterSubcontentId,
    required int subcontentNumber,
    required String rawJson,
  }) => _write(
    _exercisePrefix + _exerciseKey(chapterSubcontentId, subcontentNumber),
    rawJson,
  );

  Future<void> clearExercise({
    required String chapterSubcontentId,
    required int subcontentNumber,
  }) => _remove(
    _exercisePrefix + _exerciseKey(chapterSubcontentId, subcontentNumber),
  );

  // ── Startup ──────────────────────────────────────────────────────────────

  /// Pre-warms the cache at app start so the first real read/write doesn't pay
  /// the cost of opening the underlying SQLite database.
  /// Call this fire-and-forget from [main] (via [unawaited]).
  static Future<void> warmUp() async {
    try {
      // A no-op lookup is enough to open the DB and load the index into memory.
      await GenerationCacheManager().getFileFromCache('__warmup__');
    } catch (_) {}
  }

  // ── Housekeeping ─────────────────────────────────────────────────────────

  /// Evicts all entries from the cache (roadmap, subcontent, and exercise).
  Future<void> clearAll() => GenerationCacheManager().emptyCache();

  /// No-op: flutter_cache_manager prunes expired entries automatically.
  Future<void> pruneExpired() async {}

  // ── Internal ─────────────────────────────────────────────────────────────

  Future<String?> _read(String cacheKey) async {
    try {
      final info = await GenerationCacheManager().getFileFromCache(cacheKey);
      if (info == null) return null;
      return info.file.readAsStringSync();
    } catch (_) {
      return null;
    }
  }

  Future<void> _write(String cacheKey, String rawJson) async {
    try {
      await GenerationCacheManager().putFile(
        cacheKey,
        utf8.encode(rawJson),
        fileExtension: 'json',
      );
    } catch (_) {}
  }

  Future<void> _remove(String cacheKey) async {
    try {
      await GenerationCacheManager().removeFile(cacheKey);
    } catch (_) {}
  }

  static String _normalize(String value) => value.trim().toLowerCase();

  static String _subcontentKey(String roadmapKey, int chapterNumber) =>
      '${_normalize(roadmapKey)}::$chapterNumber';

  static String _exerciseKey(String id, int subcontentNumber) =>
      '${_normalize(id)}::$subcontentNumber';
}
