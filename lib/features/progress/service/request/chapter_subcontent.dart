import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';
import 'package:modern_learner_production/features/roadmap/service/roadmap_service.dart';

const _fallbackRoadmapBaseUrl = 'http://127.0.0.1:8000/api/v1';

Future<ChapterSubcontentResponseModel> fetchChapterSubcontent(
  ChapterSubcontentGenerateRequestModel request, {
  http.Client? client,
}) async {
  // Resolve the roadmap ID: prefer the one on the request, then the cache
  // keyed by this course, then the most-recently-generated one.
  final resolvedRoadmapId =
      _sanitize(request.roadmapId) ??
      const RoadmapIdCache().readRoadmapId(cacheKey: request.roadmapCacheKey) ??
      const RoadmapIdCache().readRoadmapId();

  // If we have no ID at all, roadmap_json must be present — the server will
  // use it as a fallback. Generate a placeholder ID so validation passes.
  final effectiveRoadmapId = resolvedRoadmapId ?? 'unknown';

  // Use the stable roadmap cache key (topic/language/level) rather than the
  // roadmap ID, which can differ between sessions (DB vs. freshly generated).
  final subcontentCacheKey = request.roadmapCacheKey ?? effectiveRoadmapId;
  final cached = await const GenerationCache().readChapterSubcontent(
    roadmapKey: subcontentCacheKey,
    chapterNumber: request.chapterNumber,
  );
  if (cached != null) {
    return ChapterSubcontentResponseModel.fromRawJson(cached);
  }

  if (effectiveRoadmapId != 'unknown') {
    try {
      final row = await RoadmapService.instance.fetchChapterProgress(
        roadmapId: effectiveRoadmapId,
        chapterNumber: request.chapterNumber,
      );
      final subcontentJson = row?.chapterSubcontentJson;
      if (subcontentJson != null) {
        final responseJson = {
          'status_code': 200,
          'code': 'ok',
          'message': '',
          'model': '',
          'course_type': subcontentJson['course_type'] ?? 'school',
          'chapter_subcontent': subcontentJson,
        };
        final rawJson = jsonEncode(responseJson);
        await const GenerationCache().saveChapterSubcontent(
          roadmapKey: subcontentCacheKey,
          chapterNumber: request.chapterNumber,
          rawJson: rawJson,
        );
        return ChapterSubcontentResponseModel.fromRawJson(rawJson);
      }
    } catch (_) {}
  }

  final activeClient = client ?? http.Client();

  try {
    final response = await _postChapterSubcontent(
      activeClient,
      request.toJson(resolvedRoadmapId: effectiveRoadmapId),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChapterSubcontentRequestException(
        'Failed to generate chapter subcontent (${response.statusCode}): '
        '${_extractErrorMessage(response)}',
      );
    }

    final rawJson = utf8.decode(response.bodyBytes);
    final result = ChapterSubcontentResponseModel.fromRawJson(rawJson);
    await const GenerationCache().saveChapterSubcontent(
      roadmapKey: subcontentCacheKey,
      chapterNumber: request.chapterNumber,
      rawJson: rawJson,
    );
    return result;
  } on SocketException catch (error) {
    throw ChapterSubcontentRequestException(
      'Could not reach the FastAPI chapter subcontent API at '
      '${_buildChapterSubcontentUri()}. Make sure the backend is running. '
      'Original error: $error',
    );
  } on HttpException catch (error) {
    throw ChapterSubcontentRequestException(
      'HTTP error while calling ${_buildChapterSubcontentUri()}: $error',
    );
  } on http.ClientException catch (error) {
    throw ChapterSubcontentRequestException(
      'Client error while calling ${_buildChapterSubcontentUri()}: $error. '
      'If you are on Android, ensure cleartext HTTP is allowed for the local backend.',
    );
  } finally {
    if (client == null) {
      activeClient.close();
    }
  }
}

Future<http.Response> _postChapterSubcontent(
  http.Client client,
  Map<String, dynamic> body,
) async {
  Object? lastConnectionError;
  final uris = _chapterSubcontentUris();

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

  throw ChapterSubcontentRequestException(
    'Could not reach the FastAPI chapter subcontent API. '
    'Last error: $lastConnectionError',
  );
}

Uri _buildChapterSubcontentUri() {
  return _chapterSubcontentUris().first;
}

List<Uri> _chapterSubcontentUris() {
  final configuredBaseUrl = ApiConstants.roadmapBaseUrl.trim();
  final baseUrl = configuredBaseUrl.isEmpty
      ? _fallbackRoadmapBaseUrl
      : configuredBaseUrl;
  final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final primary = Uri.parse(
    '$normalizedBaseUrl/openrouter/chapter-subcontent/generate',
  );
  final fallback = Uri.parse(
    '$_fallbackRoadmapBaseUrl/openrouter/chapter-subcontent/generate',
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
    if (message is String && message.trim().isNotEmpty) {
      return message;
    }

    final detail = decoded['detail'];
    if (detail is String && detail.trim().isNotEmpty) {
      return detail;
    }
    if (detail is Map<String, dynamic>) {
      final nestedMessage = detail['message'];
      if (nestedMessage is String && nestedMessage.trim().isNotEmpty) {
        return nestedMessage;
      }
      return detail.toString();
    }
    if (detail is List && detail.isNotEmpty) {
      return detail.toString();
    }
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

String? _sanitize(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

class ChapterSubcontentRequestException implements Exception {
  const ChapterSubcontentRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
