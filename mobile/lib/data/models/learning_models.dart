class ReviewSignal {
  const ReviewSignal({
    required this.cardId,
    required this.cardVersionId,
    required this.result,
    this.questionMs = 0,
    this.answerMs = 0,
    this.sourceOpened = false,
  });

  final String cardId;
  final String cardVersionId;
  final String result; // 'repeat' | 'know'
  final int questionMs;
  final int answerMs;
  final bool sourceOpened;

  Map<String, dynamic> toJson() => {
        'card_id': cardId,
        'card_version_id': cardVersionId,
        'result': result,
        'question_ms': questionMs,
        'answer_ms': answerMs,
        'source_opened': sourceOpened,
      };
}

class ReviewResult {
  const ReviewResult({
    required this.eventId,
    required this.cardId,
    required this.result,
  });

  final String eventId;
  final String cardId;
  final String result;

  factory ReviewResult.fromJson(Map<String, dynamic> json) => ReviewResult(
        eventId: json['event_id'] as String,
        cardId: json['card_id'] as String,
        result: json['result'] as String,
      );
}

class DueQueueItem {
  const DueQueueItem({
    required this.cardId,
    required this.isNew,
    this.retrievability,
  });

  final String cardId;
  final bool isNew;
  final double? retrievability;

  factory DueQueueItem.fromJson(Map<String, dynamic> json) => DueQueueItem(
        cardId: json['card_id'] as String,
        isNew: json['is_new'] as bool,
        retrievability: (json['retrievability'] as num?)?.toDouble(),
      );
}

class DueQueue {
  const DueQueue({required this.topicId, required this.items});

  final String topicId;
  final List<DueQueueItem> items;

  factory DueQueue.fromJson(Map<String, dynamic> json) => DueQueue(
        topicId: json['topic_id'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => DueQueueItem.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class TopicProgress {
  const TopicProgress({
    required this.topicId,
    required this.totalCards,
    required this.reviewedToday,
    required this.knowCount,
    required this.repeatCount,
  });

  final String topicId;
  final int totalCards;
  final int reviewedToday;
  final int knowCount;
  final int repeatCount;

  factory TopicProgress.fromJson(Map<String, dynamic> json) => TopicProgress(
        topicId: json['topic_id'] as String,
        totalCards: json['total_cards'] as int,
        reviewedToday: json['reviewed_today'] as int,
        knowCount: json['know_count'] as int,
        repeatCount: json['repeat_count'] as int,
      );
}
