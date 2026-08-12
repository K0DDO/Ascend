import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/ascend_theme.dart';
import '../../../core/widgets/ascend_glass_button.dart';
import '../../../core/widgets/ascend_glass_card.dart';
import '../../../data/models/ai_interview_models.dart';
import '../../../features/learn/application/courses_provider.dart';

class AIInterviewScreen extends ConsumerStatefulWidget {
  const AIInterviewScreen({super.key});

  @override
  ConsumerState<AIInterviewScreen> createState() => _AIInterviewScreenState();
}

class _AIInterviewScreenState extends ConsumerState<AIInterviewScreen> {
  bool _loading = false;
  String? _error;
  InterviewSession? _session;
  final _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<String?> _pickTopicId() async {
    final coursesSnapshot = await ref.read(coursesProvider.future);
    for (final course in coursesSnapshot.courses) {
      if (course.locked) continue;
      final detail = await ref.read(courseDetailProvider(course.id).future);
      if (detail == null) continue;
      for (final section in detail.sections) {
        if (section.topics.isNotEmpty) {
          return section.topics.first.id;
        }
      }
    }
    return null;
  }

  Future<void> _startInterview() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final topicId = await _pickTopicId();
      if (topicId == null) {
        setState(() => _error = 'Нет доступных тем для интервью.');
        return;
      }
      final session = await ref.read(apiClientProvider).startInterview(topicId: topicId, questionCount: 3);
      setState(() => _session = session);
    } catch (e) {
      setState(() => _error = 'Не удалось запустить интервью. Проверьте entitlement ai_interview.');
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _submitAnswer() async {
    final session = _session;
    final answer = _answerController.text.trim();
    if (session == null || answer.isEmpty || _loading) return;
    setState(() => _loading = true);
    try {
      final updated = await ref.read(apiClientProvider).answerInterview(
            sessionId: session.sessionId,
            answer: answer,
          );
      _answerController.clear();
      setState(() => _session = updated);
    } catch (_) {
      setState(() => _error = 'Не удалось отправить ответ.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    final session = _session;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('AI Interview'),
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(
          theme.spacing.lg,
          theme.spacing.md,
          theme.spacing.lg,
          theme.spacing.hotbarContentInset,
        ),
        children: [
          AscendGlassCard(
            strong: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mock Interview', style: text.titleLarge),
                SizedBox(height: theme.spacing.xs),
                Text(
                  'Grounded режим: вопросы формируются по карточкам темы.',
                  style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                ),
                SizedBox(height: theme.spacing.md),
                AscendGlassButton(
                  label: session == null ? 'Запустить интервью' : 'Перезапустить',
                  icon: Icons.record_voice_over_rounded,
                  onPressed: _loading ? null : _startInterview,
                ),
              ],
            ),
          ),
          if (_error case final err?) ...[
            SizedBox(height: theme.spacing.md),
            Text(err, style: text.bodyMedium?.copyWith(color: theme.colors.error)),
          ],
          if (session != null) ...[
            SizedBox(height: theme.spacing.lg),
            AscendGlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.isCompleted
                        ? 'Интервью завершено'
                        : 'Вопрос ${session.currentIndex + 1}/${session.totalQuestions}',
                    style: text.titleMedium,
                  ),
                  SizedBox(height: theme.spacing.xs),
                  Text(
                    session.nextQuestion ?? 'Вопросов больше нет.',
                    style: text.bodyLarge,
                  ),
                  if (!session.isCompleted) ...[
                    SizedBox(height: theme.spacing.md),
                    TextField(
                      controller: _answerController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'Введите развернутый ответ...',
                      ),
                    ),
                    SizedBox(height: theme.spacing.md),
                    AscendGlassButton(
                      label: 'Отправить ответ',
                      icon: Icons.send_rounded,
                      onPressed: _loading ? null : _submitAnswer,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(height: theme.spacing.md),
            for (final turn in session.turns)
              Padding(
                padding: EdgeInsets.only(bottom: theme.spacing.sm),
                child: AscendGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Q${turn.turnIndex + 1}: ${turn.question}', style: text.titleSmall),
                      if (turn.userAnswer case final a?) ...[
                        SizedBox(height: theme.spacing.xs),
                        Text('Ответ: $a', style: text.bodyMedium),
                      ],
                      if (turn.score case final s?) ...[
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          'Оценка: ${(s * 100).round()}%',
                          style: text.bodySmall?.copyWith(color: theme.colors.primary),
                        ),
                      ],
                      if (turn.feedback case final f?) ...[
                        SizedBox(height: theme.spacing.xxs),
                        Text(f, style: text.bodySmall?.copyWith(color: theme.colors.muted)),
                      ],
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
