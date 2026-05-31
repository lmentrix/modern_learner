import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';

const _fallbackRoadmapBaseUrl = 'http://127.0.0.1:8000/api/v1';

Future<ChapterExerciseResponseModel> fetchChapterExercise(
  ChapterExerciseGenerateRequestModel request, {
  http.Client? client,
}) async {
  final cached = await const GenerationCache().readExercise(
    chapterSubcontentId: request.chapterSubcontentId,
    subcontentNumber: request.subcontentNumber,
  );
  if (cached != null) {
    return ChapterExerciseResponseModel.fromRawJson(cached);
  }

  final activeClient = client ?? http.Client();

  try {
    final response = await _postChapterExercise(activeClient, request.toJson());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChapterExerciseRequestException(
        'Failed to generate chapter exercise (${response.statusCode}): '
        '${_extractErrorMessage(response)}',
      );
    }

    final rawJson = utf8.decode(response.bodyBytes);
    final result = ChapterExerciseResponseModel.fromRawJson(rawJson);
    await const GenerationCache().saveExercise(
      chapterSubcontentId: request.chapterSubcontentId,
      subcontentNumber: request.subcontentNumber,
      rawJson: rawJson,
    );
    return result;
  } on SocketException catch (error) {
    throw ChapterExerciseRequestException(
      'Could not reach the FastAPI chapter detail API at '
      '${_buildChapterExerciseUri()}. Make sure the backend is running. '
      'Original error: $error',
    );
  } on HttpException catch (error) {
    throw ChapterExerciseRequestException(
      'HTTP error while calling ${_buildChapterExerciseUri()}: $error',
    );
  } on http.ClientException catch (error) {
    throw ChapterExerciseRequestException(
      'Client error while calling ${_buildChapterExerciseUri()}: $error. '
      'If you are on Android, ensure cleartext HTTP is allowed for the local backend.',
    );
  } finally {
    if (client == null) {
      activeClient.close();
    }
  }
}

Future<http.Response> _postChapterExercise(
  http.Client client,
  Map<String, dynamic> body,
) async {
  Object? lastConnectionError;
  final uris = _chapterExerciseUris();

  for (var index = 0; index < uris.length; index++) {
    final uri = uris[index];
    final isLast = index == uris.length - 1;
    try {
      final response = await client
          .post(
            uri,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(ApiConstants.receiveTimeout);

      if (response.statusCode == 404 && !isLast) {
        continue;
      }
      return response;
    } on SocketException catch (error) {
      lastConnectionError = error;
      if (isLast) rethrow;
    } on HttpException catch (error) {
      lastConnectionError = error;
      if (isLast) rethrow;
    } on http.ClientException catch (error) {
      lastConnectionError = error;
      if (isLast) rethrow;
    }
  }

  throw ChapterExerciseRequestException(
    'Could not reach the FastAPI chapter detail API. '
    'Last error: $lastConnectionError',
  );
}

Uri _buildChapterExerciseUri() {
  return _chapterExerciseUris().first;
}

List<Uri> _chapterExerciseUris() {
  final configuredBaseUrl = ApiConstants.roadmapBaseUrl.trim();
  final baseUrl = configuredBaseUrl.isEmpty
      ? _fallbackRoadmapBaseUrl
      : configuredBaseUrl;
  final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final configuredUrl = ApiConstants.openRouterChapterDetailGenerate.trim();
  final configuredUri = Uri.tryParse(configuredUrl);
  final hasAbsoluteConfiguredUrl =
      configuredUri != null &&
      configuredUri.hasScheme &&
      configuredUri.host.isNotEmpty;
  final endpointUrl = hasAbsoluteConfiguredUrl
      ? configuredUrl
      : '$normalizedBaseUrl/openrouter/chapter-detail/generate';

  final primary = Uri.parse(endpointUrl);
  final fallback = Uri.parse(
    '$_fallbackRoadmapBaseUrl/openrouter/chapter-detail/generate',
  );
  if (primary == fallback) return [primary];
  return [primary, fallback];
}

String _extractErrorMessage(http.Response response) {
  if (response.bodyBytes.isEmpty) {
    return response.reasonPhrase ?? 'Empty response body';
  }

  final body = utf8.decode(response.bodyBytes);
  final decoded = _jsonDecodeSafe(body);
  if (decoded is Map<String, dynamic>) {
    final message = decoded['message'];
    if (message is String && message.trim().isNotEmpty) return message;

    final detail = decoded['detail'];
    if (detail is String && detail.trim().isNotEmpty) return detail;
    if (detail is Map<String, dynamic>) {
      final nestedMessage = detail['message'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }
      return detail.toString();
    }
    if (detail is List && detail.isNotEmpty) return detail.toString();
  }

  return body;
}

Object? _jsonDecodeSafe(String raw) {
  try {
    return jsonDecode(raw);
  } catch (_) {
    return null;
  }
}

class ChapterExerciseGenerateRequestModel {
  const ChapterExerciseGenerateRequestModel({
    required this.chapterSubcontentId,
    required this.subcontentNumber,
    this.model,
    this.context,
  });

  final String chapterSubcontentId;
  final int subcontentNumber;
  final String? model;

  /// Inline context forwarded to the backend so it can generate the exercise
  /// without requiring an in-memory store lookup.
  final ChapterDetailContext? context;

  Map<String, dynamic> toJson() {
    final selectedModel = model;
    final selectedContext = context;
    return {
      'chapter_subcontent_id': chapterSubcontentId,
      'subcontent_number': subcontentNumber,
      if (selectedModel != null && selectedModel.trim().isNotEmpty)
        'model': selectedModel,
      if (selectedContext != null) 'context': selectedContext.toJson(),
    };
  }
}

class ChapterDetailContext {
  const ChapterDetailContext({
    required this.courseType,
    required this.topic,
    required this.targetLanguage,
    required this.level,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.subcontentTitle,
    required this.subcontentType,
    required this.subcontentSummary,
    required this.sourceLessons,
    required this.objectives,
    required this.activities,
    required this.focusSkills,
  });

  final String courseType;
  final String topic;
  final String targetLanguage;
  final String level;
  final int chapterNumber;
  final String chapterTitle;
  final String subcontentTitle;
  final String subcontentType;
  final String subcontentSummary;
  final List<String> sourceLessons;
  final List<String> objectives;
  final List<String> activities;
  final List<String> focusSkills;

  Map<String, dynamic> toJson() => {
    'course_type': courseType,
    'topic': topic,
    'target_language': targetLanguage,
    'level': level,
    'chapter_number': chapterNumber,
    'chapter_title': chapterTitle,
    'subcontent_title': subcontentTitle,
    'subcontent_type': subcontentType,
    'subcontent_summary': subcontentSummary,
    'source_lessons': sourceLessons,
    'objectives': objectives,
    'activities': activities,
    'focus_skills': focusSkills,
  };
}

class ChapterExerciseResponseModel {
  const ChapterExerciseResponseModel({
    required this.statusCode,
    this.requestId,
    required this.code,
    required this.message,
    required this.model,
    required this.courseType,
    required this.chapterDetail,
    this.usage,
    this.rawContent,
    this.prompt,
  });

  factory ChapterExerciseResponseModel.fromRawJson(String source) =>
      ChapterExerciseResponseModel.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );

  factory ChapterExerciseResponseModel.fromJson(Map<String, dynamic> json) {
    final detailJson = _readMap(json, const [
      'chapter_detail',
      'chapterDetail',
    ]);
    if (detailJson == null) {
      throw const FormatException('Missing chapter detail payload.');
    }

    return ChapterExerciseResponseModel(
      statusCode: _readInt(json, const ['status_code', 'statusCode']) ?? 0,
      requestId: _readString(json, const ['request_id', 'requestId']),
      code: _readString(json, const ['code']) ?? '',
      message: _readString(json, const ['message']) ?? '',
      model: _readString(json, const ['model']) ?? '',
      courseType:
          _readString(json, const ['course_type', 'courseType']) ?? 'school',
      chapterDetail: ChapterExerciseDetailModel.fromJson(detailJson),
      usage: switch (_readMap(json, const ['usage'])) {
        final usageJson? => RoadmapUsageModel.fromJson(usageJson),
        null => null,
      },
      rawContent: _readString(json, const ['raw_content', 'rawContent']),
      prompt: _readString(json, const ['prompt']),
    );
  }

  final int statusCode;
  final String? requestId;
  final String code;
  final String message;
  final String model;
  final String courseType;
  final ChapterExerciseDetailModel chapterDetail;
  final RoadmapUsageModel? usage;
  final String? rawContent;
  final String? prompt;
}

class ChapterExerciseDetailModel {
  const ChapterExerciseDetailModel({
    required this.id,
    required this.courseType,
    required this.detailType,
    required this.chapterNumber,
    required this.chapterTitle,
    required this.subcontentNumber,
    required this.subcontentTitle,
    required this.subcontentType,
    required this.introduction,
    required this.exerciseGroups,
    required this.learningFocus,
    this.wrapUpNote,
    this.speakingFocus,
    this.practiceSteps = const [],
    this.vocabularyItems = const [],
    this.performanceTask,
    this.reviewNotes = const [],
    this.audioCues = const [],
  });

  factory ChapterExerciseDetailModel.fromJson(Map<String, dynamic> json) {
    final vocabulary = _readMap(json, const [
      'vocabulary_section',
      'vocabularySection',
    ]);

    return ChapterExerciseDetailModel(
      id: _readString(json, const ['id']) ?? '',
      courseType:
          _readString(json, const ['course_type', 'courseType']) ?? 'school',
      detailType:
          _readString(json, const ['detail_type', 'detailType']) ?? 'exercise',
      chapterNumber:
          _readInt(json, const ['chapter_number', 'chapterNumber']) ?? 0,
      chapterTitle:
          _readString(json, const ['chapter_title', 'chapterTitle']) ?? '',
      subcontentNumber:
          _readInt(json, const ['subcontent_number', 'subcontentNumber']) ?? 0,
      subcontentTitle:
          _readString(json, const ['subcontent_title', 'subcontentTitle']) ??
          '',
      subcontentType:
          _readString(json, const ['subcontent_type', 'subcontentType']) ?? '',
      introduction: _readString(json, const ['introduction']) ?? '',
      exerciseGroups: _readList(json, const [
        'exercise_groups',
        'exerciseGroups',
      ]).map(ChapterExerciseGroupModel.fromJson).toList(),
      learningFocus: _readStringList(json, const [
        'learning_focus',
        'learningFocus',
      ]),
      wrapUpNote: _readString(json, const ['wrap_up_note', 'wrapUpNote']),
      speakingFocus: _readString(json, const [
        'speaking_focus',
        'speakingFocus',
      ]),
      practiceSteps: _readList(json, const [
        'practice_steps',
        'practiceSteps',
      ]).map(VoicePracticeStepModel.fromJson).toList(),
      vocabularyItems: _readListFromMap(vocabulary, const [
        'items',
      ]).map(VoiceVocabularyItemModel.fromJson).toList(),
      performanceTask: _readString(json, const [
        'performance_task',
        'performanceTask',
      ]),
      reviewNotes: _readStringList(json, const ['review_notes', 'reviewNotes']),
      audioCues: _readStringList(json, const ['audio_cues', 'audioCues']),
    );
  }

  final String id;
  final String courseType;
  final String detailType;
  final int chapterNumber;
  final String chapterTitle;
  final int subcontentNumber;
  final String subcontentTitle;
  final String subcontentType;
  final String introduction;
  final List<ChapterExerciseGroupModel> exerciseGroups;
  final List<String> learningFocus;
  final String? wrapUpNote;
  final String? speakingFocus;
  final List<VoicePracticeStepModel> practiceSteps;
  final List<VoiceVocabularyItemModel> vocabularyItems;
  final String? performanceTask;
  final List<String> reviewNotes;
  final List<String> audioCues;

  bool get isVoice => courseType == 'voice' || detailType == 'voice_lesson';
}

class ChapterExerciseGroupModel {
  const ChapterExerciseGroupModel({
    required this.exerciseType,
    required this.title,
    required this.instructions,
    required this.questions,
    required this.pairs,
  });

  factory ChapterExerciseGroupModel.fromJson(Map<String, dynamic> json) {
    return ChapterExerciseGroupModel(
      exerciseType:
          _readString(json, const ['exercise_type', 'exerciseType']) ?? '',
      title: _readString(json, const ['title']) ?? '',
      instructions: _readString(json, const ['instructions']) ?? '',
      questions: _readList(json, const [
        'questions',
      ]).map(ChapterExerciseQuestionModel.fromJson).toList(),
      pairs: _readList(json, const [
        'pairs',
      ]).map(ChapterExerciseMatchingPairModel.fromJson).toList(),
    );
  }

  final String exerciseType;
  final String title;
  final String instructions;
  final List<ChapterExerciseQuestionModel> questions;
  final List<ChapterExerciseMatchingPairModel> pairs;
}

class ChapterExerciseQuestionModel {
  const ChapterExerciseQuestionModel({
    required this.questionNumber,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.options = const [],
    this.clue,
  });

  factory ChapterExerciseQuestionModel.fromJson(Map<String, dynamic> json) {
    return ChapterExerciseQuestionModel(
      questionNumber:
          _readInt(json, const ['question_number', 'questionNumber']) ?? 0,
      prompt: _readString(json, const ['prompt']) ?? '',
      answer: _readString(json, const ['answer']) ?? '',
      explanation: _readString(json, const ['explanation']) ?? '',
      options: _readStringList(json, const ['options']),
      clue: _readString(json, const ['clue']),
    );
  }

  final int questionNumber;
  final String prompt;
  final String answer;
  final String explanation;
  final List<String> options;
  final String? clue;
}

class ChapterExerciseMatchingPairModel {
  const ChapterExerciseMatchingPairModel({
    required this.pairNumber,
    required this.leftItem,
    required this.rightItem,
  });

  factory ChapterExerciseMatchingPairModel.fromJson(Map<String, dynamic> json) {
    return ChapterExerciseMatchingPairModel(
      pairNumber: _readInt(json, const ['pair_number', 'pairNumber']) ?? 0,
      leftItem: _readString(json, const ['left_item', 'leftItem']) ?? '',
      rightItem: _readString(json, const ['right_item', 'rightItem']) ?? '',
    );
  }

  final int pairNumber;
  final String leftItem;
  final String rightItem;
}

class VoicePracticeStepModel {
  const VoicePracticeStepModel({
    required this.stepNumber,
    required this.prompt,
    required this.coachingTip,
  });

  factory VoicePracticeStepModel.fromJson(Map<String, dynamic> json) {
    return VoicePracticeStepModel(
      stepNumber: _readInt(json, const ['step_number', 'stepNumber']) ?? 0,
      prompt: _readString(json, const ['prompt']) ?? '',
      coachingTip:
          _readString(json, const ['coaching_tip', 'coachingTip']) ?? '',
    );
  }

  final int stepNumber;
  final String prompt;
  final String coachingTip;
}

class VoiceVocabularyItemModel {
  const VoiceVocabularyItemModel({
    required this.term,
    required this.translation,
    required this.pronunciationTip,
    required this.exampleLine,
    required this.usageNote,
  });

  factory VoiceVocabularyItemModel.fromJson(Map<String, dynamic> json) {
    return VoiceVocabularyItemModel(
      term: _readString(json, const ['term']) ?? '',
      translation: _readString(json, const ['translation']) ?? '',
      pronunciationTip:
          _readString(json, const ['pronunciation_tip', 'pronunciationTip']) ??
          '',
      exampleLine:
          _readString(json, const ['example_line', 'exampleLine']) ?? '',
      usageNote: _readString(json, const ['usage_note', 'usageNote']) ?? '',
    );
  }

  final String term;
  final String translation;
  final String pronunciationTip;
  final String exampleLine;
  final String usageNote;
}

class ChapterExercisePageArgs {
  const ChapterExercisePageArgs({
    required this.chapterSubcontentId,
    required this.chapterNumber,
    required this.subcontentNumber,
    required this.chapterTitle,
    required this.subcontentTitle,
    required this.accentColorValue,
    this.model,
    this.context,
  });

  final String chapterSubcontentId;
  final int chapterNumber;
  final int subcontentNumber;
  final String chapterTitle;
  final String subcontentTitle;
  final int accentColorValue;
  final String? model;

  /// Inline context passed through to the network request so the backend
  /// doesn't need in-memory store lookups.
  final ChapterDetailContext? context;
}

class ChapterExerciseCompletionResult {
  const ChapterExerciseCompletionResult({
    required this.chapterNumber,
    required this.subcontentNumber,
    required this.score,
    required this.totalQuestions,
  });

  final int chapterNumber;
  final int subcontentNumber;
  final int score;
  final int totalQuestions;

  int get mistakesCount => (totalQuestions - score).clamp(0, totalQuestions);

  int get scorePercent {
    if (totalQuestions <= 0) return 0;
    return ((score / totalQuestions) * 100).round();
  }
}

class ChapterExerciseRequestException implements Exception {
  const ChapterExerciseRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}

String? _readString(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is String) return value;
    if (value != null) return value.toString();
  }

  return null;
}

int? _readInt(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
  }

  return null;
}

Map<String, dynamic>? _readMap(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
  }

  return null;
}

List<Map<String, dynamic>> _readList(
  Map<String, dynamic> json,
  List<String> keys,
) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.whereType<Map>().map(Map<String, dynamic>.from).toList();
    }
  }

  return const [];
}

List<Map<String, dynamic>> _readListFromMap(
  Map<String, dynamic>? json,
  List<String> keys,
) {
  if (json == null) return const [];
  return _readList(json, keys);
}

List<String> _readStringList(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    final value = json[key];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
  }

  return const [];
}
