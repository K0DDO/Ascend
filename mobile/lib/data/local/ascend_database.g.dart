// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ascend_database.dart';

// ignore_for_file: type=lint
class $LocalCoursesTable extends LocalCourses
    with TableInfo<$LocalCoursesTable, LocalCourse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentRevisionMeta = const VerificationMeta(
    'contentRevision',
  );
  @override
  late final GeneratedColumn<int> contentRevision = GeneratedColumn<int>(
    'content_revision',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _lockedMeta = const VerificationMeta('locked');
  @override
  late final GeneratedColumn<bool> locked = GeneratedColumn<bool>(
    'locked',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("locked" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _accessFeatureKeyMeta = const VerificationMeta(
    'accessFeatureKey',
  );
  @override
  late final GeneratedColumn<String> accessFeatureKey = GeneratedColumn<String>(
    'access_feature_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _topicCountMeta = const VerificationMeta(
    'topicCount',
  );
  @override
  late final GeneratedColumn<int> topicCount = GeneratedColumn<int>(
    'topic_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _syncedAtMeta = const VerificationMeta(
    'syncedAt',
  );
  @override
  late final GeneratedColumn<DateTime> syncedAt = GeneratedColumn<DateTime>(
    'synced_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    slug,
    title,
    description,
    contentRevision,
    locked,
    accessFeatureKey,
    topicCount,
    syncedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_courses';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCourse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('content_revision')) {
      context.handle(
        _contentRevisionMeta,
        contentRevision.isAcceptableOrUnknown(
          data['content_revision']!,
          _contentRevisionMeta,
        ),
      );
    }
    if (data.containsKey('locked')) {
      context.handle(
        _lockedMeta,
        locked.isAcceptableOrUnknown(data['locked']!, _lockedMeta),
      );
    }
    if (data.containsKey('access_feature_key')) {
      context.handle(
        _accessFeatureKeyMeta,
        accessFeatureKey.isAcceptableOrUnknown(
          data['access_feature_key']!,
          _accessFeatureKeyMeta,
        ),
      );
    }
    if (data.containsKey('topic_count')) {
      context.handle(
        _topicCountMeta,
        topicCount.isAcceptableOrUnknown(data['topic_count']!, _topicCountMeta),
      );
    }
    if (data.containsKey('synced_at')) {
      context.handle(
        _syncedAtMeta,
        syncedAt.isAcceptableOrUnknown(data['synced_at']!, _syncedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCourse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCourse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      contentRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}content_revision'],
      )!,
      locked: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}locked'],
      )!,
      accessFeatureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}access_feature_key'],
      ),
      topicCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}topic_count'],
      )!,
      syncedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}synced_at'],
      )!,
    );
  }

  @override
  $LocalCoursesTable createAlias(String alias) {
    return $LocalCoursesTable(attachedDatabase, alias);
  }
}

class LocalCourse extends DataClass implements Insertable<LocalCourse> {
  final String id;
  final String slug;
  final String title;
  final String? description;
  final int contentRevision;
  final bool locked;
  final String? accessFeatureKey;
  final int topicCount;
  final DateTime syncedAt;
  const LocalCourse({
    required this.id,
    required this.slug,
    required this.title,
    this.description,
    required this.contentRevision,
    required this.locked,
    this.accessFeatureKey,
    required this.topicCount,
    required this.syncedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['content_revision'] = Variable<int>(contentRevision);
    map['locked'] = Variable<bool>(locked);
    if (!nullToAbsent || accessFeatureKey != null) {
      map['access_feature_key'] = Variable<String>(accessFeatureKey);
    }
    map['topic_count'] = Variable<int>(topicCount);
    map['synced_at'] = Variable<DateTime>(syncedAt);
    return map;
  }

  LocalCoursesCompanion toCompanion(bool nullToAbsent) {
    return LocalCoursesCompanion(
      id: Value(id),
      slug: Value(slug),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      contentRevision: Value(contentRevision),
      locked: Value(locked),
      accessFeatureKey: accessFeatureKey == null && nullToAbsent
          ? const Value.absent()
          : Value(accessFeatureKey),
      topicCount: Value(topicCount),
      syncedAt: Value(syncedAt),
    );
  }

  factory LocalCourse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCourse(
      id: serializer.fromJson<String>(json['id']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      contentRevision: serializer.fromJson<int>(json['contentRevision']),
      locked: serializer.fromJson<bool>(json['locked']),
      accessFeatureKey: serializer.fromJson<String?>(json['accessFeatureKey']),
      topicCount: serializer.fromJson<int>(json['topicCount']),
      syncedAt: serializer.fromJson<DateTime>(json['syncedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'contentRevision': serializer.toJson<int>(contentRevision),
      'locked': serializer.toJson<bool>(locked),
      'accessFeatureKey': serializer.toJson<String?>(accessFeatureKey),
      'topicCount': serializer.toJson<int>(topicCount),
      'syncedAt': serializer.toJson<DateTime>(syncedAt),
    };
  }

  LocalCourse copyWith({
    String? id,
    String? slug,
    String? title,
    Value<String?> description = const Value.absent(),
    int? contentRevision,
    bool? locked,
    Value<String?> accessFeatureKey = const Value.absent(),
    int? topicCount,
    DateTime? syncedAt,
  }) => LocalCourse(
    id: id ?? this.id,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    contentRevision: contentRevision ?? this.contentRevision,
    locked: locked ?? this.locked,
    accessFeatureKey: accessFeatureKey.present
        ? accessFeatureKey.value
        : this.accessFeatureKey,
    topicCount: topicCount ?? this.topicCount,
    syncedAt: syncedAt ?? this.syncedAt,
  );
  LocalCourse copyWithCompanion(LocalCoursesCompanion data) {
    return LocalCourse(
      id: data.id.present ? data.id.value : this.id,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      contentRevision: data.contentRevision.present
          ? data.contentRevision.value
          : this.contentRevision,
      locked: data.locked.present ? data.locked.value : this.locked,
      accessFeatureKey: data.accessFeatureKey.present
          ? data.accessFeatureKey.value
          : this.accessFeatureKey,
      topicCount: data.topicCount.present
          ? data.topicCount.value
          : this.topicCount,
      syncedAt: data.syncedAt.present ? data.syncedAt.value : this.syncedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCourse(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('locked: $locked, ')
          ..write('accessFeatureKey: $accessFeatureKey, ')
          ..write('topicCount: $topicCount, ')
          ..write('syncedAt: $syncedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    slug,
    title,
    description,
    contentRevision,
    locked,
    accessFeatureKey,
    topicCount,
    syncedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCourse &&
          other.id == this.id &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.description == this.description &&
          other.contentRevision == this.contentRevision &&
          other.locked == this.locked &&
          other.accessFeatureKey == this.accessFeatureKey &&
          other.topicCount == this.topicCount &&
          other.syncedAt == this.syncedAt);
}

class LocalCoursesCompanion extends UpdateCompanion<LocalCourse> {
  final Value<String> id;
  final Value<String> slug;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> contentRevision;
  final Value<bool> locked;
  final Value<String?> accessFeatureKey;
  final Value<int> topicCount;
  final Value<DateTime> syncedAt;
  final Value<int> rowid;
  const LocalCoursesCompanion({
    this.id = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.contentRevision = const Value.absent(),
    this.locked = const Value.absent(),
    this.accessFeatureKey = const Value.absent(),
    this.topicCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCoursesCompanion.insert({
    required String id,
    required String slug,
    required String title,
    this.description = const Value.absent(),
    this.contentRevision = const Value.absent(),
    this.locked = const Value.absent(),
    this.accessFeatureKey = const Value.absent(),
    this.topicCount = const Value.absent(),
    this.syncedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       slug = Value(slug),
       title = Value(title);
  static Insertable<LocalCourse> custom({
    Expression<String>? id,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? contentRevision,
    Expression<bool>? locked,
    Expression<String>? accessFeatureKey,
    Expression<int>? topicCount,
    Expression<DateTime>? syncedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (contentRevision != null) 'content_revision': contentRevision,
      if (locked != null) 'locked': locked,
      if (accessFeatureKey != null) 'access_feature_key': accessFeatureKey,
      if (topicCount != null) 'topic_count': topicCount,
      if (syncedAt != null) 'synced_at': syncedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCoursesCompanion copyWith({
    Value<String>? id,
    Value<String>? slug,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? contentRevision,
    Value<bool>? locked,
    Value<String?>? accessFeatureKey,
    Value<int>? topicCount,
    Value<DateTime>? syncedAt,
    Value<int>? rowid,
  }) {
    return LocalCoursesCompanion(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      contentRevision: contentRevision ?? this.contentRevision,
      locked: locked ?? this.locked,
      accessFeatureKey: accessFeatureKey ?? this.accessFeatureKey,
      topicCount: topicCount ?? this.topicCount,
      syncedAt: syncedAt ?? this.syncedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (contentRevision.present) {
      map['content_revision'] = Variable<int>(contentRevision.value);
    }
    if (locked.present) {
      map['locked'] = Variable<bool>(locked.value);
    }
    if (accessFeatureKey.present) {
      map['access_feature_key'] = Variable<String>(accessFeatureKey.value);
    }
    if (topicCount.present) {
      map['topic_count'] = Variable<int>(topicCount.value);
    }
    if (syncedAt.present) {
      map['synced_at'] = Variable<DateTime>(syncedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCoursesCompanion(')
          ..write('id: $id, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('contentRevision: $contentRevision, ')
          ..write('locked: $locked, ')
          ..write('accessFeatureKey: $accessFeatureKey, ')
          ..write('topicCount: $topicCount, ')
          ..write('syncedAt: $syncedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalTopicsTable extends LocalTopics
    with TableInfo<$LocalTopicsTable, LocalTopic> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalTopicsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _courseIdMeta = const VerificationMeta(
    'courseId',
  );
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
    'course_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _prerequisiteIdsJsonMeta =
      const VerificationMeta('prerequisiteIdsJson');
  @override
  late final GeneratedColumn<String> prerequisiteIdsJson =
      GeneratedColumn<String>(
        'prerequisite_ids_json',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant('[]'),
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    courseId,
    slug,
    title,
    description,
    position,
    estimatedMinutes,
    prerequisiteIdsJson,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_topics';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalTopic> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('course_id')) {
      context.handle(
        _courseIdMeta,
        courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('prerequisite_ids_json')) {
      context.handle(
        _prerequisiteIdsJsonMeta,
        prerequisiteIdsJson.isAcceptableOrUnknown(
          data['prerequisite_ids_json']!,
          _prerequisiteIdsJsonMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalTopic map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalTopic(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      courseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}course_id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      )!,
      prerequisiteIdsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prerequisite_ids_json'],
      )!,
    );
  }

  @override
  $LocalTopicsTable createAlias(String alias) {
    return $LocalTopicsTable(attachedDatabase, alias);
  }
}

class LocalTopic extends DataClass implements Insertable<LocalTopic> {
  final String id;
  final String courseId;
  final String slug;
  final String title;
  final String? description;
  final int position;
  final int estimatedMinutes;
  final String prerequisiteIdsJson;
  const LocalTopic({
    required this.id,
    required this.courseId,
    required this.slug,
    required this.title,
    this.description,
    required this.position,
    required this.estimatedMinutes,
    required this.prerequisiteIdsJson,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['course_id'] = Variable<String>(courseId);
    map['slug'] = Variable<String>(slug);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['position'] = Variable<int>(position);
    map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    map['prerequisite_ids_json'] = Variable<String>(prerequisiteIdsJson);
    return map;
  }

  LocalTopicsCompanion toCompanion(bool nullToAbsent) {
    return LocalTopicsCompanion(
      id: Value(id),
      courseId: Value(courseId),
      slug: Value(slug),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      position: Value(position),
      estimatedMinutes: Value(estimatedMinutes),
      prerequisiteIdsJson: Value(prerequisiteIdsJson),
    );
  }

  factory LocalTopic.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalTopic(
      id: serializer.fromJson<String>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      slug: serializer.fromJson<String>(json['slug']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      position: serializer.fromJson<int>(json['position']),
      estimatedMinutes: serializer.fromJson<int>(json['estimatedMinutes']),
      prerequisiteIdsJson: serializer.fromJson<String>(
        json['prerequisiteIdsJson'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'courseId': serializer.toJson<String>(courseId),
      'slug': serializer.toJson<String>(slug),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'position': serializer.toJson<int>(position),
      'estimatedMinutes': serializer.toJson<int>(estimatedMinutes),
      'prerequisiteIdsJson': serializer.toJson<String>(prerequisiteIdsJson),
    };
  }

  LocalTopic copyWith({
    String? id,
    String? courseId,
    String? slug,
    String? title,
    Value<String?> description = const Value.absent(),
    int? position,
    int? estimatedMinutes,
    String? prerequisiteIdsJson,
  }) => LocalTopic(
    id: id ?? this.id,
    courseId: courseId ?? this.courseId,
    slug: slug ?? this.slug,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    position: position ?? this.position,
    estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    prerequisiteIdsJson: prerequisiteIdsJson ?? this.prerequisiteIdsJson,
  );
  LocalTopic copyWithCompanion(LocalTopicsCompanion data) {
    return LocalTopic(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      slug: data.slug.present ? data.slug.value : this.slug,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      position: data.position.present ? data.position.value : this.position,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      prerequisiteIdsJson: data.prerequisiteIdsJson.present
          ? data.prerequisiteIdsJson.value
          : this.prerequisiteIdsJson,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopic(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('position: $position, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('prerequisiteIdsJson: $prerequisiteIdsJson')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    courseId,
    slug,
    title,
    description,
    position,
    estimatedMinutes,
    prerequisiteIdsJson,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalTopic &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.slug == this.slug &&
          other.title == this.title &&
          other.description == this.description &&
          other.position == this.position &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.prerequisiteIdsJson == this.prerequisiteIdsJson);
}

class LocalTopicsCompanion extends UpdateCompanion<LocalTopic> {
  final Value<String> id;
  final Value<String> courseId;
  final Value<String> slug;
  final Value<String> title;
  final Value<String?> description;
  final Value<int> position;
  final Value<int> estimatedMinutes;
  final Value<String> prerequisiteIdsJson;
  final Value<int> rowid;
  const LocalTopicsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.slug = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.position = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.prerequisiteIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalTopicsCompanion.insert({
    required String id,
    required String courseId,
    required String slug,
    required String title,
    this.description = const Value.absent(),
    required int position,
    this.estimatedMinutes = const Value.absent(),
    this.prerequisiteIdsJson = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       courseId = Value(courseId),
       slug = Value(slug),
       title = Value(title),
       position = Value(position);
  static Insertable<LocalTopic> custom({
    Expression<String>? id,
    Expression<String>? courseId,
    Expression<String>? slug,
    Expression<String>? title,
    Expression<String>? description,
    Expression<int>? position,
    Expression<int>? estimatedMinutes,
    Expression<String>? prerequisiteIdsJson,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (slug != null) 'slug': slug,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (position != null) 'position': position,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (prerequisiteIdsJson != null)
        'prerequisite_ids_json': prerequisiteIdsJson,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalTopicsCompanion copyWith({
    Value<String>? id,
    Value<String>? courseId,
    Value<String>? slug,
    Value<String>? title,
    Value<String?>? description,
    Value<int>? position,
    Value<int>? estimatedMinutes,
    Value<String>? prerequisiteIdsJson,
    Value<int>? rowid,
  }) {
    return LocalTopicsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      slug: slug ?? this.slug,
      title: title ?? this.title,
      description: description ?? this.description,
      position: position ?? this.position,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      prerequisiteIdsJson: prerequisiteIdsJson ?? this.prerequisiteIdsJson,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (prerequisiteIdsJson.present) {
      map['prerequisite_ids_json'] = Variable<String>(
        prerequisiteIdsJson.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalTopicsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('slug: $slug, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('position: $position, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('prerequisiteIdsJson: $prerequisiteIdsJson, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalCardsTable extends LocalCards
    with TableInfo<$LocalCardsTable, LocalCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _topicIdMeta = const VerificationMeta(
    'topicId',
  );
  @override
  late final GeneratedColumn<String> topicId = GeneratedColumn<String>(
    'topic_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _versionIdMeta = const VerificationMeta(
    'versionId',
  );
  @override
  late final GeneratedColumn<String> versionId = GeneratedColumn<String>(
    'version_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frontJsonMeta = const VerificationMeta(
    'frontJson',
  );
  @override
  late final GeneratedColumn<String> frontJson = GeneratedColumn<String>(
    'front_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _backJsonMeta = const VerificationMeta(
    'backJson',
  );
  @override
  late final GeneratedColumn<String> backJson = GeneratedColumn<String>(
    'back_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<double> difficulty = GeneratedColumn<double>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.5),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    topicId,
    versionId,
    frontJson,
    backJson,
    difficulty,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('topic_id')) {
      context.handle(
        _topicIdMeta,
        topicId.isAcceptableOrUnknown(data['topic_id']!, _topicIdMeta),
      );
    } else if (isInserting) {
      context.missing(_topicIdMeta);
    }
    if (data.containsKey('version_id')) {
      context.handle(
        _versionIdMeta,
        versionId.isAcceptableOrUnknown(data['version_id']!, _versionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_versionIdMeta);
    }
    if (data.containsKey('front_json')) {
      context.handle(
        _frontJsonMeta,
        frontJson.isAcceptableOrUnknown(data['front_json']!, _frontJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_frontJsonMeta);
    }
    if (data.containsKey('back_json')) {
      context.handle(
        _backJsonMeta,
        backJson.isAcceptableOrUnknown(data['back_json']!, _backJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_backJsonMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      topicId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic_id'],
      )!,
      versionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}version_id'],
      )!,
      frontJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}front_json'],
      )!,
      backJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}back_json'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}difficulty'],
      )!,
    );
  }

  @override
  $LocalCardsTable createAlias(String alias) {
    return $LocalCardsTable(attachedDatabase, alias);
  }
}

class LocalCard extends DataClass implements Insertable<LocalCard> {
  final String id;
  final String topicId;
  final String versionId;
  final String frontJson;
  final String backJson;
  final double difficulty;
  const LocalCard({
    required this.id,
    required this.topicId,
    required this.versionId,
    required this.frontJson,
    required this.backJson,
    required this.difficulty,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['topic_id'] = Variable<String>(topicId);
    map['version_id'] = Variable<String>(versionId);
    map['front_json'] = Variable<String>(frontJson);
    map['back_json'] = Variable<String>(backJson);
    map['difficulty'] = Variable<double>(difficulty);
    return map;
  }

  LocalCardsCompanion toCompanion(bool nullToAbsent) {
    return LocalCardsCompanion(
      id: Value(id),
      topicId: Value(topicId),
      versionId: Value(versionId),
      frontJson: Value(frontJson),
      backJson: Value(backJson),
      difficulty: Value(difficulty),
    );
  }

  factory LocalCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalCard(
      id: serializer.fromJson<String>(json['id']),
      topicId: serializer.fromJson<String>(json['topicId']),
      versionId: serializer.fromJson<String>(json['versionId']),
      frontJson: serializer.fromJson<String>(json['frontJson']),
      backJson: serializer.fromJson<String>(json['backJson']),
      difficulty: serializer.fromJson<double>(json['difficulty']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'topicId': serializer.toJson<String>(topicId),
      'versionId': serializer.toJson<String>(versionId),
      'frontJson': serializer.toJson<String>(frontJson),
      'backJson': serializer.toJson<String>(backJson),
      'difficulty': serializer.toJson<double>(difficulty),
    };
  }

  LocalCard copyWith({
    String? id,
    String? topicId,
    String? versionId,
    String? frontJson,
    String? backJson,
    double? difficulty,
  }) => LocalCard(
    id: id ?? this.id,
    topicId: topicId ?? this.topicId,
    versionId: versionId ?? this.versionId,
    frontJson: frontJson ?? this.frontJson,
    backJson: backJson ?? this.backJson,
    difficulty: difficulty ?? this.difficulty,
  );
  LocalCard copyWithCompanion(LocalCardsCompanion data) {
    return LocalCard(
      id: data.id.present ? data.id.value : this.id,
      topicId: data.topicId.present ? data.topicId.value : this.topicId,
      versionId: data.versionId.present ? data.versionId.value : this.versionId,
      frontJson: data.frontJson.present ? data.frontJson.value : this.frontJson,
      backJson: data.backJson.present ? data.backJson.value : this.backJson,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalCard(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('versionId: $versionId, ')
          ..write('frontJson: $frontJson, ')
          ..write('backJson: $backJson, ')
          ..write('difficulty: $difficulty')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, topicId, versionId, frontJson, backJson, difficulty);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalCard &&
          other.id == this.id &&
          other.topicId == this.topicId &&
          other.versionId == this.versionId &&
          other.frontJson == this.frontJson &&
          other.backJson == this.backJson &&
          other.difficulty == this.difficulty);
}

class LocalCardsCompanion extends UpdateCompanion<LocalCard> {
  final Value<String> id;
  final Value<String> topicId;
  final Value<String> versionId;
  final Value<String> frontJson;
  final Value<String> backJson;
  final Value<double> difficulty;
  final Value<int> rowid;
  const LocalCardsCompanion({
    this.id = const Value.absent(),
    this.topicId = const Value.absent(),
    this.versionId = const Value.absent(),
    this.frontJson = const Value.absent(),
    this.backJson = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalCardsCompanion.insert({
    required String id,
    required String topicId,
    required String versionId,
    required String frontJson,
    required String backJson,
    this.difficulty = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       topicId = Value(topicId),
       versionId = Value(versionId),
       frontJson = Value(frontJson),
       backJson = Value(backJson);
  static Insertable<LocalCard> custom({
    Expression<String>? id,
    Expression<String>? topicId,
    Expression<String>? versionId,
    Expression<String>? frontJson,
    Expression<String>? backJson,
    Expression<double>? difficulty,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topicId != null) 'topic_id': topicId,
      if (versionId != null) 'version_id': versionId,
      if (frontJson != null) 'front_json': frontJson,
      if (backJson != null) 'back_json': backJson,
      if (difficulty != null) 'difficulty': difficulty,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? topicId,
    Value<String>? versionId,
    Value<String>? frontJson,
    Value<String>? backJson,
    Value<double>? difficulty,
    Value<int>? rowid,
  }) {
    return LocalCardsCompanion(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      versionId: versionId ?? this.versionId,
      frontJson: frontJson ?? this.frontJson,
      backJson: backJson ?? this.backJson,
      difficulty: difficulty ?? this.difficulty,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (topicId.present) {
      map['topic_id'] = Variable<String>(topicId.value);
    }
    if (versionId.present) {
      map['version_id'] = Variable<String>(versionId.value);
    }
    if (frontJson.present) {
      map['front_json'] = Variable<String>(frontJson.value);
    }
    if (backJson.present) {
      map['back_json'] = Variable<String>(backJson.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<double>(difficulty.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalCardsCompanion(')
          ..write('id: $id, ')
          ..write('topicId: $topicId, ')
          ..write('versionId: $versionId, ')
          ..write('frontJson: $frontJson, ')
          ..write('backJson: $backJson, ')
          ..write('difficulty: $difficulty, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalEntitlementsTable extends LocalEntitlements
    with TableInfo<$LocalEntitlementsTable, LocalEntitlement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalEntitlementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _featureKeyMeta = const VerificationMeta(
    'featureKey',
  );
  @override
  late final GeneratedColumn<String> featureKey = GeneratedColumn<String>(
    'feature_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _constraintsJsonMeta = const VerificationMeta(
    'constraintsJson',
  );
  @override
  late final GeneratedColumn<String> constraintsJson = GeneratedColumn<String>(
    'constraints_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [featureKey, constraintsJson, endsAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_entitlements';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalEntitlement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feature_key')) {
      context.handle(
        _featureKeyMeta,
        featureKey.isAcceptableOrUnknown(data['feature_key']!, _featureKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_featureKeyMeta);
    }
    if (data.containsKey('constraints_json')) {
      context.handle(
        _constraintsJsonMeta,
        constraintsJson.isAcceptableOrUnknown(
          data['constraints_json']!,
          _constraintsJsonMeta,
        ),
      );
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {featureKey};
  @override
  LocalEntitlement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalEntitlement(
      featureKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feature_key'],
      )!,
      constraintsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}constraints_json'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
    );
  }

  @override
  $LocalEntitlementsTable createAlias(String alias) {
    return $LocalEntitlementsTable(attachedDatabase, alias);
  }
}

class LocalEntitlement extends DataClass
    implements Insertable<LocalEntitlement> {
  final String featureKey;
  final String constraintsJson;
  final DateTime? endsAt;
  const LocalEntitlement({
    required this.featureKey,
    required this.constraintsJson,
    this.endsAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feature_key'] = Variable<String>(featureKey);
    map['constraints_json'] = Variable<String>(constraintsJson);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    return map;
  }

  LocalEntitlementsCompanion toCompanion(bool nullToAbsent) {
    return LocalEntitlementsCompanion(
      featureKey: Value(featureKey),
      constraintsJson: Value(constraintsJson),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
    );
  }

  factory LocalEntitlement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalEntitlement(
      featureKey: serializer.fromJson<String>(json['featureKey']),
      constraintsJson: serializer.fromJson<String>(json['constraintsJson']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'featureKey': serializer.toJson<String>(featureKey),
      'constraintsJson': serializer.toJson<String>(constraintsJson),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
    };
  }

  LocalEntitlement copyWith({
    String? featureKey,
    String? constraintsJson,
    Value<DateTime?> endsAt = const Value.absent(),
  }) => LocalEntitlement(
    featureKey: featureKey ?? this.featureKey,
    constraintsJson: constraintsJson ?? this.constraintsJson,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
  );
  LocalEntitlement copyWithCompanion(LocalEntitlementsCompanion data) {
    return LocalEntitlement(
      featureKey: data.featureKey.present
          ? data.featureKey.value
          : this.featureKey,
      constraintsJson: data.constraintsJson.present
          ? data.constraintsJson.value
          : this.constraintsJson,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalEntitlement(')
          ..write('featureKey: $featureKey, ')
          ..write('constraintsJson: $constraintsJson, ')
          ..write('endsAt: $endsAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(featureKey, constraintsJson, endsAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalEntitlement &&
          other.featureKey == this.featureKey &&
          other.constraintsJson == this.constraintsJson &&
          other.endsAt == this.endsAt);
}

class LocalEntitlementsCompanion extends UpdateCompanion<LocalEntitlement> {
  final Value<String> featureKey;
  final Value<String> constraintsJson;
  final Value<DateTime?> endsAt;
  final Value<int> rowid;
  const LocalEntitlementsCompanion({
    this.featureKey = const Value.absent(),
    this.constraintsJson = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalEntitlementsCompanion.insert({
    required String featureKey,
    this.constraintsJson = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : featureKey = Value(featureKey);
  static Insertable<LocalEntitlement> custom({
    Expression<String>? featureKey,
    Expression<String>? constraintsJson,
    Expression<DateTime>? endsAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (featureKey != null) 'feature_key': featureKey,
      if (constraintsJson != null) 'constraints_json': constraintsJson,
      if (endsAt != null) 'ends_at': endsAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalEntitlementsCompanion copyWith({
    Value<String>? featureKey,
    Value<String>? constraintsJson,
    Value<DateTime?>? endsAt,
    Value<int>? rowid,
  }) {
    return LocalEntitlementsCompanion(
      featureKey: featureKey ?? this.featureKey,
      constraintsJson: constraintsJson ?? this.constraintsJson,
      endsAt: endsAt ?? this.endsAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (featureKey.present) {
      map['feature_key'] = Variable<String>(featureKey.value);
    }
    if (constraintsJson.present) {
      map['constraints_json'] = Variable<String>(constraintsJson.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalEntitlementsCompanion(')
          ..write('featureKey: $featureKey, ')
          ..write('constraintsJson: $constraintsJson, ')
          ..write('endsAt: $endsAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final String value;
  const SyncMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(key: Value(key), value: Value(value));
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SyncMetaData copyWith({String? key, String? value}) =>
      SyncMetaData(key: key ?? this.key, value: value ?? this.value);
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxEventsTable extends OutboxEvents
    with TableInfo<$OutboxEventsTable, OutboxEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    eventType,
    payloadJson,
    status,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OutboxEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $OutboxEventsTable createAlias(String alias) {
    return $OutboxEventsTable(attachedDatabase, alias);
  }
}

class OutboxEvent extends DataClass implements Insertable<OutboxEvent> {
  final String id;
  final String eventType;
  final String payloadJson;
  final String status;
  final DateTime createdAt;
  const OutboxEvent({
    required this.id,
    required this.eventType,
    required this.payloadJson,
    required this.status,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['event_type'] = Variable<String>(eventType);
    map['payload_json'] = Variable<String>(payloadJson);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  OutboxEventsCompanion toCompanion(bool nullToAbsent) {
    return OutboxEventsCompanion(
      id: Value(id),
      eventType: Value(eventType),
      payloadJson: Value(payloadJson),
      status: Value(status),
      createdAt: Value(createdAt),
    );
  }

  factory OutboxEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxEvent(
      id: serializer.fromJson<String>(json['id']),
      eventType: serializer.fromJson<String>(json['eventType']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'eventType': serializer.toJson<String>(eventType),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  OutboxEvent copyWith({
    String? id,
    String? eventType,
    String? payloadJson,
    String? status,
    DateTime? createdAt,
  }) => OutboxEvent(
    id: id ?? this.id,
    eventType: eventType ?? this.eventType,
    payloadJson: payloadJson ?? this.payloadJson,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
  );
  OutboxEvent copyWithCompanion(OutboxEventsCompanion data) {
    return OutboxEvent(
      id: data.id.present ? data.id.value : this.id,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEvent(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, eventType, payloadJson, status, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxEvent &&
          other.id == this.id &&
          other.eventType == this.eventType &&
          other.payloadJson == this.payloadJson &&
          other.status == this.status &&
          other.createdAt == this.createdAt);
}

class OutboxEventsCompanion extends UpdateCompanion<OutboxEvent> {
  final Value<String> id;
  final Value<String> eventType;
  final Value<String> payloadJson;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const OutboxEventsCompanion({
    this.id = const Value.absent(),
    this.eventType = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxEventsCompanion.insert({
    required String id,
    required String eventType,
    required String payloadJson,
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       eventType = Value(eventType),
       payloadJson = Value(payloadJson);
  static Insertable<OutboxEvent> custom({
    Expression<String>? id,
    Expression<String>? eventType,
    Expression<String>? payloadJson,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (eventType != null) 'event_type': eventType,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxEventsCompanion copyWith({
    Value<String>? id,
    Value<String>? eventType,
    Value<String>? payloadJson,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return OutboxEventsCompanion(
      id: id ?? this.id,
      eventType: eventType ?? this.eventType,
      payloadJson: payloadJson ?? this.payloadJson,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxEventsCompanion(')
          ..write('id: $id, ')
          ..write('eventType: $eventType, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AscendDatabase extends GeneratedDatabase {
  _$AscendDatabase(QueryExecutor e) : super(e);
  $AscendDatabaseManager get managers => $AscendDatabaseManager(this);
  late final $LocalCoursesTable localCourses = $LocalCoursesTable(this);
  late final $LocalTopicsTable localTopics = $LocalTopicsTable(this);
  late final $LocalCardsTable localCards = $LocalCardsTable(this);
  late final $LocalEntitlementsTable localEntitlements =
      $LocalEntitlementsTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  late final $OutboxEventsTable outboxEvents = $OutboxEventsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    localCourses,
    localTopics,
    localCards,
    localEntitlements,
    syncMeta,
    outboxEvents,
  ];
}

typedef $$LocalCoursesTableCreateCompanionBuilder =
    LocalCoursesCompanion Function({
      required String id,
      required String slug,
      required String title,
      Value<String?> description,
      Value<int> contentRevision,
      Value<bool> locked,
      Value<String?> accessFeatureKey,
      Value<int> topicCount,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });
typedef $$LocalCoursesTableUpdateCompanionBuilder =
    LocalCoursesCompanion Function({
      Value<String> id,
      Value<String> slug,
      Value<String> title,
      Value<String?> description,
      Value<int> contentRevision,
      Value<bool> locked,
      Value<String?> accessFeatureKey,
      Value<int> topicCount,
      Value<DateTime> syncedAt,
      Value<int> rowid,
    });

class $$LocalCoursesTableFilterComposer
    extends Composer<_$AscendDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accessFeatureKey => $composableBuilder(
    column: $table.accessFeatureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topicCount => $composableBuilder(
    column: $table.topicCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCoursesTableOrderingComposer
    extends Composer<_$AscendDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get locked => $composableBuilder(
    column: $table.locked,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accessFeatureKey => $composableBuilder(
    column: $table.accessFeatureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topicCount => $composableBuilder(
    column: $table.topicCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get syncedAt => $composableBuilder(
    column: $table.syncedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCoursesTableAnnotationComposer
    extends Composer<_$AscendDatabase, $LocalCoursesTable> {
  $$LocalCoursesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get contentRevision => $composableBuilder(
    column: $table.contentRevision,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get locked =>
      $composableBuilder(column: $table.locked, builder: (column) => column);

  GeneratedColumn<String> get accessFeatureKey => $composableBuilder(
    column: $table.accessFeatureKey,
    builder: (column) => column,
  );

  GeneratedColumn<int> get topicCount => $composableBuilder(
    column: $table.topicCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get syncedAt =>
      $composableBuilder(column: $table.syncedAt, builder: (column) => column);
}

class $$LocalCoursesTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $LocalCoursesTable,
          LocalCourse,
          $$LocalCoursesTableFilterComposer,
          $$LocalCoursesTableOrderingComposer,
          $$LocalCoursesTableAnnotationComposer,
          $$LocalCoursesTableCreateCompanionBuilder,
          $$LocalCoursesTableUpdateCompanionBuilder,
          (
            LocalCourse,
            BaseReferences<_$AscendDatabase, $LocalCoursesTable, LocalCourse>,
          ),
          LocalCourse,
          PrefetchHooks Function()
        > {
  $$LocalCoursesTableTableManager(_$AscendDatabase db, $LocalCoursesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCoursesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCoursesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCoursesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> contentRevision = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<String?> accessFeatureKey = const Value.absent(),
                Value<int> topicCount = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCoursesCompanion(
                id: id,
                slug: slug,
                title: title,
                description: description,
                contentRevision: contentRevision,
                locked: locked,
                accessFeatureKey: accessFeatureKey,
                topicCount: topicCount,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String slug,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<int> contentRevision = const Value.absent(),
                Value<bool> locked = const Value.absent(),
                Value<String?> accessFeatureKey = const Value.absent(),
                Value<int> topicCount = const Value.absent(),
                Value<DateTime> syncedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCoursesCompanion.insert(
                id: id,
                slug: slug,
                title: title,
                description: description,
                contentRevision: contentRevision,
                locked: locked,
                accessFeatureKey: accessFeatureKey,
                topicCount: topicCount,
                syncedAt: syncedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCoursesTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $LocalCoursesTable,
      LocalCourse,
      $$LocalCoursesTableFilterComposer,
      $$LocalCoursesTableOrderingComposer,
      $$LocalCoursesTableAnnotationComposer,
      $$LocalCoursesTableCreateCompanionBuilder,
      $$LocalCoursesTableUpdateCompanionBuilder,
      (
        LocalCourse,
        BaseReferences<_$AscendDatabase, $LocalCoursesTable, LocalCourse>,
      ),
      LocalCourse,
      PrefetchHooks Function()
    >;
typedef $$LocalTopicsTableCreateCompanionBuilder =
    LocalTopicsCompanion Function({
      required String id,
      required String courseId,
      required String slug,
      required String title,
      Value<String?> description,
      required int position,
      Value<int> estimatedMinutes,
      Value<String> prerequisiteIdsJson,
      Value<int> rowid,
    });
typedef $$LocalTopicsTableUpdateCompanionBuilder =
    LocalTopicsCompanion Function({
      Value<String> id,
      Value<String> courseId,
      Value<String> slug,
      Value<String> title,
      Value<String?> description,
      Value<int> position,
      Value<int> estimatedMinutes,
      Value<String> prerequisiteIdsJson,
      Value<int> rowid,
    });

class $$LocalTopicsTableFilterComposer
    extends Composer<_$AscendDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get prerequisiteIdsJson => $composableBuilder(
    column: $table.prerequisiteIdsJson,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalTopicsTableOrderingComposer
    extends Composer<_$AscendDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get courseId => $composableBuilder(
    column: $table.courseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get prerequisiteIdsJson => $composableBuilder(
    column: $table.prerequisiteIdsJson,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalTopicsTableAnnotationComposer
    extends Composer<_$AscendDatabase, $LocalTopicsTable> {
  $$LocalTopicsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get courseId =>
      $composableBuilder(column: $table.courseId, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get prerequisiteIdsJson => $composableBuilder(
    column: $table.prerequisiteIdsJson,
    builder: (column) => column,
  );
}

class $$LocalTopicsTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $LocalTopicsTable,
          LocalTopic,
          $$LocalTopicsTableFilterComposer,
          $$LocalTopicsTableOrderingComposer,
          $$LocalTopicsTableAnnotationComposer,
          $$LocalTopicsTableCreateCompanionBuilder,
          $$LocalTopicsTableUpdateCompanionBuilder,
          (
            LocalTopic,
            BaseReferences<_$AscendDatabase, $LocalTopicsTable, LocalTopic>,
          ),
          LocalTopic,
          PrefetchHooks Function()
        > {
  $$LocalTopicsTableTableManager(_$AscendDatabase db, $LocalTopicsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalTopicsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalTopicsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalTopicsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> courseId = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String> prerequisiteIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTopicsCompanion(
                id: id,
                courseId: courseId,
                slug: slug,
                title: title,
                description: description,
                position: position,
                estimatedMinutes: estimatedMinutes,
                prerequisiteIdsJson: prerequisiteIdsJson,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String courseId,
                required String slug,
                required String title,
                Value<String?> description = const Value.absent(),
                required int position,
                Value<int> estimatedMinutes = const Value.absent(),
                Value<String> prerequisiteIdsJson = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalTopicsCompanion.insert(
                id: id,
                courseId: courseId,
                slug: slug,
                title: title,
                description: description,
                position: position,
                estimatedMinutes: estimatedMinutes,
                prerequisiteIdsJson: prerequisiteIdsJson,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalTopicsTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $LocalTopicsTable,
      LocalTopic,
      $$LocalTopicsTableFilterComposer,
      $$LocalTopicsTableOrderingComposer,
      $$LocalTopicsTableAnnotationComposer,
      $$LocalTopicsTableCreateCompanionBuilder,
      $$LocalTopicsTableUpdateCompanionBuilder,
      (
        LocalTopic,
        BaseReferences<_$AscendDatabase, $LocalTopicsTable, LocalTopic>,
      ),
      LocalTopic,
      PrefetchHooks Function()
    >;
typedef $$LocalCardsTableCreateCompanionBuilder =
    LocalCardsCompanion Function({
      required String id,
      required String topicId,
      required String versionId,
      required String frontJson,
      required String backJson,
      Value<double> difficulty,
      Value<int> rowid,
    });
typedef $$LocalCardsTableUpdateCompanionBuilder =
    LocalCardsCompanion Function({
      Value<String> id,
      Value<String> topicId,
      Value<String> versionId,
      Value<String> frontJson,
      Value<String> backJson,
      Value<double> difficulty,
      Value<int> rowid,
    });

class $$LocalCardsTableFilterComposer
    extends Composer<_$AscendDatabase, $LocalCardsTable> {
  $$LocalCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frontJson => $composableBuilder(
    column: $table.frontJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get backJson => $composableBuilder(
    column: $table.backJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalCardsTableOrderingComposer
    extends Composer<_$AscendDatabase, $LocalCardsTable> {
  $$LocalCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topicId => $composableBuilder(
    column: $table.topicId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get versionId => $composableBuilder(
    column: $table.versionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frontJson => $composableBuilder(
    column: $table.frontJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get backJson => $composableBuilder(
    column: $table.backJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalCardsTableAnnotationComposer
    extends Composer<_$AscendDatabase, $LocalCardsTable> {
  $$LocalCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topicId =>
      $composableBuilder(column: $table.topicId, builder: (column) => column);

  GeneratedColumn<String> get versionId =>
      $composableBuilder(column: $table.versionId, builder: (column) => column);

  GeneratedColumn<String> get frontJson =>
      $composableBuilder(column: $table.frontJson, builder: (column) => column);

  GeneratedColumn<String> get backJson =>
      $composableBuilder(column: $table.backJson, builder: (column) => column);

  GeneratedColumn<double> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );
}

class $$LocalCardsTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $LocalCardsTable,
          LocalCard,
          $$LocalCardsTableFilterComposer,
          $$LocalCardsTableOrderingComposer,
          $$LocalCardsTableAnnotationComposer,
          $$LocalCardsTableCreateCompanionBuilder,
          $$LocalCardsTableUpdateCompanionBuilder,
          (
            LocalCard,
            BaseReferences<_$AscendDatabase, $LocalCardsTable, LocalCard>,
          ),
          LocalCard,
          PrefetchHooks Function()
        > {
  $$LocalCardsTableTableManager(_$AscendDatabase db, $LocalCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> topicId = const Value.absent(),
                Value<String> versionId = const Value.absent(),
                Value<String> frontJson = const Value.absent(),
                Value<String> backJson = const Value.absent(),
                Value<double> difficulty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCardsCompanion(
                id: id,
                topicId: topicId,
                versionId: versionId,
                frontJson: frontJson,
                backJson: backJson,
                difficulty: difficulty,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String topicId,
                required String versionId,
                required String frontJson,
                required String backJson,
                Value<double> difficulty = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalCardsCompanion.insert(
                id: id,
                topicId: topicId,
                versionId: versionId,
                frontJson: frontJson,
                backJson: backJson,
                difficulty: difficulty,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $LocalCardsTable,
      LocalCard,
      $$LocalCardsTableFilterComposer,
      $$LocalCardsTableOrderingComposer,
      $$LocalCardsTableAnnotationComposer,
      $$LocalCardsTableCreateCompanionBuilder,
      $$LocalCardsTableUpdateCompanionBuilder,
      (
        LocalCard,
        BaseReferences<_$AscendDatabase, $LocalCardsTable, LocalCard>,
      ),
      LocalCard,
      PrefetchHooks Function()
    >;
typedef $$LocalEntitlementsTableCreateCompanionBuilder =
    LocalEntitlementsCompanion Function({
      required String featureKey,
      Value<String> constraintsJson,
      Value<DateTime?> endsAt,
      Value<int> rowid,
    });
typedef $$LocalEntitlementsTableUpdateCompanionBuilder =
    LocalEntitlementsCompanion Function({
      Value<String> featureKey,
      Value<String> constraintsJson,
      Value<DateTime?> endsAt,
      Value<int> rowid,
    });

class $$LocalEntitlementsTableFilterComposer
    extends Composer<_$AscendDatabase, $LocalEntitlementsTable> {
  $$LocalEntitlementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalEntitlementsTableOrderingComposer
    extends Composer<_$AscendDatabase, $LocalEntitlementsTable> {
  $$LocalEntitlementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalEntitlementsTableAnnotationComposer
    extends Composer<_$AscendDatabase, $LocalEntitlementsTable> {
  $$LocalEntitlementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get featureKey => $composableBuilder(
    column: $table.featureKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get constraintsJson => $composableBuilder(
    column: $table.constraintsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);
}

class $$LocalEntitlementsTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $LocalEntitlementsTable,
          LocalEntitlement,
          $$LocalEntitlementsTableFilterComposer,
          $$LocalEntitlementsTableOrderingComposer,
          $$LocalEntitlementsTableAnnotationComposer,
          $$LocalEntitlementsTableCreateCompanionBuilder,
          $$LocalEntitlementsTableUpdateCompanionBuilder,
          (
            LocalEntitlement,
            BaseReferences<
              _$AscendDatabase,
              $LocalEntitlementsTable,
              LocalEntitlement
            >,
          ),
          LocalEntitlement,
          PrefetchHooks Function()
        > {
  $$LocalEntitlementsTableTableManager(
    _$AscendDatabase db,
    $LocalEntitlementsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalEntitlementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalEntitlementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalEntitlementsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> featureKey = const Value.absent(),
                Value<String> constraintsJson = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEntitlementsCompanion(
                featureKey: featureKey,
                constraintsJson: constraintsJson,
                endsAt: endsAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String featureKey,
                Value<String> constraintsJson = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalEntitlementsCompanion.insert(
                featureKey: featureKey,
                constraintsJson: constraintsJson,
                endsAt: endsAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalEntitlementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $LocalEntitlementsTable,
      LocalEntitlement,
      $$LocalEntitlementsTableFilterComposer,
      $$LocalEntitlementsTableOrderingComposer,
      $$LocalEntitlementsTableAnnotationComposer,
      $$LocalEntitlementsTableCreateCompanionBuilder,
      $$LocalEntitlementsTableUpdateCompanionBuilder,
      (
        LocalEntitlement,
        BaseReferences<
          _$AscendDatabase,
          $LocalEntitlementsTable,
          LocalEntitlement
        >,
      ),
      LocalEntitlement,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AscendDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AscendDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AscendDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AscendDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AscendDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AscendDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;
typedef $$OutboxEventsTableCreateCompanionBuilder =
    OutboxEventsCompanion Function({
      required String id,
      required String eventType,
      required String payloadJson,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$OutboxEventsTableUpdateCompanionBuilder =
    OutboxEventsCompanion Function({
      Value<String> id,
      Value<String> eventType,
      Value<String> payloadJson,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$OutboxEventsTableFilterComposer
    extends Composer<_$AscendDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxEventsTableOrderingComposer
    extends Composer<_$AscendDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxEventsTableAnnotationComposer
    extends Composer<_$AscendDatabase, $OutboxEventsTable> {
  $$OutboxEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$OutboxEventsTableTableManager
    extends
        RootTableManager<
          _$AscendDatabase,
          $OutboxEventsTable,
          OutboxEvent,
          $$OutboxEventsTableFilterComposer,
          $$OutboxEventsTableOrderingComposer,
          $$OutboxEventsTableAnnotationComposer,
          $$OutboxEventsTableCreateCompanionBuilder,
          $$OutboxEventsTableUpdateCompanionBuilder,
          (
            OutboxEvent,
            BaseReferences<_$AscendDatabase, $OutboxEventsTable, OutboxEvent>,
          ),
          OutboxEvent,
          PrefetchHooks Function()
        > {
  $$OutboxEventsTableTableManager(_$AscendDatabase db, $OutboxEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion(
                id: id,
                eventType: eventType,
                payloadJson: payloadJson,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String eventType,
                required String payloadJson,
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxEventsCompanion.insert(
                id: id,
                eventType: eventType,
                payloadJson: payloadJson,
                status: status,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AscendDatabase,
      $OutboxEventsTable,
      OutboxEvent,
      $$OutboxEventsTableFilterComposer,
      $$OutboxEventsTableOrderingComposer,
      $$OutboxEventsTableAnnotationComposer,
      $$OutboxEventsTableCreateCompanionBuilder,
      $$OutboxEventsTableUpdateCompanionBuilder,
      (
        OutboxEvent,
        BaseReferences<_$AscendDatabase, $OutboxEventsTable, OutboxEvent>,
      ),
      OutboxEvent,
      PrefetchHooks Function()
    >;

class $AscendDatabaseManager {
  final _$AscendDatabase _db;
  $AscendDatabaseManager(this._db);
  $$LocalCoursesTableTableManager get localCourses =>
      $$LocalCoursesTableTableManager(_db, _db.localCourses);
  $$LocalTopicsTableTableManager get localTopics =>
      $$LocalTopicsTableTableManager(_db, _db.localTopics);
  $$LocalCardsTableTableManager get localCards =>
      $$LocalCardsTableTableManager(_db, _db.localCards);
  $$LocalEntitlementsTableTableManager get localEntitlements =>
      $$LocalEntitlementsTableTableManager(_db, _db.localEntitlements);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
  $$OutboxEventsTableTableManager get outboxEvents =>
      $$OutboxEventsTableTableManager(_db, _db.outboxEvents);
}
