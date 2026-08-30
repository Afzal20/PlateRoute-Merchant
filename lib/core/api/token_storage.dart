import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _kAccessKey = 'pr_access';
const _kRefreshKey = 'pr_refresh';

/// Securely stores and retrieves JWT access + refresh tokens.
class TokenStorage {
  const TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<String?> getAccess() => _storage.read(key: _kAccessKey);
  Future<String?> getRefresh() => _storage.read(key: _kRefreshKey);

  Future<void> saveAccess(String token) =>
      _storage.write(key: _kAccessKey, value: token);

  Future<void> saveRefresh(String token) =>
      _storage.write(key: _kRefreshKey, value: token);

  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    await saveAccess(access);
    await saveRefresh(refresh);
  }

  Future<void> clear() async {
    await _storage.delete(key: _kAccessKey);
    await _storage.delete(key: _kRefreshKey);
  }

  Future<bool> hasTokens() async {
    final access = await getAccess();
    return access != null && access.isNotEmpty;
  }
}
