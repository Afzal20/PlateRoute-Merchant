import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_storage.dart';

const _kAccessKey = 'access_token';
const _kRefreshKey = 'refresh_token';

/// Base Dio instance wired with JWT auth, token refresh and idempotency.
class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    required Dio dio,
  })  : _tokenStorage = tokenStorage,
        _dio = dio;

  final TokenStorage _tokenStorage;
  final Dio _dio;

  Dio get dio => _dio;

  /// Builds Dio with all interceptors stacked.
  static Future<ApiClient> create(TokenStorage tokenStorage) async {
    final baseUrl = dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:8000/api/v1/';

    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // 1. Auth header injection
    dio.interceptors.add(_AuthInterceptor(tokenStorage: tokenStorage, dio: dio));

    // 2. Idempotency key (MOB-C-04) — injected by callers via Options.extra
    dio.interceptors.add(_IdempotencyInterceptor());

    return ApiClient(tokenStorage: tokenStorage, dio: dio);
  }
}

/// Injects Authorization header and handles 401 -> token refresh.
class _AuthInterceptor extends QueuedInterceptorsWrapper {
  _AuthInterceptor({required this.tokenStorage, required this.dio});

  final TokenStorage tokenStorage;
  final Dio dio;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStorage.getAccess();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      handler.next(err);
      return;
    }

    final refresh = await tokenStorage.getRefresh();
    if (refresh == null) {
      await tokenStorage.clear();
      handler.next(err);
      return;
    }

    try {
      // Avoid using the authenticated dio instance for refresh to prevent loops
      final refreshDio = Dio(BaseOptions(baseUrl: dio.options.baseUrl));
      final response = await refreshDio.post(
        '../auth/token/refresh/',
        data: {'refresh': refresh},
      );

      final newAccess = response.data['access'] as String?;
      if (newAccess == null) throw Exception('no access in refresh response');

      await tokenStorage.saveAccess(newAccess);

      // Retry original request with new token
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $newAccess';

      final retryResponse = await dio.fetch(retryOptions);
      handler.resolve(retryResponse);
    } catch (_) {
      await tokenStorage.clear();
      handler.next(err);
    }
  }
}

/// Injects Idempotency-Key header when callers set it via Options.extra.
/// Usage: dio.post('/orders/accept/', options: Options(extra: {'idempotencyKey': key}))
class _IdempotencyInterceptor extends InterceptorsWrapper {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final key = options.extra['idempotencyKey'] as String?;
    if (key != null) {
      options.headers['Idempotency-Key'] = key;
    }
    handler.next(options);
  }
}
