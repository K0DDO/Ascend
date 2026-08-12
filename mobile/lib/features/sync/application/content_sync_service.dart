import '../../../core/network/api_client.dart';
import '../../../data/local/local_content_store.dart';
import '../../../data/models/course_models.dart';

enum ContentDataSource { network, cache }

class CoursesSnapshot {
  const CoursesSnapshot({
    required this.courses,
    required this.source,
    this.syncedAt,
  });

  final List<CourseSummary> courses;
  final ContentDataSource source;
  final DateTime? syncedAt;
}

class ContentSyncService {
  ContentSyncService(this._api, this._store);

  final AscendApiClient _api;
  final LocalContentStore _store;

  Future<CoursesSnapshot> syncAndLoad() async {
    try {
      await _syncFromNetwork();
      final courses = await _store.readCourses();
      final syncedAtRaw = await _store.readSyncMeta('last_sync_at');
      return CoursesSnapshot(
        courses: courses,
        source: ContentDataSource.network,
        syncedAt: syncedAtRaw != null ? DateTime.tryParse(syncedAtRaw) : null,
      );
    } catch (_) {
      final courses = await _store.readCourses();
      if (courses.isEmpty) rethrow;
      final syncedAtRaw = await _store.readSyncMeta('last_sync_at');
      return CoursesSnapshot(
        courses: courses,
        source: ContentDataSource.cache,
        syncedAt: syncedAtRaw != null ? DateTime.tryParse(syncedAtRaw) : null,
      );
    }
  }

  Future<CourseDetail?> readCourseDetail(String courseId) {
    return _store.readCourseDetail(courseId);
  }

  Future<void> wipeAll() => _store.wipeAll();

  Future<void> _syncFromNetwork() async {
    final entitlements = await _api.fetchEntitlements();
    await _store.saveEntitlements(
      entitlements
          .map(
            (item) => (
              key: item.key,
              constraints: item.constraints,
              endsAt: item.endsAt,
            ),
          )
          .toList(),
    );

    final listing = await _api.fetchCourses();
    await _store.upsertCourses(listing.courses);
    await _store.purgeCoursesNotIn(listing.courses.map((course) => course.id).toSet());

    for (final course in listing.courses) {
      if (course.locked) continue;
      final detail = await _api.fetchCourse(course.id);
      await _store.replaceTopicsForCourse(course.id, detail);
      for (final section in detail.sections) {
        for (final topic in section.topics) {
          final cards = await _api.fetchTopicCards(topic.id);
          await _store.replaceCardsForTopic(
            topic.id,
            cards
                .map(
                  (card) => (
                    id: card.id,
                    versionId: card.versionId,
                    front: card.front,
                    back: card.back,
                    difficulty: card.difficulty,
                  ),
                )
                .toList(),
          );
        }
      }
    }

    await _store.purgeLockedCourseContent();
    await _store.setSyncMeta('last_sync_at', DateTime.now().toUtc().toIso8601String());
    await _store.setSyncMeta('content_revision', listing.courses.fold<int>(
      0,
      (max, course) => course.contentRevision > max ? course.contentRevision : max,
    ).toString());
  }
}
