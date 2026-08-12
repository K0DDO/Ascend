class InterviewTurn {
  const InterviewTurn({
    required this.turnIndex,
    required this.question,
    this.userAnswer,
    this.score,
    this.feedback,
  });

  final int turnIndex;
  final String question;
  final String? userAnswer;
  final double? score;
  final String? feedback;

  factory InterviewTurn.fromJson(Map<String, dynamic> json) => InterviewTurn(
        turnIndex: json['turn_index'] as int? ?? 0,
        question: json['question'] as String? ?? '',
        userAnswer: json['user_answer'] as String?,
        score: (json['score'] as num?)?.toDouble(),
        feedback: json['feedback'] as String?,
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
  });

  final String sessionId;
  final String topicId;
  final String status;
  final int currentIndex;
  final int totalQuestions;
  final double score;
  final String? nextQuestion;
  final List<InterviewTurn> turns;

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
      );
}
