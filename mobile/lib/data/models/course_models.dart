class CourseSummary {
  const CourseSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.contentRevision,
    required this.locked,
    this.accessFeatureKey,
    required this.topicCount,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final int contentRevision;
  final bool locked;
  final String? accessFeatureKey;
  final int topicCount;

  factory CourseSummary.fromJson(Map<String, dynamic> json) {
    return CourseSummary(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      contentRevision: json['content_revision'] as int? ?? 1,
      locked: json['locked'] as bool? ?? true,
      accessFeatureKey: json['access_feature_key'] as String?,
      topicCount: json['topic_count'] as int? ?? 0,
    );
  }
}

class CourseListResponse {
  const CourseListResponse({required this.courses});

  final List<CourseSummary> courses;

  factory CourseListResponse.fromJson(Map<String, dynamic> json) {
    final items = json['courses'] as List<dynamic>? ?? const [];
    return CourseListResponse(
      courses: items.map((item) => CourseSummary.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class TopicSummary {
  const TopicSummary({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.position,
    required this.estimatedMinutes,
    required this.prerequisiteIds,
    this.locked = false,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final int position;
  final int estimatedMinutes;
  final List<String> prerequisiteIds;
  final bool locked;

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int? ?? 0,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
      prerequisiteIds: (json['prerequisite_ids'] as List<dynamic>? ?? const []).cast<String>(),
      locked: json['locked'] as bool? ?? false,
    );
  }
}

class CourseSection {
  const CourseSection({
    required this.id,
    required this.title,
    required this.topics,
  });

  final String id;
  final String title;
  final List<TopicSummary> topics;

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    final items = json['topics'] as List<dynamic>? ?? const [];
    return CourseSection(
      id: json['id'] as String,
      title: json['title'] as String,
      topics: items.map((item) => TopicSummary.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class CourseDetail {
  const CourseDetail({
    required this.id,
    required this.slug,
    required this.title,
    required this.description,
    required this.locked,
    required this.sections,
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final bool locked;
  final List<CourseSection> sections;

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    final items = json['sections'] as List<dynamic>? ?? const [];
    return CourseDetail(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      locked: json['locked'] as bool? ?? true,
      sections: items.map((item) => CourseSection.fromJson(item as Map<String, dynamic>)).toList(),
    );
  }
}

class CardSourceRef {
  const CardSourceRef({
    required this.documentId,
    required this.sourceVersionId,
    this.blockId,
    this.documentTitle,
  });

  final String documentId;
  final String sourceVersionId;
  final String? blockId;
  final String? documentTitle;

  factory CardSourceRef.fromJson(Map<String, dynamic> json) => CardSourceRef(
        documentId: json['document_id'] as String,
        sourceVersionId: json['source_version_id'] as String,
        blockId: json['block_id'] as String?,
        documentTitle: json['document_title'] as String?,
      );
}

class CardPreview {
  const CardPreview({
    required this.id,
    required this.versionId,
    required this.front,
    required this.back,
    required this.difficulty,
    this.sources = const [],
  });

  final String id;
  final String versionId;
  final Map<String, dynamic> front;
  final Map<String, dynamic> back;
  final double difficulty;
  final List<CardSourceRef> sources;

  factory CardPreview.fromJson(Map<String, dynamic> json) {
    return CardPreview(
      id: json['id'] as String,
      versionId: json['version_id'] as String,
      front: json['front'] as Map<String, dynamic>? ?? const {},
      back: json['back'] as Map<String, dynamic>? ?? const {},
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
      sources: ((json['sources'] as List<dynamic>?) ?? const [])
          .map((e) => CardSourceRef.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class SourceBlock {
  const SourceBlock({
    required this.id,
    required this.blockKey,
    required this.type,
    required this.position,
    required this.payload,
  });

  final String id;
  final String blockKey;
  final String type;
  final int position;
  final Map<String, dynamic> payload;

  factory SourceBlock.fromJson(Map<String, dynamic> json) => SourceBlock(
        id: json['id'] as String,
        blockKey: json['block_key'] as String? ?? '',
        type: json['type'] as String? ?? 'paragraph',
        position: json['position'] as int? ?? 0,
        payload: json['payload'] as Map<String, dynamic>? ?? const {},
      );
}

class SourceDocument {
  const SourceDocument({
    required this.id,
    required this.title,
    required this.topicId,
    required this.versionId,
    required this.version,
    required this.blocks,
  });

  final String id;
  final String title;
  final String topicId;
  final String versionId;
  final int version;
  final List<SourceBlock> blocks;

  factory SourceDocument.fromJson(Map<String, dynamic> json) => SourceDocument(
        id: json['id'] as String,
        title: json['title'] as String? ?? '',
        topicId: json['topic_id'] as String,
        versionId: json['version_id'] as String,
        version: json['version'] as int? ?? 1,
        blocks: ((json['blocks'] as List<dynamic>?) ?? const [])
            .map((e) => SourceBlock.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
