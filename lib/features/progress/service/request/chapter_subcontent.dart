import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/chapter_subcontent_model.dart';

const _fallbackRoadmapBaseUrl = 'http://127.0.0.1:8000/api/v1';

Future<ChapterSubcontentResponseModel> fetchChapterSubcontent(
  ChapterSubcontentGenerateRequestModel request, {
  http.Client? client,
}) async {
  final resolvedRoadmapId =
      _sanitize(request.roadmapId) ??
      const RoadmapIdCache().readRoadmapId(cacheKey: request.roadmapCacheKey) ??
      const RoadmapIdCache().readRoadmapId();

  if (resolvedRoadmapId == null) {
    throw const ChapterSubcontentRequestException(
      'No roadmap id was provided and no cached roadmap id was found. '
      'Generate the roadmap first so the roadmap id can be cached.',
    );
  }

  final activeClient = client ?? http.Client();

  try {
    final response = await _postChapterSubcontent(
      activeClient,
      request.toJson(resolvedRoadmapId: resolvedRoadmapId),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ChapterSubcontentRequestException(
        'Failed to generate chapter subcontent (${response.statusCode}): '
        '${_extractErrorMessage(response)}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) {
      throw const FormatException(
        'Chapter subcontent response is not a JSON object.',
      );
    }

    return ChapterSubcontentResponseModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
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
  final configuredUrl = ApiConstants.openRouterChapterSubcontentGenerate.trim();
  final configuredUri = Uri.tryParse(configuredUrl);
  final hasAbsoluteConfiguredUrl =
      configuredUri != null &&
      configuredUri.hasScheme &&
      configuredUri.host.isNotEmpty;
  final endpointUrl = hasAbsoluteConfiguredUrl
      ? configuredUrl
      : '$normalizedBaseUrl/openrouter/chapter-subcontent/generate';

  final primary = Uri.parse(endpointUrl);
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
  if (trimmed == null || trimmed.isEmpty) {
    return null;
  }
  return trimmed;
}

class ChapterSubcontentRequestException implements Exception {
  const ChapterSubcontentRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
