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
  });

  final String id;
  final String slug;
  final String title;
  final String? description;
  final int position;
  final int estimatedMinutes;
  final List<String> prerequisiteIds;

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      id: json['id'] as String,
      slug: json['slug'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      position: json['position'] as int? ?? 0,
      estimatedMinutes: json['estimated_minutes'] as int? ?? 0,
      prerequisiteIds: (json['prerequisite_ids'] as List<dynamic>? ?? const []).cast<String>(),
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

class CardPreview {
  const CardPreview({
    required this.id,
    required this.versionId,
    required this.front,
    required this.back,
    required this.difficulty,
  });

  final String id;
  final String versionId;
  final Map<String, dynamic> front;
  final Map<String, dynamic> back;
  final double difficulty;

  factory CardPreview.fromJson(Map<String, dynamic> json) {
    return CardPreview(
      id: json['id'] as String,
      versionId: json['version_id'] as String,
      front: json['front'] as Map<String, dynamic>? ?? const {},
      back: json['back'] as Map<String, dynamic>? ?? const {},
      difficulty: (json['difficulty'] as num?)?.toDouble() ?? 0.5,
    );
  }
}
