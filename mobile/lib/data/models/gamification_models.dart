class Achievement {
  const Achievement({
    required this.key,
    required this.title,
    required this.unlocked,
    required this.progress,
  });

  final String key;
  final String title;
  final bool unlocked;
  final double progress;

  factory Achievement.fromJson(Map<String, dynamic> json) => Achievement(
        key: json['key'] as String,
        title: json['title'] as String,
        unlocked: json['unlocked'] as bool? ?? false,
        progress: (json['progress'] as num?)?.toDouble() ?? 0,
      );
}

class GamificationOverview {
  const GamificationOverview({
    required this.streakDays,
    required this.xpTotal,
    required this.xpToday,
    required this.dailyGoalReviews,
    required this.dailyProgressReviews,
    required this.achievements,
  });

  final int streakDays;
  final int xpTotal;
  final int xpToday;
  final int dailyGoalReviews;
  final int dailyProgressReviews;
  final List<Achievement> achievements;

  factory GamificationOverview.fromJson(Map<String, dynamic> json) => GamificationOverview(
        streakDays: json['streak_days'] as int? ?? 0,
        xpTotal: json['xp_total'] as int? ?? 0,
        xpToday: json['xp_today'] as int? ?? 0,
        dailyGoalReviews: json['daily_goal_reviews'] as int? ?? 0,
        dailyProgressReviews: json['daily_progress_reviews'] as int? ?? 0,
        achievements: ((json['achievements'] as List<dynamic>?) ?? const [])
            .map((item) => Achievement.fromJson(item as Map<String, dynamic>))
            .toList(),
      );
}
