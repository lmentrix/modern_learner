/// Scores a user's spoken attempt against an expected phrase.
/// Uses order-aware word matching combined with STT confidence.
class VoicePronunciationScorer {
  const VoicePronunciationScorer._();

  static PronunciationResult score({
    required String expected,
    required String spoken,
    required double sttConfidence,
  }) {
    final expTokens = _tokenize(expected);
    final actTokens = _tokenize(spoken);

    if (expTokens.isEmpty) {
      return PronunciationResult(
        score: 0,
        matchedWords: 0,
        totalWords: 0,
        matchedIndices: const [],
        transcription: spoken,
        feedback: 'Nothing to compare.',
      );
    }

    // Order-aware sequential scan — tracks which expected-word indices matched.
    final matched = <int>[];
    var actIdx = 0;
    for (var expIdx = 0; expIdx < expTokens.length; expIdx++) {
      for (var i = actIdx; i < actTokens.length; i++) {
        if (_similar(actTokens[i], expTokens[expIdx])) {
          matched.add(expIdx);
          actIdx = i + 1;
          break;
        }
      }
    }

    final coverage = matched.length / expTokens.length;
    final conf = sttConfidence.clamp(0.0, 1.0);
    final raw = (coverage * 0.75 + conf * 0.25).clamp(0.0, 1.0);

    return PronunciationResult(
      score: raw,
      matchedWords: matched.length,
      totalWords: expTokens.length,
      matchedIndices: matched,
      transcription: spoken,
      feedback: _feedback(raw),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  static List<String> _tokenize(String text) => text
      .toLowerCase()
      .replaceAll(RegExp(r"[^\w\s']"), '')
      .split(RegExp(r'\s+'))
      .where((w) => w.isNotEmpty)
      .toList();

  /// Allows a 1-character edit distance for minor mispronunciations.
  static bool _similar(String a, String b) {
    if (a == b) return true;
    if ((a.length - b.length).abs() > 2) return false;
    return _editDistance(a, b) <= 1;
  }

  static int _editDistance(String a, String b) {
    final m = a.length, n = b.length;
    final dp = List.generate(m + 1, (_) => List.filled(n + 1, 0));
    for (var i = 0; i <= m; i++) {
      dp[i][0] = i;
    }
    for (var j = 0; j <= n; j++) {
      dp[0][j] = j;
    }
    for (var i = 1; i <= m; i++) {
      for (var j = 1; j <= n; j++) {
        dp[i][j] = a[i - 1] == b[j - 1]
            ? dp[i - 1][j - 1]
            : 1 +
                  [
                    dp[i - 1][j],
                    dp[i][j - 1],
                    dp[i - 1][j - 1],
                  ].reduce((x, y) => x < y ? x : y);
      }
    }
    return dp[m][n];
  }

  static String _feedback(double score) {
    if (score >= 0.92) return 'Perfect! Spot-on pronunciation.';
    if (score >= 0.78) return 'Great — just a couple of words to polish.';
    if (score >= 0.62) return 'Good effort. Speak a little more clearly.';
    if (score >= 0.42) return 'Keep practicing — focus on each word.';
    return 'Try again slowly, word by word.';
  }
}

// ── Result model ──────────────────────────────────────────────────────────────

class PronunciationResult {
  const PronunciationResult({
    required this.score,
    required this.matchedWords,
    required this.totalWords,
    required this.matchedIndices,
    required this.transcription,
    required this.feedback,
    this.encouragement,
  });

  /// 0.0 – 1.0
  final double score;
  final int matchedWords;
  final int totalWords;

  /// Indices (into the expected-word list) of words the user said correctly.
  final List<int> matchedIndices;

  final String transcription;
  final String feedback;

  /// Optional AI-generated encouragement (set when Qwen scoring is available).
  final String? encouragement;

  int get scorePercent => (score * 100).round();

  String get grade {
    if (score >= 0.92) return 'Excellent';
    if (score >= 0.78) return 'Great';
    if (score >= 0.62) return 'Good';
    if (score >= 0.42) return 'Keep going';
    return 'Try again';
  }
}
