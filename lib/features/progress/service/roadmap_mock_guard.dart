import 'dart:convert';

bool isMockRoadmapPayload(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty) return false;

  final searchable = jsonEncode(raw).toLowerCase();
  if (searchable.contains('mock roadmap') ||
      searchable.contains('offline_fallback') ||
      searchable.contains('offline-fallback') ||
      searchable.contains('deterministic offline')) {
    return true;
  }

  final roadmap = _readMap(raw['roadmap']);
  final data = _readMap(raw['data']);
  final nested = roadmap ?? data;

  return _hasMockMarkers(raw) || (nested != null && _hasMockMarkers(nested));
}

bool isUsableRoadmapPayload(Map<String, dynamic>? raw) {
  if (raw == null || raw.isEmpty || isMockRoadmapPayload(raw)) return false;
  final roadmap = _readMap(raw['roadmap']);
  final data = _readMap(raw['data']);
  final nested = _readMap(roadmap?['data']) ?? roadmap ?? data ?? raw;
  return nested['chapters'] is List;
}

Map<String, dynamic>? stripMockRoadmapPayload(Map<String, dynamic>? raw) {
  if (raw == null || isMockRoadmapPayload(raw)) return null;
  return raw;
}

bool _hasMockMarkers(Map<String, dynamic> raw) {
  final code = (raw['code'] ?? '').toString().toLowerCase();
  final model = (raw['model'] ?? '').toString().toLowerCase();
  final message = (raw['message'] ?? '').toString().toLowerCase();
  final summary = (raw['summary'] ?? '').toString().toLowerCase();
  final id = (raw['id'] ?? '').toString().toLowerCase();
  return raw['mocked'] == true ||
      code.contains('mock') ||
      code.contains('offline_fallback') ||
      model == 'offline-fallback' ||
      message.contains('mock roadmap') ||
      summary.contains('deterministic offline') ||
      id.startsWith('mock') ||
      id.contains('_mock');
}

Map<String, dynamic>? _readMap(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return null;
}
