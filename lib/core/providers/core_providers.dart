import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../api/api_client.dart';
import '../api/token_storage.dart';

/// Provides [FlutterSecureStorage] singleton.
final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  ),
);

/// Provides [TokenStorage].
final tokenStorageProvider = Provider<TokenStorage>(
  (ref) => TokenStorage(ref.watch(secureStorageProvider)),
);

/// Provides the initialized [ApiClient]. This is async because we need to
/// load the .env file before construction.
final apiClientProvider = FutureProvider<ApiClient>((ref) async {
  final tokenStorage = ref.watch(tokenStorageProvider);
  return ApiClient.create(tokenStorage);
});
