import 'package:ascend/data/local/ascend_database.dart';
import 'package:ascend/data/local/local_content_store.dart';
import 'package:ascend/data/local/open_database.dart';
import 'package:ascend/data/models/course_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late AscendDatabase db;
  late LocalContentStore store;

  setUp(() async {
    db = await openAscendMemoryDatabase();
    store = LocalContentStore(db);
  });

  tearDown(() async {
    await db.close();
  });

  test('upsertCourses and readCourses round-trip', () async {
    const course = CourseSummary(
      id: 'course-1',
      slug: 'demo',
      title: 'Demo Course',
      description: 'Learn basics',
      contentRevision: 2,
      locked: false,
      accessFeatureKey: 'demo_access',
      topicCount: 1,
    );

    await store.upsertCourses([course]);
    final courses = await store.readCourses();

    expect(courses, hasLength(1));
    expect(courses.first.id, course.id);
    expect(courses.first.title, course.title);
    expect(courses.first.locked, isFalse);
  });

  test('wipeAll clears stored content', () async {
    await store.upsertCourses([
      const CourseSummary(
        id: 'course-1',
        slug: 'demo',
        title: 'Demo',
        description: null,
        contentRevision: 1,
        locked: false,
        topicCount: 0,
      ),
    ]);
    await store.setSyncMeta('last_sync_at', DateTime.utc(2026, 1, 1).toIso8601String());

    await store.wipeAll();

    expect(await store.readCourses(), isEmpty);
    expect(await store.readSyncMeta('last_sync_at'), isNull);
  });

  test('purgeLockedCourseContent removes topics for locked courses', () async {
    await store.upsertCourses([
      const CourseSummary(
        id: 'locked-1',
        slug: 'pro',
        title: 'Pro',
        description: null,
        contentRevision: 1,
        locked: true,
        topicCount: 1,
      ),
    ]);
    await store.replaceTopicsForCourse(
      'locked-1',
      const CourseDetail(
        id: 'locked-1',
        slug: 'pro',
        title: 'Pro',
        description: null,
        locked: true,
        sections: [
          CourseSection(
            id: 's1',
            title: 'Section',
            topics: [
              TopicSummary(
                id: 'topic-1',
                slug: 'intro',
                title: 'Intro',
                description: null,
                position: 0,
                estimatedMinutes: 5,
                prerequisiteIds: [],
              ),
            ],
          ),
        ],
      ),
    );

    await store.purgeLockedCourseContent();

    final detail = await store.readCourseDetail('locked-1');
    expect(detail, isNotNull);
    expect(detail!.sections, isEmpty);
  });
}
