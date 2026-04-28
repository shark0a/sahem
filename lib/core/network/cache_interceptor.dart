import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Extends DioCacheInterceptor with custom cache-busting logic.
/// Registered in DioClient.create() alongside other interceptors.
class AppCacheInterceptor extends Interceptor {
  final CacheOptions options;

  AppCacheInterceptor({required this.options});

  @override
  void onRequest(RequestOptions request, RequestInterceptorHandler handler) {
    if (request.method.toUpperCase() == 'GET') {
      request.extra = {
        ...request.extra,
        ...options.toExtra(),
      };
    } else {
      request.extra = {
        ...request.extra,
        ...options.copyWith(policy: CachePolicy.noCache).toExtra(),
      };
    }
    handler.next(request);
  }
}
