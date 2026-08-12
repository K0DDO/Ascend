import 'dart:convert';

import 'package:drift/drift.dart';

import '../models/course_models.dart';
import 'ascend_database.dart';

class LocalContentStore {
  LocalContentStore(this._db);

  final AscendDatabase _db;

  Future<void> wipeAll() => _db.wipeAllIncludingOutbox();

  Future<void> saveEntitlements(List<({String key, Map<String, dynamic> constraints, DateTime? endsAt})> items) async {
    await _db.batch((batch) {
      batch.deleteAll(_db.localEntitlements);
      batch.insertAll(
        _db.localEntitlements,
        items
            .map(
              (item) => LocalEntitlementsCompanion.insert(
                featureKey: item.key,
                constraintsJson: Value(jsonEncode(item.constraints)),
                endsAt: Value(item.endsAt),
              ),
            )
            .toList(),
      );
    });
  }

  Future<Set<String>> readEntitlementKeys() async {
    final rows = await _db.select(_db.localEntitlements).get();
    return rows.map((row) => row.featureKey).toSet();
  }

  Future<void> upsertCourses(List<CourseSummary> courses) async {
    await _db.batch((batch) {
      for (final course in courses) {
        batch.insert(
          _db.localCourses,
          LocalCoursesCompanion.insert(
            id: course.id,
            slug: course.slug,
            title: course.title,
            description: Value(course.description),
            contentRevision: Value(course.contentRevision),
            locked: Value(course.locked),
            accessFeatureKey: Value(course.accessFeatureKey),
            topicCount: Value(course.topicCount),
            syncedAt: Value(DateTime.now().toUtc()),
          ),
          mode: InsertMode.insertOrReplace,
        );
      }
    });
  }

  Future<void> replaceTopicsForCourse(String courseId, CourseDetail detail) async {
    await _db.transaction(() async {
      await (_db.delete(_db.localTopics)..where((t) => t.courseId.equals(courseId))).go();
      for (final section in detail.sections) {
        for (final topic in section.topics) {
          await _db.into(_db.localTopics).insert(
                LocalTopicsCompanion.insert(
                  id: topic.id,
                  courseId: courseId,
                  slug: topic.slug,
                  title: topic.title,
                  description: Value(topic.description),
                  position: topic.position,
                  estimatedMinutes: Value(topic.estimatedMinutes),
                  prerequisiteIdsJson: Value(jsonEncode(topic.prerequisiteIds)),
                ),
              );
        }
      }
    });
  }

  Future<void> replaceCardsForTopic(
    String topicId,
    List<({String id, String versionId, Map<String, dynamic> front, Map<String, dynamic> back, double difficulty})> cards,
  ) async {
    await _db.transaction(() async {
      await (_db.delete(_db.localCards)..where((c) => c.topicId.equals(topicId))).go();
      for (final card in cards) {
        await _db.into(_db.localCards).insert(
              LocalCardsCompanion.insert(
                id: card.id,
                topicId: topicId,
                versionId: card.versionId,
                frontJson: jsonEncode(card.front),
                backJson: jsonEncode(card.back),
                difficulty: Value(card.difficulty),
              ),
            );
      }
    });
  }

  Future<void> purgeCoursesNotIn(Set<String> allowedCourseIds) async {
    final allCourses = await _db.select(_db.localCourses).get();
    for (final course in allCourses) {
      if (allowedCourseIds.contains(course.id)) continue;
      final topics =
          await (_db.select(_db.localTopics)..where((t) => t.courseId.equals(course.id))).get();
      for (final topic in topics) {
        await (_db.delete(_db.localCards)..where((c) => c.topicId.equals(topic.id))).go();
      }
      await (_db.delete(_db.localTopics)..where((t) => t.courseId.equals(course.id))).go();
      await (_db.delete(_db.localCourses)..where((c) => c.id.equals(course.id))).go();
    }
  }

  Future<void> purgeLockedCourseContent() async {
    final lockedCourses =
        await (_db.select(_db.localCourses)..where((c) => c.locked.equals(true))).get();
    for (final course in lockedCourses) {
      final topics =
          await (_db.select(_db.localTopics)..where((t) => t.courseId.equals(course.id))).get();
      for (final topic in topics) {
        await (_db.delete(_db.localCards)..where((c) => c.topicId.equals(topic.id))).go();
      }
      await (_db.delete(_db.localTopics)..where((t) => t.courseId.equals(course.id))).go();
    }
  }

  Future<List<CourseSummary>> readCourses() async {
    final rows = await (_db.select(_db.localCourses)..orderBy([(c) => OrderingTerm.asc(c.title)])).get();
    return rows
        .map(
          (row) => CourseSummary(
            id: row.id,
            slug: row.slug,
            title: row.title,
            description: row.description,
            contentRevision: row.contentRevision,
            locked: row.locked,
            accessFeatureKey: row.accessFeatureKey,
            topicCount: row.topicCount,
          ),
        )
        .toList();
  }

  Future<CourseDetail?> readCourseDetail(String courseId) async {
    final course = await (_db.select(_db.localCourses)..where((c) => c.id.equals(courseId))).getSingleOrNull();
    if (course == null) return null;
    final topics = await (_db.select(_db.localTopics)
          ..where((t) => t.courseId.equals(courseId))
          ..orderBy([(t) => OrderingTerm.asc(t.position)]))
        .get();
    if (topics.isEmpty && course.locked) {
      return CourseDetail(
        id: course.id,
        slug: course.slug,
        title: course.title,
        description: course.description,
        locked: course.locked,
        sections: const [],
      );
    }
    return CourseDetail(
      id: course.id,
      slug: course.slug,
      title: course.title,
      description: course.description,
      locked: course.locked,
      sections: [
        CourseSection(
          id: 'local-section',
          title: 'Темы',
          topics: topics
              .map(
                (topic) => TopicSummary(
                  id: topic.id,
                  slug: topic.slug,
                  title: topic.title,
                  description: topic.description,
                  position: topic.position,
                  estimatedMinutes: topic.estimatedMinutes,
                  prerequisiteIds: (jsonDecode(topic.prerequisiteIdsJson) as List<dynamic>).cast<String>(),
                  locked: false,
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Future<void> setSyncMeta(String key, String value) async {
    await _db.into(_db.syncMeta).insertOnConflictUpdate(
          SyncMetaCompanion.insert(key: key, value: value),
        );
  }

  Future<String?> readSyncMeta(String key) async {
    final row = await (_db.select(_db.syncMeta)..where((m) => m.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<List<CardPreview>> readCardsForTopic(String topicId) async {
    final rows = await (_db.select(_db.localCards)..where((c) => c.topicId.equals(topicId))).get();
    return rows
        .map(
          (row) => CardPreview(
            id: row.id,
            versionId: row.versionId,
            front: jsonDecode(row.frontJson) as Map<String, dynamic>,
            back: jsonDecode(row.backJson) as Map<String, dynamic>,
            difficulty: row.difficulty,
          ),
        )
        .toList();
  }

  Future<int> pendingOutboxCount() async {
    final count = await (_db.selectOnly(_db.outboxEvents)
          ..addColumns([_db.outboxEvents.id.count()])
          ..where(_db.outboxEvents.status.equals('pending')))
        .getSingle();
    return count.read(_db.outboxEvents.id.count()) ?? 0;
  }

  Future<void> enqueueOutbox({
    required String eventType,
    required Map<String, dynamic> payload,
  }) async {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    await _db.into(_db.outboxEvents).insert(
          OutboxEventsCompanion.insert(
            id: id,
            eventType: eventType,
            payloadJson: jsonEncode(payload),
            status: const Value('pending'),
          ),
        );
  }

  Future<List<({String id, String eventType, Map<String, dynamic> payload})>> readPendingOutbox({
    int limit = 25,
  }) async {
    final rows = await (_db.select(_db.outboxEvents)
          ..where((e) => e.status.equals('pending'))
          ..orderBy([(e) => OrderingTerm.asc(e.createdAt)])
          ..limit(limit))
        .get();
    return rows
        .map(
          (row) => (
            id: row.id,
            eventType: row.eventType,
            payload: jsonDecode(row.payloadJson) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> markOutboxSent(String id) async {
    await (_db.update(_db.outboxEvents)..where((e) => e.id.equals(id))).write(
      const OutboxEventsCompanion(status: Value('sent')),
    );
  }

  Future<void> markOutboxFailed(String id) async {
    await (_db.update(_db.outboxEvents)..where((e) => e.id.equals(id))).write(
      const OutboxEventsCompanion(status: Value('failed')),
    );
  }
}
