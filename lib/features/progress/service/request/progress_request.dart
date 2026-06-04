import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/cache/generation_cache.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';

const _fallbackRoadmapBaseUrl = 'http://127.0.0.1:8000/api/v1';

Future<RoadmapResponseModel> fetchProgress(
  RoadmapGenerateRequestModel request, {
  http.Client? client,
  bool bypassCache = false,
}) async {
  final cacheKey = RoadmapIdCache.buildRoadmapCacheKey(
    roadmapMode: request.roadmapMode,
    topic: request.topic,
    language: request.language,
    level: request.level,
    nativeLanguage: request.nativeLanguage,
  );

  const generationCache = GenerationCache();
  final cached = bypassCache
      ? null
      : await generationCache.readRoadmap(cacheKey);
  if (cached != null) {
    try {
      final cachedResponse = RoadmapResponseModel.fromRawJson(cached);
      if (!_isStaleGeneratedRoadmap(cachedResponse)) {
        return cachedResponse;
      }
      await generationCache.clearRoadmap(cacheKey);
    } catch (_) {
      await generationCache.clearRoadmap(cacheKey);
    }
  }

  final activeClient = client ?? http.Client();

  try {
    final response = await _postRoadmapGenerate(activeClient, request.toJson());

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RoadmapRequestException(
        'Failed to generate roadmap (${response.statusCode}): '
        '${_extractErrorMessage(response)}',
      );
    }

    final rawJson = utf8.decode(response.bodyBytes);
    final roadmapResponse = RoadmapResponseModel.fromRawJson(rawJson);
    if (_isStaleGeneratedRoadmap(roadmapResponse)) {
      throw const RoadmapRequestException(
        'The roadmap generator returned a mock/offline roadmap. Try again when the roadmap backend is available.',
      );
    }
    final roadmapId = roadmapResponse.roadmap.id;
    if (roadmapId != null && roadmapId.trim().isNotEmpty) {
      await const RoadmapIdCache().saveRoadmapId(
        roadmapId: roadmapId,
        cacheKey: cacheKey,
      );
    }
    await generationCache.saveRoadmap(cacheKey, rawJson);

    return roadmapResponse;
  } on SocketException catch (error) {
    throw RoadmapRequestException(
      'Could not reach the FastAPI roadmap API at '
      '${_buildRoadmapGenerateUri()}. Make sure the backend is running. '
      'Original error: $error',
    );
  } on HttpException catch (error) {
    throw RoadmapRequestException(
      'HTTP error while calling ${_buildRoadmapGenerateUri()}: $error',
    );
  } on http.ClientException catch (error) {
    throw RoadmapRequestException(
      'Client error while calling ${_buildRoadmapGenerateUri()}: $error. '
      'If you are on Android, ensure cleartext HTTP is allowed for the local backend.',
    );
  } finally {
    if (client == null) {
      activeClient.close();
    }
  }
}

Future<http.Response> _postRoadmapGenerate(
  http.Client client,
  Map<String, dynamic> body,
) async {
  Object? lastConnectionError;
  final uris = _roadmapGenerateUris();

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

  throw RoadmapRequestException(
    'Could not reach the FastAPI roadmap API. Last error: $lastConnectionError',
  );
}

Uri _buildRoadmapGenerateUri() {
  return _roadmapGenerateUris().first;
}

List<Uri> _roadmapGenerateUris() {
  final configuredBaseUrl = ApiConstants.roadmapBaseUrl.trim();
  final baseUrl = configuredBaseUrl.isEmpty
      ? _fallbackRoadmapBaseUrl
      : configuredBaseUrl;
  final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final primary = Uri.parse('$normalizedBaseUrl/openrouter/roadmaps/generate');
  final fallback = Uri.parse(
    '$_fallbackRoadmapBaseUrl/openrouter/roadmaps/generate',
  );
  if (primary == fallback) return [primary];
  return [primary, fallback];
}

String _extractErrorMessage(http.Response response) {
  if (response.bodyBytes.isEmpty) {
    return response.reasonPhrase ?? 'Empty response body';
  }

  final body = utf8.decode(response.bodyBytes);
  final decoded = jsonDecodeSafe(body);
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

Object? jsonDecodeSafe(String raw) {
  try {
    return jsonDecode(raw);
  } catch (_) {
    return null;
  }
}

bool _isStaleGeneratedRoadmap(RoadmapResponseModel response) {
  final code = response.code.toLowerCase();
  final model = response.model.toLowerCase();
  final message = response.message.toLowerCase();
  final summary = response.roadmap.summary.toLowerCase();
  final id = (response.roadmap.id ?? '').toLowerCase();
  return response.mocked ||
      code.contains('mock') ||
      code.contains('offline_fallback') ||
      model == 'offline-fallback' ||
      message.contains('mock roadmap') ||
      summary.contains('deterministic offline') ||
      id.startsWith('mock') ||
      id.contains('_mock');
}

class RoadmapRequestException implements Exception {
  const RoadmapRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
