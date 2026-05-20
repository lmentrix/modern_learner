import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:modern_learner_production/core/constants/api_constants.dart';
import 'package:modern_learner_production/features/progress/service/cache/roadmap_id_cache.dart';
import 'package:modern_learner_production/features/progress/service/model/roadmap_model.dart';

const _fallbackRoadmapBaseUrl = 'http://127.0.0.1:8000/api/v1';

Future<RoadmapResponseModel> fetchProgress(
  RoadmapGenerateRequestModel request, {
  http.Client? client,
}) async {
  final activeClient = client ?? http.Client();

  try {
    final response = await activeClient
        .post(
          _buildRoadmapGenerateUri(),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(request.toJson()),
        )
        .timeout(ApiConstants.receiveTimeout);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw RoadmapRequestException(
        'Failed to generate roadmap (${response.statusCode}): '
        '${_extractErrorMessage(response)}',
      );
    }

    final decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! Map) {
      throw const FormatException('Roadmap response is not a JSON object.');
    }

    final roadmapResponse = RoadmapResponseModel.fromJson(
      Map<String, dynamic>.from(decoded),
    );
    final roadmapId = roadmapResponse.roadmap.id;
    if (roadmapId != null && roadmapId.trim().isNotEmpty) {
      await const RoadmapIdCache().saveRoadmapId(
        roadmapId: roadmapId,
        cacheKey: RoadmapIdCache.buildRoadmapCacheKey(
          roadmapMode: request.roadmapMode,
          topic: request.topic,
          language: request.language,
          level: request.level,
          nativeLanguage: request.nativeLanguage,
        ),
      );
    }

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

Uri _buildRoadmapGenerateUri() {
  final configuredBaseUrl = ApiConstants.roadmapBaseUrl.trim();
  final baseUrl = configuredBaseUrl.isEmpty
      ? _fallbackRoadmapBaseUrl
      : configuredBaseUrl;
  final normalizedBaseUrl = baseUrl.endsWith('/')
      ? baseUrl.substring(0, baseUrl.length - 1)
      : baseUrl;
  final configuredOpenRouterUrl = ApiConstants.openRouterRoadmapGenerate.trim();
  final configuredOpenRouterUri = Uri.tryParse(configuredOpenRouterUrl);
  final hasAbsoluteConfiguredUrl =
      configuredOpenRouterUri != null &&
      configuredOpenRouterUri.hasScheme &&
      configuredOpenRouterUri.host.isNotEmpty;
  final openRouterUrl = hasAbsoluteConfiguredUrl
      ? configuredOpenRouterUrl
      : '$normalizedBaseUrl/openrouter/roadmaps/generate';

  return Uri.parse(openRouterUrl);
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

class RoadmapRequestException implements Exception {
  const RoadmapRequestException(this.message);

  final String message;

  @override
  String toString() => message;
}
