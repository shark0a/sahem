import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

import 'package:sahem/core/errors/exceptions.dart';
import 'package:sahem/core/network/cache_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    final cacheOptions = CacheOptions(
      store: MemCacheStore(),
      policy: CachePolicy.forceCache,
      maxStale: const Duration(hours: 1),
    );

    dio.interceptors.addAll([
      AppCacheInterceptor(options: cacheOptions),
      DioCacheInterceptor(options: cacheOptions),
      LogInterceptor(
        requestBody: false,
        requestHeader: false,
        responseHeader: false,
      ),
      _ErrorInterceptor(),
    ]);

    return dio;
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        throw const NetworkException(message: 'Connection timed out');
      case DioExceptionType.badResponse:
        throw ServerException(
          statusCode: err.response?.statusCode,
          message: err.response?.statusMessage ?? 'Server error',
        );
      case DioExceptionType.cancel:
        break;
      default:
        throw NetworkException(message: err.message ?? 'Network error');
    }
    handler.next(err);
  }
}
