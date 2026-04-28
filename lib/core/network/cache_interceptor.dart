import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';

/// Extends DioCacheInterceptor with custom cache-busting logic.
/// Registered in DioClient.create() alongside other interceptors.
class AppCacheInterceptor extends Interceptor {
  final CacheOptions options;

  AppCacheInterceptor({required this.options});

  @override
  void onRequest(
      RequestOptions request, RequestInterceptorHandler handler) {
    // Force network on POST/PUT/DELETE — only cache GETs
    if (request.method != 'GET') {
      request.extra = {
        ...request.extra,
        DioCacheInterceptor.extraKey: options.copyWith(
          policy: CachePolicy.noCache,
        ),
      };
    }
    handler.next(request);
  }
}
