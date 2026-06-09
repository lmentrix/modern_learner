import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl {
    final raw = dotenv.env['BASE_URL'] ?? '';
    return _normalizeBaseUrl(raw);
  }

  static String get roadmapBaseUrl {
    final raw = dotenv.env['ROADMAP_BASE_URL'] ?? baseUrl;
    return _normalizeBaseUrl(raw);
  }

  static String _normalizeBaseUrl(String raw) {
    if (raw.isEmpty || kIsWeb) return raw;

    final uri = Uri.tryParse(raw);
    if (uri == null) return raw;

    final host = uri.host.toLowerCase();
    final isLoopback = host == 'localhost' || host == '127.0.0.1';
    if (isLoopback && defaultTargetPlatform == TargetPlatform.android) {
      return uri.replace(host: '10.0.2.2').toString();
    }

    return raw;
  }

  static String _joinUrl(String base, String path) {
    if (base.isEmpty) return path;
    final normalizedBase = base.endsWith('/')
        ? base.substring(0, base.length - 1)
        : base;
    return '$normalizedBase$path';
  }

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['PUBLISHABLE_KEY'] ?? '';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Endpoints ─────────────────────────────────────────────────────────────
  // FastAPI roadmap routes live under their own base URL. Per
  // `fastapi_backend/README.md`, that base should include `/api/v1`.
  static String get structuredRoadmapGenerate =>
      _joinUrl(roadmapBaseUrl, '/structured-roadmap/generate');
  static String get voiceRoadmapGenerate =>
      _joinUrl(roadmapBaseUrl, '/voice-roadmap/generate');
  static String get openRouterRoadmapGenerate =>
      _joinUrl(roadmapBaseUrl, '/openrouter/roadmaps/generate');
  static String get openRouterChapterSubcontentGenerate =>
      _joinUrl(roadmapBaseUrl, '/openrouter/chapter-subcontent/generate');
  static String get aiRoadmapGenerate =>
      _joinUrl(roadmapBaseUrl, '/ai/roadmap/generate');
  static String get aiChapterContentGenerate =>
      _joinUrl(roadmapBaseUrl, '/ai/chapter-content/generate');
  static String get openRouterChapterDetailGenerate =>
      _joinUrl(roadmapBaseUrl, '/openrouter/chapter-detail/generate');
  static String get structuredChapterContentGenerate =>
      _joinUrl(roadmapBaseUrl, '/structured-roadmap/chapter-content/generate');
  static String get voiceChapterContentGenerate =>
      _joinUrl(roadmapBaseUrl, '/voice-roadmap/chapter-content/generate');
  static String get structuredLessonContentGenerate =>
      _joinUrl(roadmapBaseUrl, '/structured-roadmap/lesson-content/generate');
  static String get voiceLessonContentGenerate =>
      _joinUrl(roadmapBaseUrl, '/voice-roadmap/lesson-content/generate');
  static const String voiceLessonGenerate = '/ai/voice-lesson/generate';
  static const String voiceLessonGenerateWithAudio =
      '/ai/voice-lesson/generate-with-audio';
  static const String voiceLessonTts = '/ai/voice-lesson/tts';
  static const String openRouterVoiceTts = '/openrouter/voice/tts';

  static String get qwenTtsSynthesize =>
      _joinUrl(roadmapBaseUrl, '/qwen-tts/synthesize');

  static String get openRouterApiKey => dotenv.env['OPENROUTER_API_KEY'] ?? '';
  static const String exploreSubjects = '/explore/subjects';
}
