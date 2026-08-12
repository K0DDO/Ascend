import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _accessTokenKey = 'ascend_access_token';
const _refreshTokenKey = 'ascend_refresh_token';
const _demoModeKey = 'ascend_demo_mode';

class TokenStorage {
  TokenStorage(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> saveTokens({required String accessToken, required String refreshToken}) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
  }

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> isDemoMode() async {
    final value = await _storage.read(key: _demoModeKey);
    return value == 'true';
  }

  Future<void> setDemoMode(bool enabled) async {
    if (enabled) {
      await _storage.write(key: _demoModeKey, value: 'true');
    } else {
      await _storage.delete(key: _demoModeKey);
    }
  }
}
