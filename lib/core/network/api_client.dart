import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import 'package:modern_learner_production/core/constants/api_constants.dart';

@lazySingleton
class ApiClient {
  ApiClient(this._dio) {
    _dio
      ..options = BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: ApiConstants.connectTimeout,
        receiveTimeout: ApiConstants.receiveTimeout,
        sendTimeout: ApiConstants.sendTimeout,
        headers: {'Content-Type': 'application/json'},
      )
      ..interceptors.addAll([
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
        ),
      ]);
  }

  final Dio _dio;

  Dio get dio => _dio;
}
