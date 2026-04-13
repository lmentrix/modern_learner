import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

abstract final class ApiConstants {
  static String get baseUrl {
    final raw = dotenv.env['BASE_URL'] ?? '';
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

  static String get supabaseUrl => dotenv.env['SUPABASE_URL'] ?? '';
  static String get supabasePublishableKey =>
      dotenv.env['PUBLISHABLE_KEY'] ?? '';

  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 120);
  static const Duration sendTimeout = Duration(seconds: 30);

  // ── Endpoints ─────────────────────────────────────────────────────────────
  static const String lessonRoadmapGenerate = '/ai/lesson-roadmap/generate';
  static const String roadmapGenerate = '/ai/roadmap/generate';
  static const String chapterContentGenerate = '/ai/chapter-content/generate';
  static const String lessonContentGenerate = '/ai/lesson-content/generate';
  static const String exploreSubjects = '/explore/subjects';
}
