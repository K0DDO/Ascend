import 'package:drift/drift.dart';

part 'ascend_database.g.dart';

class LocalCourses extends Table {
  TextColumn get id => text()();
  TextColumn get slug => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get contentRevision => integer().withDefault(const Constant(1))();
  BoolColumn get locked => boolean().withDefault(const Constant(true))();
  TextColumn get accessFeatureKey => text().nullable()();
  IntColumn get topicCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get syncedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalTopics extends Table {
  TextColumn get id => text()();
  TextColumn get courseId => text()();
  TextColumn get slug => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get position => integer()();
  IntColumn get estimatedMinutes => integer().withDefault(const Constant(0))();
  TextColumn get prerequisiteIdsJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalCards extends Table {
  TextColumn get id => text()();
  TextColumn get topicId => text()();
  TextColumn get versionId => text()();
  TextColumn get frontJson => text()();
  TextColumn get backJson => text()();
  RealColumn get difficulty => real().withDefault(const Constant(0.5))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

class LocalEntitlements extends Table {
  TextColumn get featureKey => text()();
  TextColumn get constraintsJson => text().withDefault(const Constant('{}'))();
  DateTimeColumn get endsAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {featureKey};
}

class SyncMeta extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

class OutboxEvents extends Table {
  TextColumn get id => text()();
  TextColumn get eventType => text()();
  TextColumn get payloadJson => text()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    LocalCourses,
    LocalTopics,
    LocalCards,
    LocalEntitlements,
    SyncMeta,
    OutboxEvents,
  ],
)
class AscendDatabase extends _$AscendDatabase {
  AscendDatabase(super.executor);

  @override
  int get schemaVersion => 1;

  Future<void> wipeContent() async {
    await batch((batch) {
      batch.deleteAll(localCards);
      batch.deleteAll(localTopics);
      batch.deleteAll(localCourses);
      batch.deleteAll(localEntitlements);
      batch.deleteAll(syncMeta);
    });
  }

  Future<void> wipeAllIncludingOutbox() async {
    await batch((batch) {
      batch.deleteAll(localCards);
      batch.deleteAll(localTopics);
      batch.deleteAll(localCourses);
      batch.deleteAll(localEntitlements);
      batch.deleteAll(syncMeta);
      batch.deleteAll(outboxEvents);
    });
  }
}
