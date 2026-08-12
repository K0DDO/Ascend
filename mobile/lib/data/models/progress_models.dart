class WeakArea {
  const WeakArea({
    required this.topicId,
    required this.topicTitle,
    required this.mastery,
  });

  final String topicId;
  final String topicTitle;
  final double mastery;

  factory WeakArea.fromJson(Map<String, dynamic> json) => WeakArea(
        topicId: json['topic_id'] as String,
        topicTitle: json['topic_title'] as String,
        mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
      );
}

class ActivityPoint {
  const ActivityPoint({
    required this.day,
    required this.reviews,
  });

  final DateTime day;
  final int reviews;

  factory ActivityPoint.fromJson(Map<String, dynamic> json) => ActivityPoint(
        day: DateTime.parse(json['day'] as String),
        reviews: json['reviews'] as int? ?? 0,
      );
}

class ProgressOverview {
  const ProgressOverview({
    required this.totalReviews,
    required this.knowRate,
    required this.readiness,
    required this.weakAreas,
    required this.activity,
  });

  final int totalReviews;
  final double knowRate;
  final double readiness;
  final List<WeakArea> weakAreas;
  final List<ActivityPoint> activity;

  factory ProgressOverview.fromJson(Map<String, dynamic> json) => ProgressOverview(
        totalReviews: json['total_reviews'] as int? ?? 0,
        knowRate: (json['know_rate'] as num?)?.toDouble() ?? 0,
        readiness: (json['readiness'] as num?)?.toDouble() ?? 0,
        weakAreas: ((json['weak_areas'] as List<dynamic>?) ?? const [])
            .map((item) => WeakArea.fromJson(item as Map<String, dynamic>))
            .toList(),
        activity: ((json['activity'] as List<dynamic>?) ?? const [])
            .map((item) => ActivityPoint.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
