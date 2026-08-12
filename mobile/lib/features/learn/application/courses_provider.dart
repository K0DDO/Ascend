import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../data/local/database_provider.dart';
import '../../../data/models/course_models.dart';
import '../../sync/application/content_sync_service.dart';
final contentSyncServiceProvider = FutureProvider<ContentSyncService>((ref) async {
  final store = await ref.watch(localContentStoreProvider.future);
  final api = ref.watch(apiClientProvider);
  final deviceInfo = ref.watch(deviceInfoProvider);
  return ContentSyncService(api, store, deviceInfo);
});

final coursesProvider = FutureProvider<CoursesSnapshot>((ref) async {
  final sync = await ref.watch(contentSyncServiceProvider.future);
  return sync.syncAndLoad();
});

final courseDetailProvider = FutureProvider.family<CourseDetail?, String>((ref, courseId) async {
  final sync = await ref.watch(contentSyncServiceProvider.future);
  return sync.readCourseDetail(courseId);
});
