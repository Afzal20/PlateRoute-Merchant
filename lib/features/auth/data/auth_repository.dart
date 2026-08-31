import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/core_providers.dart';

class LoginResult {
  const LoginResult({
    required this.access,
    required this.refresh,
    required this.vendorStatus,
  });

  final String access;
  final String refresh;
  final String vendorStatus;
}

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;

  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final resp = await _dio.post(
      '/auth/login/',
      data: {'email': email, 'password': password},
    );

    final access = resp.data['access'] as String? ?? '';
    final refresh = resp.data['refresh'] as String? ?? '';

    // After login, fetch vendor status
    String vendorStatus = 'approved';
    try {
      final vendorResp = await _dio.get(
        '/vendors/',
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      final results = vendorResp.data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        vendorStatus = results.first['status'] as String? ?? 'approved';
      }
    } catch (_) {
      // If vendor fetch fails, assume approved and let auth proceed
    }

    return LoginResult(
      access: access,
      refresh: refresh,
      vendorStatus: vendorStatus,
    );
  }

  Future<LoginResult> loginWithGoogleToken(String accessToken) async {
    final resp = await _dio.post(
      '/auth/google/login/',
      data: {'access_token': accessToken},
    );

    final access = resp.data['access'] as String? ?? '';
    final refresh = resp.data['refresh'] as String? ?? '';

    // After login, fetch vendor status
    String vendorStatus = 'approved';
    try {
      final vendorResp = await _dio.get(
        '/vendors/',
        options: Options(headers: {'Authorization': 'Bearer $access'}),
      );
      final results = vendorResp.data['results'] as List?;
      if (results != null && results.isNotEmpty) {
        vendorStatus = results.first['status'] as String? ?? 'approved';
      }
    } catch (_) {
      // If vendor fetch fails, assume approved and let auth proceed
    }

    return LoginResult(
      access: access,
      refresh: refresh,
      vendorStatus: vendorStatus,
    );
  }

  Future<void> logout(Dio dio) async {
    await dio.post('/auth/logout/');
  }

  Future<void> requestPasswordReset(String email) async {
    await _dio.post('/auth/password-reset-otp/', data: {'email': email});
  }

  Future<void> confirmPasswordReset({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    await _dio.post(
      '/auth/password-reset-otp/confirm/',
      data: {'email': email, 'otp': otp, 'new_password': newPassword},
    );
  }

  Future<void> registerFcmToken(String fcmToken) async {
    await _dio.post(
      '/notifications/devices/',
      data: {'token': fcmToken, 'platform': 'android'},
    );
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  // Sync fallback — if API client not yet ready, use plain Dio
  final apiClientAsync = ref.watch(apiClientProvider);
  final dio = apiClientAsync.when(
    data: (c) => c.dio,
    loading: () => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
    error: (_, __) => Dio(BaseOptions(baseUrl: 'http://10.0.2.2:8000/api/v1/')),
  );
  return AuthRepository(dio);
});
