import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/core/theme/app_colors.dart';

/// Generates voice lesson content (phrases + exercises) for a given topic and
/// language. Tries the AI backend first; falls back to a local template on
/// network / API failure. Results are cached to avoid redundant calls.
class VoiceLessonGenerationService {
  VoiceLessonGenerationService({required this.dio, required this.prefs});

  final Dio dio;
  final SharedPreferences prefs;

  static const _prefix = 'voice_lesson_v3_';

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns a JSON map suitable for storing in `lessons.content.voice_lesson`.
  /// This method generates lesson content WITH Qwen TTS parameters included.
  Future<Map<String, dynamic>> generateContent({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    final key = _cacheKey(topic, language, level, nativeLanguage);
    final cached = prefs.getString(key);
    if (cached != null) {
      return jsonDecode(cached) as Map<String, dynamic>;
    }

    Map<String, dynamic> result;
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.voiceLessonGenerate,
        data: {
          'topic': topic,
          'language': language,
          'difficulty': level,
          'nativeLanguage': nativeLanguage,
        },
      );
      result = _unwrapPayload(response.data);
    } catch (_) {
      result = _buildTemplate(topic: topic, language: language, level: level);
    }

    await prefs.setString(key, jsonEncode(result));
    return result;
  }

  /// Generate voice lesson content WITH pre-generated audio from Qwen TTS.
  /// 
  /// This calls the backend's `generate-with-audio` endpoint which:
  /// 1. Generates the structured lesson content via AI
  /// 2. Synthesizes audio for all phrases and exercises using Qwen TTS
  /// 3. Returns everything in one response
  /// 
  /// Returns a map containing both the lesson content and pre-generated audio.
  Future<Map<String, dynamic>> generateContentWithAudio({
    required String topic,
    required String language,
    required String level,
    required String nativeLanguage,
  }) async {
    try {
      final response = await dio.post<Map<String, dynamic>>(
        ApiConstants.voiceLessonGenerateWithAudio,
        data: {
          'topic': topic,
          'language': language,
          'difficulty': level,
          'nativeLanguage': nativeLanguage,
        },
      );
      return _unwrapPayload(response.data);
    } catch (e) {
      // Fall back to content-only generation if audio generation fails
      return generateContent(
        topic: topic,
        language: language,
        level: level,
        nativeLanguage: nativeLanguage,
      );
    }
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _cacheKey(
    String topic,
    String language,
    String level,
    String native,
  ) => '$_prefix${topic}_${language}_${level}_$native'.toLowerCase().replaceAll(
    ' ',
    '_',
  );

  /// Builds locally-generated template content when the AI API is unavailable.
  /// This template now includes Qwen TTS parameters for each phrase and exercise.
  Map<String, dynamic> _buildTemplate({
    required String topic,
    required String language,
    required String level,
  }) {
    final color = _colorForLanguage(language);
    final emoji = _emojiForTopic(topic);
    final voiceProfile = _buildVoiceProfile(language, level);
    final languageType = _languageTypeFor(language);
    final voice = level.toLowerCase() == 'beginner' ? 'Serena' : 'Cherry';

    // Build narrator TTS
    final narratorTts = {
      'introText':
          'Welcome to this $language lesson about $topic. Let\'s practice some useful phrases.',
      'voice': voice,
      'languageType': languageType,
      'instructions': 'Warm, welcoming, and clear. Encouraging tone for learners.',
      'optimizeInstructions': true,
    };

    final phrases = <Map<String, dynamic>>[
      {
        'id': 'p1',
        'text': 'Excuse me, could you help me with $topic?',
        'phonetic': '/ɪkˈskjuːz miː kʊd juː help miː/',
        'translation': 'Asking for help with $topic',
        'tip':
            'A polite opener when you need assistance. Works in almost any $topic situation.',
        'audio_cues': ['gentle opening', 'slight pause after excuse me'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Excuse me, could you help me with $topic?',
          instructions:
              'Speak clearly and encouragingly. Gentle opening, slight pause after excuse me.',
        ),
        'tts': {
          'text': 'Excuse me, could you help me with $topic?',
          'voice': voice,
          'languageType': languageType,
          'instructions':
              'Gentle opening, slight pause after excuse me. Clear and encouraging for learners.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'p2',
        'text': 'I\'d like to know more about this.',
        'phonetic': '/aɪd laɪk tə nəʊ mɔːr əˈbaʊt ðɪs/',
        'translation': 'Expressing curiosity about $topic',
        'tip':
            'Use this phrase to show genuine interest and keep the conversation going.',
        'audio_cues': ['steady pace', 'warm curiosity'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'I\'d like to know more about this.',
          instructions: 'Use a warm, curious tone with steady pacing.',
        ),
        'tts': {
          'text': 'I\'d like to know more about this.',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Warm, curious tone with steady pacing.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'p3',
        'text': 'Thank you so much for your help.',
        'phonetic': '/θæŋk juː səʊ mʌtʃ fər jɔːr help/',
        'translation': 'Showing gratitude after a $topic interaction',
        'tip': 'Always express gratitude. It leaves a positive impression.',
        'audio_cues': ['smile in the voice', 'soft ending'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Thank you so much for your help.',
          instructions: 'Sound grateful and warm with a soft ending.',
        ),
        'tts': {
          'text': 'Thank you so much for your help.',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Grateful and warm with a soft ending.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'p4',
        'text': 'Could you repeat that, please?',
        'phonetic': '/kʊd juː rɪˈpiːt ðæt pliːz/',
        'translation': 'Politely asking for clarification in $topic',
        'tip':
            'Never be afraid to ask for clarification — it shows you\'re engaged.',
        'audio_cues': ['rising intonation on repeat', 'polite finish'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Could you repeat that, please?',
          instructions:
              'Use polite rising intonation on repeat and a gentle finish.',
        ),
        'tts': {
          'text': 'Could you repeat that, please?',
          'voice': voice,
          'languageType': languageType,
          'instructions':
              'Polite rising intonation on repeat, gentle finish.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'p5',
        'text': 'That sounds great, I\'ll try it!',
        'phonetic': '/ðæt saʊndz ɡreɪt aɪl traɪ ɪt/',
        'translation': 'Accepting a suggestion about $topic',
        'tip': 'Showing enthusiasm encourages more helpful conversation.',
        'audio_cues': ['brighter energy', 'strong stress on great'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'That sounds great, I\'ll try it!',
          instructions: 'Use brighter energy and stress the word great.',
        ),
        'tts': {
          'text': 'That sounds great, I\'ll try it!',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Brighter energy, stress the word great.',
          'optimizeInstructions': true,
        },
      },
    ];

    final exercises = <Map<String, dynamic>>[
      {
        'id': 'ex1',
        'question': 'Which phrase is best for opening a $topic conversation?',
        'options': [
          'Excuse me, could you help me with $topic?',
          'I don\'t understand anything.',
          'Leave me alone.',
          'I know everything about $topic.',
        ],
        'correct_index': 0,
        'practice_prompt': 'Excuse me, could you help me with $topic?',
        'audio_cues': ['clear opening', 'friendly tone'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Excuse me, could you help me with $topic?',
          instructions: 'Friendly tone with clear pronunciation for learners.',
        ),
        'tts': {
          'text': 'Excuse me, could you help me with $topic?',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Friendly tone, clear pronunciation for learners.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'ex2',
        'question': 'How do you politely ask someone to repeat what they said?',
        'options': [
          'What?!',
          'Could you repeat that, please?',
          'Say it again.',
          'I wasn\'t listening.',
        ],
        'correct_index': 1,
        'practice_prompt': 'Could you repeat that, please?',
        'audio_cues': ['gentle request', 'slight rise on repeat'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Could you repeat that, please?',
          instructions: 'Make it sound polite with a small rise on repeat.',
        ),
        'tts': {
          'text': 'Could you repeat that, please?',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Polite with a small rise on repeat.',
          'optimizeInstructions': true,
        },
      },
      {
        'id': 'ex3',
        'question':
            'Which phrase shows you are grateful after a $topic interaction?',
        'options': [
          'That\'s not good enough.',
          'Whatever.',
          'Thank you so much for your help.',
          'I expected better.',
        ],
        'correct_index': 2,
        'practice_prompt': 'Thank you so much for your help.',
        'audio_cues': ['warm delivery', 'soft closing'],
        'speech': _buildSpeech(
          voiceProfile,
          text: 'Thank you so much for your help.',
          instructions: 'Warm delivery with a soft closing tone.',
        ),
        'tts': {
          'text': 'Thank you so much for your help.',
          'voice': voice,
          'languageType': languageType,
          'instructions': 'Warm delivery with soft closing tone.',
          'optimizeInstructions': true,
        },
      },
    ];

    return {
      'title': '$topic Voice Lab',
      'subtitle': 'Essential $language phrases for $topic',
      'description':
          'AI-generated speaking prompts and quick checks for $topic.',
      'topic': topic,
      'duration': '15 min',
      'emoji': emoji,
      // ignore: deprecated_member_use
      'accent_color': color.value,
      'level': level,
      'ai_generated': true,
      'voice_profile': voiceProfile,
      'narrator_tts': narratorTts,
      'phrases': phrases,
      'exercises': exercises,
      'pronunciation_tips': [
        {
          'category': 'Rhythm',
          'tip':
              'Slow down slightly before the key request so each word stays clear.',
          'examples': ['Excuse me', 'Could you repeat that'],
        },
        {
          'category': 'Politeness',
          'tip': 'Let your intonation soften at the end of polite requests.',
          'examples': ['please', 'thank you'],
        },
      ],
      'practice_phrases': phrases.map((phrase) => phrase['text']).toList(),
    };
  }

  Map<String, dynamic> _unwrapPayload(Map<String, dynamic>? raw) {
    if (raw == null) return <String, dynamic>{};
    final nested = raw['data'];
    if (nested is Map<String, dynamic>) {
      return nested;
    }
    return raw;
  }

  Map<String, dynamic> _buildVoiceProfile(String language, String level) => {
    'provider': 'qwen',
    'disclosure': 'AI-generated voice',
    'model': 'qwen3-tts-instruct-flash',
    'voice': level.toLowerCase() == 'beginner' ? 'Serena' : 'Cherry',
    'language_type': _languageTypeFor(language),
    'style': 'Clear, encouraging, and easy to follow for language learners.',
  };

  Map<String, dynamic> _buildSpeech(
    Map<String, dynamic> voiceProfile, {
    required String text,
    required String instructions,
  }) => {
    'provider': voiceProfile['provider'],
    'model': voiceProfile['model'],
    'voice': voiceProfile['voice'],
    'language_type': voiceProfile['language_type'],
    'text': text,
    'instructions': instructions,
    'optimize_instructions': true,
  };

  static Color _colorForLanguage(String language) {
    switch (language.toLowerCase()) {
      case 'spanish':
        return const Color(0xFFFF6B35);
      case 'french':
        return const Color(0xFF3B82F6);
      case 'german':
        return const Color(0xFFFFD700);
      case 'japanese':
        return const Color(0xFFFF2D55);
      case 'mandarin':
        return const Color(0xFFFF4500);
      case 'italian':
        return const Color(0xFF00B4D8);
      case 'portuguese':
        return const Color(0xFF00DC82);
      default:
        return AppColors.primary;
    }
  }

  static String _emojiForTopic(String topic) {
    final t = topic.toLowerCase();
    if (t.contains('food') || t.contains('eat') || t.contains('restaurant')) {
      return '🍽️';
    }
    if (t.contains('travel') || t.contains('airport') || t.contains('hotel')) {
      return '✈️';
    }
    if (t.contains('greet') || t.contains('hello') || t.contains('introduc')) {
      return '👋';
    }
    if (t.contains('shop') || t.contains('market') || t.contains('buy')) {
      return '🛍️';
    }
    if (t.contains('work') || t.contains('business') || t.contains('office')) {
      return '💼';
    }
    if (t.contains('school') || t.contains('study') || t.contains('class')) {
      return '📚';
    }
    if (t.contains('doctor') || t.contains('health') || t.contains('medical')) {
      return '🏥';
    }
    if (t.contains('sport') || t.contains('gym') || t.contains('exercise')) {
      return '⚽';
    }
    if (t.contains('music') || t.contains('sing') || t.contains('song')) {
      return '🎵';
    }
    if (t.contains('coffee') || t.contains('cafe') || t.contains('drink')) {
      return '☕';
    }
    return '🎤';
  }

  static String _languageTypeFor(String language) {
    switch (language.toLowerCase()) {
      case 'mandarin':
      case 'chinese':
        return 'Chinese';
      case 'spanish':
        return 'Spanish';
      case 'portuguese':
        return 'Portuguese';
      case 'french':
        return 'French';
      case 'german':
        return 'German';
      case 'italian':
        return 'Italian';
      case 'japanese':
        return 'Japanese';
      case 'korean':
        return 'Korean';
      case 'russian':
        return 'Russian';
      case 'english':
      default:
        return 'English';
    }
  }
}
