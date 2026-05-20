import 'dart:convert';

import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoadmapIdCache {
  const RoadmapIdCache();

  static const _latestRoadmapIdKey = 'progress_latest_roadmap_id';
  static const _roadmapIdMapKey = 'progress_cached_roadmap_ids';

  static String buildRoadmapCacheKey({
    required String roadmapMode,
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) {
    return [
      _normalizeKeyPart(roadmapMode),
      _normalizeKeyPart(topic),
      _normalizeKeyPart(language),
      _normalizeKeyPart(level),
      _normalizeKeyPart(nativeLanguage),
    ].join('::');
  }

  String? readRoadmapId({String? cacheKey}) {
    final sharedPreferences = _sharedPreferencesOrNull;
    if (sharedPreferences == null) {
      return null;
    }

    if (cacheKey == null || cacheKey.trim().isEmpty) {
      final latest = sharedPreferences.getString(_latestRoadmapIdKey);
      return _sanitize(latest);
    }

    final map = _readCachedMap(sharedPreferences);
    return _sanitize(map[cacheKey.trim()]);
  }

  Future<void> saveRoadmapId({
    required String roadmapId,
    String? cacheKey,
  }) async {
    final sharedPreferences = _sharedPreferencesOrNull;
    final sanitizedRoadmapId = _sanitize(roadmapId);
    if (sharedPreferences == null || sanitizedRoadmapId == null) {
      return;
    }

    await sharedPreferences.setString(_latestRoadmapIdKey, sanitizedRoadmapId);

    final sanitizedCacheKey = _sanitize(cacheKey);
    if (sanitizedCacheKey == null) {
      return;
    }

    final map = _readCachedMap(sharedPreferences);
    map[sanitizedCacheKey] = sanitizedRoadmapId;
    await sharedPreferences.setString(_roadmapIdMapKey, jsonEncode(map));
  }

  Future<void> clearRoadmapId({String? cacheKey}) async {
    final sharedPreferences = _sharedPreferencesOrNull;
    if (sharedPreferences == null) {
      return;
    }

    final sanitizedCacheKey = _sanitize(cacheKey);
    if (sanitizedCacheKey == null) {
      await sharedPreferences.remove(_latestRoadmapIdKey);
      return;
    }

    final map = _readCachedMap(sharedPreferences);
    map.remove(sanitizedCacheKey);
    await sharedPreferences.setString(_roadmapIdMapKey, jsonEncode(map));
  }

  SharedPreferences? get _sharedPreferencesOrNull {
    final locator = GetIt.instance;
    if (!locator.isRegistered<SharedPreferences>()) {
      return null;
    }
    return locator<SharedPreferences>();
  }

  Map<String, String> _readCachedMap(SharedPreferences sharedPreferences) {
    final raw = sharedPreferences.getString(_roadmapIdMapKey);
    if (raw == null || raw.isEmpty) {
      return <String, String>{};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map) {
      return <String, String>{};
    }

    return decoded.map<String, String>((key, value) {
      return MapEntry(key.toString(), value.toString());
    });
  }

  static String? _sanitize(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }

  static String _normalizeKeyPart(String value) {
    return value.trim().toLowerCase();
  }
}
