import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/voice/service/voice_pronunciation_scorer.dart';

// ── Qwen word detail ───────────────────────────────────────────────────────────

class QwenWordDetail {
  const QwenWordDetail({
    required this.word,
    required this.correct,
    this.tip,
  });

  final String word;
  final bool correct;
  final String? tip;
}

// ── Extended result returned by Qwen ──────────────────────────────────────────

class QwenPronunciationResult {
  const QwenPronunciationResult({
    required this.scorePercent,
    required this.grade,
    required this.feedback,
    required this.wordDetails,
    required this.encouragement,
  });

  final int scorePercent;
  final String grade;
  final String feedback;
  final List<QwenWordDetail> wordDetails;
  final String encouragement;

  double get score => scorePercent / 100.0;

  List<int> get matchedIndices {
    final indices = <int>[];
    for (var i = 0; i < wordDetails.length; i++) {
      if (wordDetails[i].correct) indices.add(i);
    }
    return indices;
  }

  /// Converts to the shared [PronunciationResult] used throughout the app.
  PronunciationResult toPronunciationResult(String transcription) {
    return PronunciationResult(
      score: score,
      matchedWords: matchedIndices.length,
      totalWords: wordDetails.isEmpty ? 1 : wordDetails.length,
      matchedIndices: matchedIndices,
      transcription: transcription,
      feedback: feedback,
      encouragement: encouragement,
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class QwenPronunciationService {
  QwenPronunciationService._();
  static final QwenPronunciationService instance = QwenPronunciationService._();

  /// Calls the backend Qwen pronunciation scoring endpoint.
  /// Returns `null` if the endpoint is unreachable or returns an error.
  Future<QwenPronunciationResult?> score({
    required String expected,
    required String spoken,
    required String language,
    double sttConfidence = 0.0,
  }) async {
    final url = ApiConstants.qwenPronunciationScore.trim();
    if (url.isEmpty) return null;

    try {
      final response = await http
          .post(
            Uri.parse(url),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'expected': expected,
              'spoken': spoken,
              'language': language,
              'stt_confidence': sttConfidence,
            }),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) return null;

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResult(body);
    } catch (_) {
      return null;
    }
  }

  QwenPronunciationResult _parseResult(Map<String, dynamic> body) {
    final scorePercent = (body['score_percent'] as num?)?.toInt() ?? 50;
    final grade = (body['grade'] as String?) ?? 'Good';
    final feedback = (body['feedback'] as String?) ?? 'Keep practicing!';
    final encouragement = (body['encouragement'] as String?) ?? 'Keep going!';

    final rawWords = body['word_details'] as List<dynamic>? ?? [];
    final wordDetails = rawWords
        .whereType<Map<String, dynamic>>()
        .map(
          (w) => QwenWordDetail(
            word: (w['word'] as String?) ?? '',
            correct: (w['correct'] as bool?) ?? false,
            tip: w['tip'] as String?,
          ),
        )
        .toList();

    return QwenPronunciationResult(
      scorePercent: scorePercent.clamp(0, 100),
      grade: grade,
      feedback: feedback,
      wordDetails: wordDetails,
      encouragement: encouragement,
    );
  }
}
