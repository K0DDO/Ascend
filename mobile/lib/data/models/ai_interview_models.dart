class RubricScores {
  const RubricScores({
    required this.clarity,
    required this.correctness,
    required this.completeness,
    required this.terminology,
  });

  final double clarity;
  final double correctness;
  final double completeness;
  final double terminology;

  factory RubricScores.fromJson(Map<String, dynamic> json) => RubricScores(
        clarity: (json['clarity'] as num?)?.toDouble() ?? 0,
        correctness: (json['correctness'] as num?)?.toDouble() ?? 0,
        completeness: (json['completeness'] as num?)?.toDouble() ?? 0,
        terminology: (json['terminology'] as num?)?.toDouble() ?? 0,
      );
}

class InterviewTurn {
  const InterviewTurn({
    required this.turnIndex,
    required this.question,
    this.userAnswer,
    this.score,
    this.feedback,
    this.rubric,
    this.cardId,
  });

  final int turnIndex;
  final String question;
  final String? userAnswer;
  final double? score;
  final String? feedback;
  final RubricScores? rubric;
  final String? cardId;

  factory InterviewTurn.fromJson(Map<String, dynamic> json) => InterviewTurn(
        turnIndex: json['turn_index'] as int? ?? 0,
        question: json['question'] as String? ?? '',
        userAnswer: json['user_answer'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        feedback: json['feedback'] as String?,
        rubric: json['rubric'] == null
            ? null
            : RubricScores.fromJson(json['rubric'] as Map<String, dynamic>),
        cardId: json['card_id'] as String?,
      );
}

class InterviewSummary {
  const InterviewSummary({
    required this.averageScore,
    required this.confidenceBand,
    required this.strongDimensions,
    required this.weakDimensions,
    required this.mistakeCount,
  });

  final double averageScore;
  final String confidenceBand;
  final List<String> strongDimensions;
  final List<String> weakDimensions;
  final int mistakeCount;

  factory InterviewSummary.fromJson(Map<String, dynamic> json) => InterviewSummary(
        averageScore: (json['average_score'] as num?)?.toDouble() ?? 0,
        confidenceBand: json['confidence_band'] as String? ?? 'low',
        strongDimensions: ((json['strong_dimensions'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        weakDimensions: ((json['weak_dimensions'] as List<dynamic>?) ?? const [])
            .map((e) => e.toString())
            .toList(),
        mistakeCount: json['mistake_count'] as int? ?? 0,
      );
}

class MistakeItem {
  const MistakeItem({
    required this.id,
    required this.prompt,
    required this.expectedHint,
    this.userAnswer,
    required this.score,
  });

  final String id;
  final String prompt;
  final String expectedHint;
  final String? userAnswer;
  final double score;

  factory MistakeItem.fromJson(Map<String, dynamic> json) => MistakeItem(
        id: json['id'] as String,
        prompt: json['prompt'] as String? ?? '',
        expectedHint: json['expected_hint'] as String? ?? '',
        userAnswer: json['user_answer'] as String?,
        score: (json['score'] as num?)?.toDouble() ?? 0,
      );
}

class InterviewSession {
  const InterviewSession({
    required this.sessionId,
    required this.topicId,
    required this.status,
    required this.currentIndex,
    required this.totalQuestions,
    required this.score,
    this.nextQuestion,
    required this.turns,
    this.summary,
  });

  final String sessionId;
  final String topicId;
  final String status;
  final int currentIndex;
  final int totalQuestions;
  final double score;
  final String? nextQuestion;
  final List<InterviewTurn> turns;
  final InterviewSummary? summary;

  bool get isCompleted => status == 'completed';

  factory InterviewSession.fromJson(Map<String, dynamic> json) => InterviewSession(
        sessionId: json['session_id'] as String,
        topicId: json['topic_id'] as String,
        status: json['status'] as String? ?? 'in_progress',
        currentIndex: json['current_index'] as int? ?? 0,
        totalQuestions: json['total_questions'] as int? ?? 0,
        score: (json['score'] as num?)?.toDouble() ?? 0,
        nextQuestion: json['next_question'] as String?,
        turns: ((json['turns'] as List<dynamic>?) ?? const [])
            .map((e) => InterviewTurn.fromJson(e as Map<String, dynamic>))
            .toList(),
        summary: json['summary'] == null
            ? null
            : InterviewSummary.fromJson(json['summary'] as Map<String, dynamic>),
      );
}
