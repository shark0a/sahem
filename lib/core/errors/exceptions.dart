class ServerException implements Exception {
  final String? message;
  final int? statusCode;
  const ServerException({this.message, this.statusCode});

  @override
  String toString() =>
      'ServerException(statusCode: $statusCode, message: $message)';
}

class CacheException implements Exception {
  final String? message;
  const CacheException({this.message});

  @override
  String toString() => 'CacheException(message: $message)';
}

class NetworkException implements Exception {
  final String? message;
  const NetworkException({this.message});

  @override
  String toString() => 'NetworkException(message: $message)';
}

class LocationException implements Exception {
  final String? message;
  const LocationException({this.message});

  @override
  String toString() => 'LocationException(message: $message)';
}
