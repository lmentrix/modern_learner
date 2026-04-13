class ServerException implements Exception {
  const ServerException({this.message = 'Server error occurred.', this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class CacheException implements Exception {
  const CacheException({this.message = 'Cache error occurred.'});
  final String message;

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException implements Exception {
  const NetworkException({this.message = 'No internet connection.'});
  final String message;

  @override
  String toString() => 'NetworkException: $message';
}

class UnauthorizedException implements Exception {
  const UnauthorizedException({this.message = 'Unauthorized.'});
  final String message;

  @override
  String toString() => 'UnauthorizedException: $message';
}

