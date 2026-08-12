import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../data/models/auth_models.dart';
import '../../data/models/ai_interview_models.dart';
import '../../data/models/course_models.dart';
import '../../data/models/entitlement_models.dart';
import '../../data/models/gamification_models.dart';
import '../../data/models/learning_models.dart';
import '../../data/models/progress_models.dart';
import '../../data/storage/device_info_service.dart';
import '../../data/storage/token_storage.dart';
import '../config/api_config.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AscendApiClient {
  AscendApiClient({
    required Dio dio,
    required TokenStorage tokenStorage,
    required DeviceInfoService deviceInfo,
  })  : _dio = dio,
        _tokenStorage = tokenStorage,
        _deviceInfo = deviceInfo {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _tokenStorage.readAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401 &&
              error.requestOptions.extra['retried'] != true) {
            try {
              final refreshed = await refreshTokens();
              final opts = error.requestOptions;
              opts.headers['Authorization'] = 'Bearer ${refreshed.accessToken}';
              opts.extra['retried'] = true;
              final response = await _dio.fetch(opts);
              return handler.resolve(response);
            } catch (_) {
              await _tokenStorage.clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;
  final DeviceInfoService _deviceInfo;

  Dio get dio => _dio;

  Future<Map<String, dynamic>> _devicePayload() async {
    return {
      'device_id': await _deviceInfo.deviceId(),
      'platform': _deviceInfo.platform,
      'app_version': ApiConfig.appVersion,
    };
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final payload = {
      'email': email,
      'password': password,
      'display_name': displayName,
      ...await _devicePayload(),
    };
    final response = await _dio.post('${ApiConfig.apiPrefix}/auth/register', data: payload);
    return _parseAuthResponse(response);
  }

  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final payload = {
      'email': email,
      'password': password,
      ...await _devicePayload(),
    };
    final response = await _dio.post('${ApiConfig.apiPrefix}/auth/login', data: payload);
    return _parseAuthResponse(response);
  }

  Future<TokenPair> refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw ApiException('Session expired', statusCode: 401);
    }
    final response = await _dio.post(
      '${ApiConfig.apiPrefix}/auth/refresh',
      data: {
        'refresh_token': refreshToken,
        'device_id': await _deviceInfo.deviceId(),
      },
    );
    final tokens = TokenPair.fromJson(response.data as Map<String, dynamic>);
    await _tokenStorage.saveTokens(
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
    );
    return tokens;
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _dio.post(
          '${ApiConfig.apiPrefix}/auth/logout',
          data: {'refresh_token': refreshToken},
        );
      } on DioException {
        // Best-effort server logout; local session is cleared regardless.
      }
    }
    await _tokenStorage.clearTokens();
  }

  Future<AscendUser> fetchMe() async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/auth/me');
    return AscendUser.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CourseListResponse> fetchCourses() async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/courses');
    return CourseListResponse.fromJson(response.data as Map<String, dynamic>);
  }

  Future<CourseDetail> fetchCourse(String courseId) async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/courses/$courseId');
    return CourseDetail.fromJson(response.data as Map<String, dynamic>);
  }

  Future<List<EntitlementItem>> fetchEntitlements() async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/me/entitlements');
    final features = (response.data as Map<String, dynamic>)['features'] as List<dynamic>? ?? const [];
    return features
        .map((item) => EntitlementItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CardPreview>> fetchTopicCards(String topicId) async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/topics/$topicId/cards');
    final cards = (response.data as Map<String, dynamic>)['cards'] as List<dynamic>? ?? const [];
    return cards.map((item) => CardPreview.fromJson(item as Map<String, dynamic>)).toList();
  }

  Future<ReviewResult> recordReview(ReviewSignal signal) async {
    final response = await _dio.post(
      '${ApiConfig.apiPrefix}/learning/reviews',
      data: signal.toJson(),
    );
    return ReviewResult.fromJson(response.data as Map<String, dynamic>);
  }

  Future<TopicProgress> fetchTopicProgress(String topicId) async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/learning/topics/$topicId/progress');
    return TopicProgress.fromJson(response.data as Map<String, dynamic>);
  }

  Future<DueQueue> fetchDueQueue(String topicId, {int limit = 20}) async {
    final response = await _dio.get(
      '${ApiConfig.apiPrefix}/learning/topics/$topicId/queue',
      queryParameters: {'limit': limit},
    );
    return DueQueue.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ProgressOverview> fetchProgressOverview() async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/progress/overview');
    return ProgressOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<GamificationOverview> fetchGamificationOverview() async {
    final response = await _dio.get('${ApiConfig.apiPrefix}/gamification/overview');
    return GamificationOverview.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InterviewSession> startInterview({
    required String topicId,
    int questionCount = 3,
  }) async {
    final response = await _dio.post(
      '${ApiConfig.apiPrefix}/ai/interviews/start',
      data: {
        'topic_id': topicId,
        'question_count': questionCount,
      },
    );
    return InterviewSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<InterviewSession> answerInterview({
    required String sessionId,
    required String answer,
  }) async {
    final response = await _dio.post(
      '${ApiConfig.apiPrefix}/ai/interviews/$sessionId/answer',
      data: {'answer': answer},
    );
    return InterviewSession.fromJson(response.data as Map<String, dynamic>);
  }

  Future<AuthResult> _parseAuthResponse(Response<dynamic> response) async {
    final result = AuthResult.fromJson(response.data as Map<String, dynamic>);
    await _tokenStorage.saveTokens(
      accessToken: result.tokens.accessToken,
      refreshToken: result.tokens.refreshToken,
    );
    return result;
  }

  static String messageFromDio(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final nested = data['error'];
      if (nested is Map<String, dynamic> && nested['message'] is String) {
        return nested['message'] as String;
      }
      if (data['detail'] is String) {
        return data['detail'] as String;
      }
    }
    return 'Не удалось выполнить запрос. Проверьте подключение.';
  }
}

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

final tokenStorageProvider = Provider<TokenStorage>((ref) {
  return TokenStorage(ref.watch(secureStorageProvider));
});

final deviceInfoProvider = Provider<DeviceInfoService>((ref) {
  return DeviceInfoService(ref.watch(secureStorageProvider));
});

final dioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 12),
      receiveTimeout: const Duration(seconds: 12),
      headers: {'Accept': 'application/json'},
    ),
  );
});

final apiClientProvider = Provider<AscendApiClient>((ref) {
  return AscendApiClient(
    dio: ref.watch(dioProvider),
    tokenStorage: ref.watch(tokenStorageProvider),
    deviceInfo: ref.watch(deviceInfoProvider),
  );
});
