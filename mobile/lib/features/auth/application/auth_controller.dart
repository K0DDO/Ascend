import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/models/auth_models.dart';
import '../data/auth_repository.dart';

enum AuthStatus { loading, unauthenticated, authenticated, guest }

@immutable
class AuthState {
  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
  });

  const AuthState.loading() : this(status: AuthStatus.loading);

  const AuthState.unauthenticated({String? errorMessage})
      : this(status: AuthStatus.unauthenticated, errorMessage: errorMessage);

  const AuthState.authenticated(AscendUser user)
      : this(status: AuthStatus.authenticated, user: user);

  const AuthState.guest() : this(status: AuthStatus.guest);

  final AuthStatus status;
  final AscendUser? user;
  final String? errorMessage;

  bool get isSignedIn => status == AuthStatus.authenticated;
  bool get isGuest => status == AuthStatus.guest;
  bool get canUseApp => isSignedIn || isGuest;
}

class AuthController extends StateNotifier<AuthState> {
  AuthController(this._repository, {bool autoBootstrap = true}) : super(const AuthState.loading()) {
    if (autoBootstrap) {
      bootstrap();
    }
  }

  final AuthRepository _repository;

  Future<void> bootstrap() async {
    try {
      if (await _repository.isDemoMode()) {
        state = const AuthState.guest();
        return;
      }
      final user = await _repository.restoreSession();
      state = user != null ? AuthState.authenticated(user) : const AuthState.unauthenticated();
    } catch (_) {
      state = const AuthState.unauthenticated();
    }
  }

  Future<void> login({required String email, required String password}) async {
    state = const AuthState.loading();
    try {
      final result = await _repository.login(email: email, password: password);
      state = AuthState.authenticated(result.user);
    } on DioException catch (error) {
      state = AuthState.unauthenticated(
        errorMessage: AscendApiClient.messageFromDio(error),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AuthState.loading();
    try {
      final result = await _repository.register(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = AuthState.authenticated(result.user);
    } on DioException catch (error) {
      state = AuthState.unauthenticated(
        errorMessage: AscendApiClient.messageFromDio(error),
      );
    }
  }

  Future<void> enterDemoMode() async {
    state = const AuthState.loading();
    await _repository.enableDemoMode();
    state = const AuthState.guest();
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    await _repository.logout();
    state = const AuthState.unauthenticated();
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(ref.watch(authRepositoryProvider));
});
