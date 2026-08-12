import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/models/auth_models.dart';
import '../../../data/storage/token_storage.dart';
import '../../learn/application/courses_provider.dart';

typedef ContentWipeCallback = Future<void> Function();

class AuthRepository {
  AuthRepository(
    this._api,
    this._tokenStorage, {
    ContentWipeCallback? wipeLocalContent,
  }) : _wipeLocalContent = wipeLocalContent;

  final AscendApiClient _api;
  final TokenStorage _tokenStorage;
  final ContentWipeCallback? _wipeLocalContent;

  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) {
    return _api.register(email: email, password: password, displayName: displayName);
  }

  Future<AuthResult> login({required String email, required String password}) {
    return _api.login(email: email, password: password);
  }

  Future<AscendUser?> restoreSession() async {
    if (await _tokenStorage.isDemoMode()) {
      return null;
    }
    final access = await _tokenStorage.readAccessToken();
    final refresh = await _tokenStorage.readRefreshToken();
    if (access == null && refresh == null) {
      return null;
    }
    try {
      return await _api.fetchMe();
    } on DioException catch (error) {
      if (error.response?.statusCode == 401 && refresh != null) {
        await _api.refreshTokens();
        return _api.fetchMe();
      }
      await _tokenStorage.clearTokens();
      return null;
    }
  }

  Future<void> logout() async {
    await _api.logout();
    await _wipeLocalContent?.call();
    await _tokenStorage.setDemoMode(false);
  }

  Future<void> enableDemoMode() async {
    await _api.logout();
    await _wipeLocalContent?.call();
    await _tokenStorage.setDemoMode(true);
  }

  Future<void> disableDemoMode() async {
    await _tokenStorage.setDemoMode(false);
  }

  Future<bool> isDemoMode() => _tokenStorage.isDemoMode();
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(apiClientProvider),
    ref.watch(tokenStorageProvider),
    wipeLocalContent: () async {
      final store = await ref.read(localContentStoreProvider.future);
      await store.wipeAll();
      ref.invalidate(ascendDatabaseProvider);
      ref.invalidate(localContentStoreProvider);
      ref.invalidate(coursesProvider);
    },
  );
});
