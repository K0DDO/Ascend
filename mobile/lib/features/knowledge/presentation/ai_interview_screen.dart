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
  bool _checkingEntitlement = true;
  bool _hasEntitlement = false;
  String? _error;
  InterviewSession? _session;
  List<MistakeItem> _mistakes = const [];
  final _answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEntitlement();
  }

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  Future<void> _loadEntitlement() async {
    try {
      final keys = await ref.read(apiClientProvider).fetchEntitlements();
      if (mounted) {
        setState(() {
          _hasEntitlement = keys.any((item) => item.key == 'ai_interview');
          _checkingEntitlement = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _hasEntitlement = false;
          _checkingEntitlement = false;
        });
      }
    }
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

  Future<void> _loadMistakes(String sessionId) async {
    try {
      final items = await ref.read(apiClientProvider).fetchInterviewMistakes(sessionId: sessionId);
      if (mounted) setState(() => _mistakes = items);
    } catch (_) {
      // Non-blocking
    }
  }

  Future<void> _startInterview() async {
    setState(() {
      _loading = true;
      _error = null;
      _mistakes = const [];
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
      if (mounted) setState(() => _loading = false);
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
      if (updated.isCompleted) {
        await _loadMistakes(updated.sessionId);
      }
    } catch (_) {
      setState(() => _error = 'Не удалось отправить ответ.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildBlockedState(AscendTheme theme, TextTheme text) {
    return AscendGlassCard(
      strong: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline_rounded, color: theme.colors.warning, size: 32),
          SizedBox(height: theme.spacing.sm),
          Text('AI Interview недоступен', style: text.titleLarge),
          SizedBox(height: theme.spacing.xs),
          Text(
            'Для доступа нужен entitlement ai_interview. Обратитесь к ментору или администратору.',
            style: text.bodyMedium?.copyWith(color: theme.colors.muted),
          ),
        ],
      ),
    );
  }

  Widget _buildRubricRow(String label, double value, AscendTheme theme, TextTheme text) {
    return Padding(
      padding: EdgeInsets.only(bottom: theme.spacing.xxs),
      child: Row(
        children: [
          Expanded(child: Text(label, style: text.bodySmall)),
          Text('${(value * 100).round()}%', style: text.labelMedium),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = context.ascendTheme;
    final text = theme.typography.textTheme;
    final session = _session;

    if (_checkingEntitlement) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
          if (!_hasEntitlement)
            _buildBlockedState(theme, text)
          else ...[
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
                  if (session != null) ...[
                    SizedBox(height: theme.spacing.sm),
                    LinearProgressIndicator(
                      value: session.totalQuestions == 0
                          ? 0
                          : session.currentIndex / session.totalQuestions,
                      backgroundColor: theme.colors.border.withValues(alpha: 0.2),
                    ),
                    SizedBox(height: theme.spacing.xxs),
                    Text(
                      'Прогресс: ${session.currentIndex}/${session.totalQuestions}',
                      style: text.bodySmall?.copyWith(color: theme.colors.muted),
                    ),
                  ],
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
              if (session.isCompleted && session.summary != null) ...[
                SizedBox(height: theme.spacing.md),
                AscendGlassCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Итог', style: text.titleMedium),
                      SizedBox(height: theme.spacing.xs),
                      Text(
                        'Средняя оценка: ${(session.summary!.averageScore * 100).round()}%',
                        style: text.bodyLarge,
                      ),
                      Text(
                        'Уверенность: ${session.summary!.confidenceBand}',
                        style: text.bodyMedium?.copyWith(color: theme.colors.muted),
                      ),
                      if (session.summary!.weakDimensions.isNotEmpty) ...[
                        SizedBox(height: theme.spacing.xs),
                        Text(
                          'Слабые стороны: ${session.summary!.weakDimensions.join(', ')}',
                          style: text.bodySmall?.copyWith(color: theme.colors.warning),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
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
                        if (turn.rubric case final rubric?) ...[
                          SizedBox(height: theme.spacing.xs),
                          _buildRubricRow('Clarity', rubric.clarity, theme, text),
                          _buildRubricRow('Correctness', rubric.correctness, theme, text),
                          _buildRubricRow('Completeness', rubric.completeness, theme, text),
                          _buildRubricRow('Terminology', rubric.terminology, theme, text),
                        ],
                        if (turn.feedback case final f?) ...[
                          SizedBox(height: theme.spacing.xxs),
                          Text(f, style: text.bodySmall?.copyWith(color: theme.colors.muted)),
                        ],
                      ],
                    ),
                  ),
                ),
              if (_mistakes.isNotEmpty) ...[
                SizedBox(height: theme.spacing.md),
                Text('Mistakes deck', style: text.titleLarge),
                SizedBox(height: theme.spacing.sm),
                for (final item in _mistakes)
                  Padding(
                    padding: EdgeInsets.only(bottom: theme.spacing.sm),
                    child: AscendGlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.prompt, style: text.titleSmall),
                          SizedBox(height: theme.spacing.xxs),
                          Text(
                            'Подсказка: ${item.expectedHint}',
                            style: text.bodySmall?.copyWith(color: theme.colors.muted),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ],
          ],
        ],
      ),
    );
  }
}
